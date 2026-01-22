import dataclasses
import json
import os
from typing import List, Type

from dacite import Config as DaciteConfig
from dacite import from_dict

from objects import Query


@dataclasses.dataclass
class CollectResult:
    db_version: str = ""
    git_message: str = ""
    ddl_execution_time: int = 0
    model_execution_time: int = 0
    config: str = ""
    database_config: str = ""
    model_queries: List[str] = None
    queries: List[Type[Query]] = None

    def append(self, new_element):
        if not self.queries:
            self.queries = [new_element, ]
        else:
            self.queries.append(new_element)

        # CPUs are cheap
        self.queries.sort(key=lambda q: q.query_hash)

    def find_query_by_hash(self, query_hash) -> Type[Query] | None:
        return next(
            (query for query in self.queries if query.query_hash == query_hash),
            None,
        )


class EnhancedJSONEncoder(json.JSONEncoder):
    def default(self, o):
        if dataclasses.is_dataclass(o):
            return dataclasses.asdict(o)
        return super().default(o)


class ResultsLoader:

    def __init__(self):
        self.clazz = CollectResult

    def get_queries_from_previous_result(self, previous_execution_path):
        # Try exact path first
        if os.path.exists(previous_execution_path):
            with open(previous_execution_path, "r") as prev_result:
                return from_dict(self.clazz, json.load(prev_result), DaciteConfig(check_types=False))

        # Try adding .json extension if path doesn't exist
        json_path = previous_execution_path + '.json'
        if os.path.exists(json_path):
            with open(json_path, "r") as prev_result:
                return from_dict(self.clazz, json.load(prev_result), DaciteConfig(check_types=False))

        # Fall back to original path (will raise FileNotFoundError)
        with open(previous_execution_path, "r") as prev_result:
            return from_dict(self.clazz, json.load(prev_result), DaciteConfig(check_types=False))

    def store_queries_to_file(self, queries: Type[CollectResult], output_json_name: str):
        if not os.path.isdir("report"):
            os.mkdir("report")

        with open(f"report/{output_json_name}.json", "w") as result_file:
            result_file.write(json.dumps(queries, cls=EnhancedJSONEncoder))


class IncrementalResultsWriter:
    """Writes query results incrementally to disk to reduce memory usage.

    Format: JSON Lines (.jsonl) with:
    - First line: metadata record (db_version, git_message, config, etc.)
    - Subsequent lines: one query result per line

    On finalize(), consolidates to a single JSON file.
    """

    # Remove duplicates if optimization count exceeds this threshold
    DEDUP_THRESHOLD = 300

    def __init__(self, output_name: str):
        self.output_name = output_name
        self.jsonl_path = None
        self.json_path = None
        self.file_handle = None
        self.queries_written = 0
        self.metadata = None

    def start(self, metadata: CollectResult):
        """Initialize the output file and write metadata."""
        if not os.path.isdir("report"):
            os.mkdir("report")

        self.jsonl_path = f"report/{self.output_name}.jsonl"
        self.json_path = f"report/{self.output_name}.json"
        self.file_handle = open(self.jsonl_path, "w")

        # Store metadata for final JSON
        self.metadata = {
            "db_version": metadata.db_version,
            "git_message": metadata.git_message,
            "ddl_execution_time": metadata.ddl_execution_time,
            "model_execution_time": metadata.model_execution_time,
            "config": metadata.config,
            "database_config": metadata.database_config,
            "model_queries": metadata.model_queries or [],
        }

        # Write metadata as first line
        metadata_record = {"_type": "metadata", **self.metadata}
        self.file_handle.write(json.dumps(metadata_record) + "\n")
        self.file_handle.flush()

    def write_query(self, query: Query):
        """Write a single query result and flush to disk."""
        if not self.file_handle:
            raise RuntimeError("IncrementalResultsWriter not started")

        query_record = dataclasses.asdict(query)
        query_record["_type"] = "query"
        self.file_handle.write(json.dumps(query_record, cls=EnhancedJSONEncoder) + "\n")
        self.file_handle.flush()
        self.queries_written += 1

    def _deduplicate_optimizations(self, optimizations):
        """Remove duplicate optimizations based on cost_off_explain plan hash."""
        if not optimizations or len(optimizations) <= self.DEDUP_THRESHOLD:
            return optimizations

        seen_plans = set()
        unique_optimizations = []

        for opt in optimizations:
            # Get plan hash from cost_off_explain
            plan_str = ""
            if opt.get("cost_off_explain"):
                cost_off = opt["cost_off_explain"]
                if isinstance(cost_off, dict):
                    plan_str = cost_off.get("full_str", "")
                elif hasattr(cost_off, "full_str"):
                    plan_str = cost_off.full_str

            # Simple hash of the plan
            plan_hash = hash(plan_str) if plan_str else hash(str(opt.get("explain_hints", "")))

            if plan_hash not in seen_plans:
                seen_plans.add(plan_hash)
                unique_optimizations.append(opt)

        return unique_optimizations

    def finalize(self):
        """Consolidate JSONL to final JSON file and clean up."""
        if self.file_handle:
            self.file_handle.close()
            self.file_handle = None

        if not self.jsonl_path or not os.path.exists(self.jsonl_path):
            return

        # Read JSONL and build final result
        result = {
            **self.metadata,
            "queries": []
        }

        total_optimizations = 0
        deduped_optimizations = 0

        with open(self.jsonl_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                record = json.loads(line)
                record_type = record.pop("_type", None)

                if record_type == "query":
                    # Deduplicate optimizations if count is high
                    if record.get("optimizations"):
                        original_count = len(record["optimizations"])
                        total_optimizations += original_count

                        if original_count > self.DEDUP_THRESHOLD:
                            record["optimizations"] = self._deduplicate_optimizations(
                                record["optimizations"])
                            deduped_optimizations += original_count - len(record["optimizations"])

                    result["queries"].append(record)

        # Sort queries by hash for consistency
        result["queries"].sort(key=lambda q: q.get("query_hash", ""))

        # Write final JSON
        with open(self.json_path, "w") as f:
            json.dump(result, f, cls=EnhancedJSONEncoder)

        # Remove temporary JSONL file
        os.remove(self.jsonl_path)

        return total_optimizations, deduped_optimizations

    def finish(self):
        """Close the output file without finalizing."""
        if self.file_handle:
            self.file_handle.close()
            self.file_handle = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        # Only finalize on successful completion
        if exc_type is None:
            self.finalize()
        else:
            self.finish()
        return False
