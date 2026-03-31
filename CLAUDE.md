# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TAQO (Testing Accuracy of Query Optimizer) is a Python-based testing framework for query optimizers in PostgreSQL-compatible databases (YugabyteDB, PostgreSQL, CockroachDB). It automates optimizer testing inspired by the [TAQO research paper](https://www.researchgate.net/publication/241623318_Testing_the_accuracy_of_query_optimizers) — evaluating queries with different execution plans via pg_hint_plan to determine if the optimizer selects optimal plans.

## Development Commands

### Environment Setup
```bash
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

Python 3.10+ required. No linting/formatting tools are configured in the repo.

### Running the Tool
```bash
# Full CLI help
python3 src/runner.py -h

# Collect mode - evaluate queries and store results
python3 src/runner.py collect \
  --model=basic --config=config/default.conf \
  --output=taqo_basic --database=taqo --optimizations --yes

# Quick debug run (limited queries, plans only)
python3 src/runner.py collect \
  --model=basic --config=config/default.conf \
  --output=debug_run --num-queries=5 --plans-only --yes

# Report mode - generate reports from collected data
python3 src/runner.py report --type=taqo \
  --config=config/default.conf --results=report/yb_results.json

# Regression report (compare two versions)
python3 src/runner.py report --type=regression \
  --config=config/default.conf \
  --v1-results=report/v1.json --v2-results=report/v2.json

# Score report (YB vs PG comparison with charts)
python3 src/runner.py report --type=score \
  --config=config/default.conf \
  --results=report/yb.json --pg-results=report/pg.json
```

### Testing Changes

No formal test suite exists. Validate changes by:
- Running a small model: `--model=basic --num-queries=5`
- Using `--plans-only` for fast plan-only checks (no query execution)
- Comparing outputs across runs with `--type=regression` report
- Checking that generated JSON in `report/` and rendered HTML reports are valid

### Running Against Different Databases
```bash
# YugabyteDB (default, port 5433)
python3 src/runner.py collect --db=yugabyte --model=basic --output=yb_test --yes

# PostgreSQL (port 5432, auto-sets --ddl-prefix=postgres)
python3 src/runner.py collect --db=postgres --port=5432 --model=basic --output=pg_test --yes

# CockroachDB
python3 src/runner.py collect --db=cockroach --port=26257 --model=basic --output=crdb_test --yes
```

## Architecture

### Entry Point and Flow

`src/runner.py` is the CLI entry point (~70 arguments) supporting two actions:

1. **Collect** (`src/actions/collect.py`) — DDL execution flow: DROP → CREATE → IMPORT → ANALYZE → COMPACT → Query evaluation → JSON output
2. **Report** (`src/actions/report.py` + `src/actions/reports/`) — Load JSON results → Generate AsciiDoc → Convert to HTML via asciidoctor

### Core Modules

- **`src/config.py`** — `Config` (singleton via metaclass) and `ConnectionConfig` dataclasses, `DDLStep` enum. Config priority: CLI args > `--options key=value` > model `model.conf` > `config/default.conf`
- **`src/objects.py`** — Core data structures: `Query`, `ExecutionPlan`, `PlanNode` (tree), `Table`, `Field`, `QueryTips`, `ListOfQueries`
- **`src/collect.py`** — Serialization: `CollectResult`, `ResultsLoader`, `EnhancedJSONEncoder`
- **`src/utils.py`** — SQL parsing, execution timing, result hashing

### Database Adapters (`src/db/`)

All adapters inherit from `Database` (`database.py`). Key interface methods: `establish_connection()`, `create_test_database()`, `get_execution_plan()`, `get_list_optimizations()`.

- **`postgres.py`** (reference implementation, ~712 lines) — Contains `Postgres`, `Connection` (psycopg2 wrapper), `PostgresQuery`, `PostgresOptimization`, `PostgresExecutionPlan`, `PGListOfOptimizations`, `Leading` (join order hint generation)
- **`yugabyte.py`** — Extends Postgres with compaction/flush, RPC metrics, colocated DB support, source-build support (`YugabyteLocalRepository`, `YugabyteLocalCluster`)
- **`cockroach.py`** — Extends Postgres with CRDB-specific plan text parsing

### SQL Models (`src/models/`)

`SQLModel` (`sql.py`) loads from `sql/$MODEL_NAME/` directory. Factory in `factory.py`.

Directory structure per model:
```
sql/$MODEL_NAME/
  ├── create.sql, drop.sql, import.sql, analyze.sql
  ├── postgres.create.sql   # Optional DB-specific variant (--ddl-prefix=postgres)
  ├── model.conf             # Optional per-model config overrides
  └── queries/*.sql          # Individual test queries (one per file)
```

### Optimization Hint Generation

The `Leading` class in `postgres.py` generates pg_hint_plan hints:
1. All table permutations → Leading hints (join order)
2. For each: all join type combinations (NestLoop, Hash, Merge)
3. For each: all scan type combinations (Sequential, Index)

**Pairwise reduction:** For queries with >3 tables (configurable via `all-pairs-threshold`), uses `allpairspy` library to reduce combinations while maintaining coverage.

**Query hints** in SQL files control generation:
```sql
-- accept: a b c           # Only use this join order
-- reject: NestLoop        # Exclude NestLoop joins
-- max_timeout: 5s         # Custom timeout
-- tags: muted_nlj, skip_consistency_check
-- debug_hints: set (yb_enable_optimizer_statistics false)
```

### Report Types (`src/actions/reports/`)

- **taqo** — Base optimizer performance analysis with TAQO scoring
- **score** — Comparative YB vs PG analysis with bokeh charts
- **regression** — Version-to-version comparison
- **comparison** — Side-by-side plan comparison
- **selectivity** — Selectivity estimation analysis
- **cost** — Cost model validation with interactive bokeh visualizations

Reports are AsciiDoc → HTML (requires `asciidoctor` gem + `coderay` for syntax highlighting).

### Configuration (`config/default.conf`, HOCON format)

Key settings: `explain-clause`, `session-props` (pg_hint_plan config), `skip-percentage-delta` (5%), `test-query-timeout` (1200s), `num-retries` (5), `num-warmup` (1), `all-pairs-threshold` (3), `look-near-best-plan` (true).

Override config from CLI: `--options "key=value"` (supports `int:` and `bool:` prefixes for type coercion).

## Important Implementation Details

- **Config singleton**: `Config()` is globally accessible without parameter passing (metaclass singleton)
- **Execution plan comparison**: Plans compared with `COSTS OFF` to detect equivalents; duplicates skipped
- **Result validation**: Hash-based consistency check across all optimization variants. DML uses rowcount instead. Disable with `skip_consistency_check` tag
- **Timeout cascade**: Framework tracks minimum execution time and uses it as timeout for subsequent optimizations
- **Plan parsing**: Regex-based with hierarchical `PlanNode` tree. Supports visitor pattern (`PlanNodeVisitor`, `PlanPrinter`)
- **Reconnection**: `CollectAction._reconnect()` handles dropped connections; RPC timeout retries in DDL evaluation
- **SQL alias limitation**: A query must have either all tables aliased or no aliases (due to SQL parsing)

## Coding Style

Python 3.10+, PEP 8 (4-space indent). snake_case for modules/functions, PascalCase for classes. Place new actions under `src/actions/`, new reports under `src/actions/reports/`, new DB adapters under `src/db/`.

## Useful Flags Reference

- `--optimizations` / `--no-optimizations` — Enable/disable hint generation
- `--plans-only` — Collect only execution plans (fast, no query execution)
- `--server-side-execution` — Use EXPLAIN ANALYZE for timing
- `--ddl-prefix` — Select DB-specific DDL variant (e.g., `postgres`)
- `--ddls` — DDL stages to run (comma-separated: database,create,analyze,import,compact,drop)
- `--num-queries` — Limit queries (useful for debugging)
- `--options` — Override config key=value pairs
- `--exit-on-fail` — Exit on query failures
- `--verbose` — DEBUG logging
- `--yes` — Skip confirmation prompt
