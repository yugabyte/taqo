from inspect import cleandoc

from config import Config
from db.yugabyte import ENABLE_STATISTICS_HINT
from utils import parse_clear_and_parametrized_sql


class PgUnitGenerator:

    def __init__(self):
        self.config = Config()

    @staticmethod
    def add_semicolon(line: str):
        if line.endswith(";"):
            return line
        else:
            return f"{line};"

    @staticmethod
    def wrap_query_plan(plan: str):
        num_rows = len(plan.split("\n"))
        max_length = max(len(line) for line in plan.split("\n")) + 2
        plan = "\n".join([f" {row}" for row in plan.split("\n")])

        return f"""
{' ' * int(max_length / 2 - 5)}QUERY PLAN
{('-' * max_length)}
{plan}
({num_rows} rows)

"""

    def generate_postgres_unit_tests(self, teardown_queries, create_queries, queries):
        # generate sql file
        with open(f"report/{self.config.output}.sql", "w") as result_file:
            result_file.write(f"CREATE DATABASE {self.config.connection.database} with colocation = true;\n")
            result_file.write(f"\c {self.config.connection.database}\n\n")
            result_file.write(f"SET statement_timeout = '{self.config.ddl_query_timeout}s'\n\n")
            for model_query in create_queries:
                if model_query.startswith("--"):
                    result_file.write(model_query)
                else:
                    result_file.write(self.add_semicolon(' '.join(model_query.split())))
                result_file.write("\n")

            result_file.write("\n")
            result_file.write("-- TBD: ADD STATISTICS IMPORT QUERIES\n")
            result_file.write("\n")

            for session_prop in self.config.session_props:
                result_file.write(self.add_semicolon(session_prop))
                result_file.write("\n")

            result_file.write("\n")
            result_file.write("\n")

            # cbo query?
            if self.config.enable_statistics:
                result_file.write(self.add_semicolon(ENABLE_STATISTICS_HINT))
                result_file.write("\n")

            result_file.write("\n")

            previous_tag = None
            for query in queries:
                _,_, clean_query = parse_clear_and_parametrized_sql(query.get_costs_off_explain())
                if previous_tag != query.tag:
                    result_file.write("\n")
                    previous_tag = query.tag
                result_file.write(cleandoc(self.add_semicolon(clean_query)))
                result_file.write("\n")

            result_file.write("\n")

            for model_query in teardown_queries:
                result_file.write(self.add_semicolon(model_query.replace("\n", "")))
                result_file.write("\n")

        # generate out file
        with open(f"report/{self.config.output}.out", "w") as result_file:
            result_file.write(f"CREATE DATABASE {self.config.connection.database} with colocation = true;\n")
            result_file.write(f"\c {self.config.connection.database}\n\n")
            result_file.write(f"SET statement_timeout = '{self.config.ddl_query_timeout}s'\n\n")
            for model_query in create_queries:
                if model_query.startswith("--"):
                    result_file.write(model_query)
                else:
                    result_file.write(self.add_semicolon(' '.join(model_query.split())))
                result_file.write("\n")

            result_file.write("\n")
            result_file.write("-- TBD: ADD STATISTICS IMPORT QUERIES\n")
            result_file.write("\n")

            for session_prop in self.config.session_props:
                result_file.write(self.add_semicolon(session_prop))
                result_file.write("\n")

            result_file.write("\n")
            result_file.write("\n")

            # cbo query?
            if self.config.enable_statistics:
                result_file.write(self.add_semicolon(ENABLE_STATISTICS_HINT))
                result_file.write("\n")

            result_file.write("\n")

            for query in queries:
                _,_, clean_query = parse_clear_and_parametrized_sql(query.get_costs_off_explain())
                result_file.write(cleandoc(self.add_semicolon(clean_query)))
                result_file.write(self.wrap_query_plan(query.cost_off_explain.full_str))

            result_file.write("\n")

            for model_query in teardown_queries:
                result_file.write(self.add_semicolon(model_query))
                result_file.write("\n")