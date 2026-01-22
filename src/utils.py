import difflib
import hashlib
import json
import re
import time
import traceback
import pglast
from copy import copy

import psycopg2
from psycopg2._psycopg import cursor

from config import Config
from db.database import Database
from objects import Query, FieldInTableHelper

PARAMETER_VARIABLE = r"[^'](\%\((.*?)\))"
WITH_ORDINALITY = r"[Ww][Ii][Tt][Hh]\s*[Oo][Rr][Dd][Ii][Nn][Aa][Ll][Ii][Tt][yY]\s*[Aa][Ss]\s*.*(.*)"


def current_milli_time():
    return (time.time_ns() // 1_000) / 1_000


def remove_with_ordinality(sql_str):
    while True:
        match = re.search(WITH_ORDINALITY, sql_str)
        if not match:
            break

        start, end = match.span(0)
        sql_str = (sql_str[:start] if start > 0 else "") + (
            sql_str[end:] if end < len(sql_str) else "")

    return sql_str


def get_result_for_consistency_check_streaming(connection, query_sql: str, is_dml: bool,
                                                has_order_by: bool, has_limit: bool):
    """Fetch results for consistency check using server-side cursor for true streaming.

    Uses config.max_rows_for_hash to limit rows included in hash calculation.
    Server-side cursor ensures we don't load entire result set into memory.

    Returns: (cardinality, result_string, parameters)
    """
    config = Config()
    max_rows = config.max_rows_for_hash or 10000

    if is_dml:
        # For DML, use regular cursor
        with connection.cursor() as cur:
            cur.execute(query_sql)
            return cur.rowcount, f"{cur.rowcount} updates", None

    # if there is a limit without order by we can't validate results
    if has_limit and not has_order_by:
        # Still need to execute to consume/skip
        with connection.cursor(name='consistency_skip_cursor') as server_cur:
            server_cur.execute(query_sql)
            # Don't fetch anything, just close
        return 0, "LIMIT_WITHOUT_ORDER_BY", None

    str_result = []
    cardinality = 0
    warned = False

    # Use server-side cursor (named cursor) for true streaming
    # This prevents psycopg2 from loading all results into memory
    with connection.cursor(name='consistency_check_cursor') as server_cur:
        server_cur.itersize = 1000  # Fetch 1000 rows at a time from server
        server_cur.execute(query_sql)

        for row in server_cur:
            cardinality += 1
            # Only include first N rows in hash to limit memory
            if cardinality <= max_rows:
                for column_value in row:
                    str_result.append(f"{str(column_value)}")
            elif not warned:
                config.logger.warning(
                    f"Result set exceeds max-rows-for-hash ({max_rows}). "
                    f"Streaming remaining rows without hashing.")
                warned = True

    if not has_order_by and cardinality <= max_rows:
        # Only sort if we have all results (sorting partial results is meaningless)
        str_result.sort()

    # Include cardinality in hash so different-sized results don't collide
    if cardinality > max_rows:
        str_result.append(f"__cardinality__{cardinality}")

    return cardinality, ''.join(str_result), None


def get_result_for_consistency_check(cur, is_dml: bool, has_order_by: bool, has_limit: bool):
    """Legacy function - fetches from existing cursor (may cause OOM on large results)."""
    config = Config()
    max_rows = config.max_rows_for_hash or 10000

    if is_dml:
        return cur.rowcount, f"{cur.rowcount} updates"

    if has_limit and not has_order_by:
        _discard_cursor_results(cur)
        return 0, "LIMIT_WITHOUT_ORDER_BY"

    str_result = []
    cardinality = 0
    warned = False

    while True:
        rows = cur.fetchmany(1000)
        if not rows:
            break

        for row in rows:
            cardinality += 1
            if cardinality <= max_rows:
                for column_value in row:
                    str_result.append(f"{str(column_value)}")
            elif not warned:
                config.logger.warning(
                    f"Result set exceeds max-rows-for-hash ({max_rows}). "
                    f"Using partial hash for consistency check.")
                warned = True

    if not has_order_by:
        str_result.sort()

    if cardinality > max_rows:
        str_result.append(f"__cardinality__{cardinality}")

    return cardinality, ''.join(str_result)


def get_result(cur, is_dml: bool, is_explain: bool = False):
    """Fetch query results.

    Args:
        is_explain: If True, returns raw plan text without building string list.

    Note: This function consumes results from an already-executed cursor.
    For client-side cursors (default), all data is already in memory from execute().
    For true streaming, use get_result_streaming() with a server-side cursor.
    """
    if is_dml:
        return cur.rowcount, f"{cur.rowcount} updates"

    if is_explain:
        # For EXPLAIN queries, just get the plan text (small result set)
        rows = cur.fetchall()
        plan_text = '\n'.join(str(row[0]) for row in rows)
        return len(rows), plan_text

    # For regular queries, consume results
    # Note: With client-side cursor, data is already in memory from execute()
    # We just need to count and optionally discard
    cardinality = 0

    while True:
        rows = cur.fetchmany(1000)
        if not rows:
            break
        cardinality += len(rows)

    # Don't build str_result - we don't need it for timing, saves memory
    return cardinality, f"rows={cardinality}"


def get_result_streaming(connection, query_sql: str, is_dml: bool):
    """Fetch query results using server-side cursor for true streaming.

    Use this when you need to fully execute and fetch a large result set
    without loading everything into memory.
    """
    if is_dml:
        with connection.cursor() as cur:
            cur.execute(query_sql)
            return cur.rowcount, f"{cur.rowcount} updates"

    cardinality = 0

    with connection.cursor(name='result_streaming_cursor') as server_cur:
        server_cur.itersize = 2000
        server_cur.execute(query_sql)

        for _ in server_cur:
            cardinality += 1

    return cardinality, f"rows={cardinality}"


def _discard_cursor_results(cur):
    """Consume and discard cursor results to free server resources."""
    while cur.fetchmany(1000):
        pass


def calculate_avg_execution_time(cur,
                                 query: Query,
                                 sut_database: Database,
                                 query_str: str = None,
                                 num_retries: int = 0,
                                 connection=None) -> object:
    config = Config()

    query_str = query_str or query.get_query()
    query_str_lower = query_str.lower() if query_str is not None else None

    has_order_by = query.has_order_by
    has_limit = True if " limit " in query_str_lower else False

    with_analyze = query_with_analyze(query_str_lower)
    is_dml = query_is_dml(query_str_lower)

    execution_times = []
    actual_evaluations = 0

    # run at least one iteration
    num_retries = max(num_retries, 2)
    num_warmup = config.num_warmup
    execution_plan_collected = False
    stats_reset = False

    for iteration in range(num_retries + num_warmup):
        # noinspection PyUnresolvedReferences
        try:
            if config.yugabyte_collect_stats and iteration >= num_warmup and not stats_reset:
                sut_database.reset_query_statics(cur)
                stats_reset = True

            sut_database.prepare_query_execution(cur, query)

            if iteration == 0:
                # evaluate test query without analyze and collect result hash
                # using first iteration as a result collecting step
                # Use server-side cursor for streaming to avoid OOM on large results
                # Note: prepare_query_execution already called above, session props are set
                cardinality, result, _ = get_result_for_consistency_check_streaming(
                    connection, query.get_query(), is_dml, has_order_by, has_limit)

                query.result_cardinality = cardinality
                query.result_hash = get_md5(result)
            else:
                if iteration < num_warmup:
                    # Warmup: use streaming for non-EXPLAIN to avoid OOM
                    if with_analyze:
                        query.parameters = evaluate_sql(cur, query_str)
                        _, result = get_result(cur, is_dml, is_explain=True)
                    else:
                        _, result = get_result_streaming(connection, query_str, is_dml)
                else:
                    if not execution_plan_collected:
                        collect_execution_plan(cur, connection, query, sut_database)
                        execution_plan_collected = True

                        # prepare execution again
                        sut_database.prepare_query_execution(cur, query)

                    start_time = current_milli_time()

                    if with_analyze:
                        # EXPLAIN ANALYZE - small result set, use regular cursor
                        evaluate_sql(cur, query_str)
                        config.logger.debug("SQL >> Getting results")
                        _, result = get_result(cur, is_dml, is_explain=True)
                        execution_times.append(extract_execution_time_from_analyze(result))
                    else:
                        # Raw query - use streaming to avoid OOM
                        _, result = get_result_streaming(connection, query_str, is_dml)
                        execution_times.append(current_milli_time() - start_time)
        except psycopg2.errors.QueryCanceled:
            # failed by timeout - it's ok just skip optimization
            query.execution_time_ms = -1
            config.logger.debug(
                f"Skipping optimization due to timeout limitation:\n{query_str}")
            return False
        except psycopg2.errors.DatabaseError as ie:
            # Some serious problem occurred - probably an issue
            query.execution_time_ms = 0
            config.logger.error(f"INTERNAL ERROR {ie}\nSQL query:\n{query_str}")
            traceback.print_exc(limit=None, file=None, chain=True)
            return False
        finally:
            rolled_back_tries = 0
            rolled_back = False
            while rolled_back_tries < 5:
                rolled_back_tries += 1
                try:
                    connection.rollback()
                    rolled_back = True
                    break
                except Exception as e:
                    time.sleep(2)
            if not rolled_back:
                config.logger.error(
                    f"INTERNAL ERROR Failed to rollback transaction after failed query execution:\n{query_str}")

            if iteration >= num_warmup:
                actual_evaluations += 1

    # TODO convert execution_time_ms into a property
    query.execution_time_ms = sum(execution_times) / len(execution_times)

    if config.yugabyte_collect_stats:
        sut_database.collect_query_statistics(cur, query, query_str)

    return True


def find_order_by_in_query(query_str_lower):
    try:
        statement_json = pglast.parser.parse_sql_json(query_str_lower)
        statement_dict = json.loads(statement_json)
        has_order_by = 'sortClause' in list(statement_dict["stmts"][0]['stmt'].values())[0]
    except Exception:
        has_order_by = False

    return has_order_by


def collect_execution_plan(cur,
                           connection,
                           query: Query,
                           sut_database: Database):
    try:
        evaluate_sql(cur, query.get_explain())
        query.execution_plan = sut_database.get_execution_plan(
            '\n'.join(str(item[0]) for item in cur.fetchall())
        )

        connection.rollback()
    except psycopg2.errors.QueryCanceled as e:
        # failed by timeout - it's ok just skip optimization
        Config().logger.debug(f"Getting execution plan failed with {e}")

        query.execution_time_ms = 0
        query.execution_plan = sut_database.get_execution_plan("")


def query_with_analyze(query_str_lower):
    return query_str_lower is not None and \
        "explain" in query_str_lower and \
        ("analyze" in query_str_lower or "analyse" in query_str_lower)


def query_is_dml(query_str_lower):
    return "update" in query_str_lower or \
        "insert" in query_str_lower or \
        "delete" in query_str_lower


def extract_execution_time_from_analyze(result):
    extracted = -1
    matches = re.findall(r"(?<!\s)Execution\sTime:\s(\d+\.\d+)\sms", result, re.MULTILINE)
    if matches:
        return float(matches[0])

    return extracted


def calculate_client_execution_time(query):
    execution_plan = query.execution_plan.full_str
    client_time = query.execution_time_ms

    extracted = -1
    server_time = extract_execution_time_from_analyze(execution_plan)
    if server_time == -1:
        return extracted
    else:
        return server_time - client_time


def extract_actual_cardinality(result):
    matches = re.finditer(r"\(actual\stime.*rows=(\d+).*\)", result.split("\n")[0], re.MULTILINE)
    for matchNum, match in enumerate(matches, start=1):
        result = float(match.groups()[0])
        break

    return result


def get_tables(object, tables_in_sut):
    def _parse_tables(tables, object, tables_in_sut):
        if isinstance(object, list):
            for subfield in object:
                _parse_tables(tables, subfield, tables_in_sut)
        elif isinstance(object, dict):
            for key, value in object.items():
                if key == 'RangeVar':
                    table_name = value['relname']
                    alias = value['alias']['aliasname'] if value.get('alias') else table_name

                    for real_table in tables_in_sut:
                        if table_name == real_table.name:
                            table_copy = real_table.copy()
                            table_copy.alias = alias

                            tables.add(table_copy)

                _parse_tables(tables, value, tables_in_sut)

        return tables

    return _parse_tables(set(), object, tables_in_sut)


def get_fields(object, tables_in_query):
    def _parse_fields(fields, object, tables):
        if isinstance(object, list):
            for subfield in object:
                _parse_fields(fields, subfield, tables)
        elif isinstance(object, dict):
            for key, value in object.items():
                if key == 'ColumnRef':
                    value = value['fields']
                    if len(value) == 2:
                        table = value[0]["String"]["sval"]
                        if 'A_Star' in value[1]:
                            table = [table_object for table_object in tables if table_object.name == table]

                            # todo implement alias to alias
                            if table:
                                table = table[0]

                                for field_in_table in table.fields:
                                    fields.add(FieldInTableHelper(table, field_in_table.name))
                        elif 'String' in value[1]:
                            field = value[1]["String"]["sval"]
                            fields.add(FieldInTableHelper(table, field))
                    else:
                        if value[0].get("String"):
                            fields.add(FieldInTableHelper("UNKNOWN", value[0]["String"]["sval"]))
                        elif 'A_Star' in value[0]:
                            # TODO If star used then add all fields for all tables
                            for table in tables:
                                for table_field in table.fields:
                                    fields.add(FieldInTableHelper(table.name, table_field.name))

                _parse_fields(fields, value, tables)

        return fields

    fields_in_query = set()

    # crunch for select max(c1) from t1
    # search across all known tables and tables in query and add all possible combination
    for field_in_query in _parse_fields(set(), object, tables_in_query):
        if field_in_query.table_name == "UNKNOWN":
            for table_in_query in tables_in_query:
                for field in table_in_query.fields:
                    if field.name == field_in_query.field_name:
                        new_field = field_in_query.copy()
                        new_field.table_name = table_in_query.alias
                        fields_in_query.add(new_field)
        else:
            fields_in_query.add(field_in_query)

    return fields_in_query


def get_alias_table_names(sql_str, tables_in_sut):
    # 'WITH ORDINALITY' clauses get misinterpreted as
    # aliases so remove them from the query.
    sql_str = remove_with_ordinality(sql_str)

    _, _, sql_wo_parameters = parse_clear_and_parametrized_sql(sql_str)

    statement_json = pglast.parser.parse_sql_json(sql_wo_parameters)
    statement_dict = json.loads(statement_json)

    tables_in_query = get_tables(statement_dict, tables_in_sut)
    fields_in_query = get_fields(statement_dict, tables_in_query)

    # return usable table objects list
    table_objects_in_query = []
    for table_in_query in tables_in_query:
        table_copy = table_in_query.copy()

        new_fields = []
        for field_in_table in table_copy.fields:
            new_fields.extend(
                field_in_table
                for field in fields_in_query
                if table_copy.alias == field.table_name
                and field_in_table.name == field.field_name
            )
        table_copy.fields = new_fields

        table_objects_in_query.append(table_copy)

    return table_objects_in_query


def evaluate_sql(cur: cursor, sql: str, force_warning: bool = False, mute_exceptions: bool = False):
    # TODO https://github.com/yugabyte/yugabyte-db/issues/21041
    force_warning = force_warning or ("analyze" in sql.lower() and "explain" not in sql.lower())

    config = Config()

    parameters, sql, sql_wo_parameters = parse_clear_and_parametrized_sql(sql)

    if config.parametrized and parameters:
        try:
            config.logger.debug(f"SQL >> {sql}[{parameters}]")
            cur.execute(sql, parameters)
        except psycopg2.errors.QueryCanceled as e:
            if not mute_exceptions:
                config.logger.debug(f"UNSTABLE: {sql_wo_parameters}", sql)
            cur.connection.rollback()
            raise e
        except psycopg2.errors.DuplicateDatabase as ddb:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql}[{parameters}]", ddb)
        except psycopg2.errors.ConfigurationLimitExceeded as cle:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql}[{parameters}]", cle)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)
        except psycopg2.OperationalError as oe:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql}[{parameters}]", oe)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)
        except Exception as e:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql}[{parameters}]", e)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)

            raise e
    else:
        try:
            config.logger.debug(f"SQL >> {sql_wo_parameters}")
            cur.execute(sql_wo_parameters)
        except psycopg2.errors.QueryCanceled as e:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.debug(f"UNSTABLE: {sql_wo_parameters}", sql_wo_parameters)
            raise e
        except psycopg2.errors.DuplicateDatabase as ddb:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql_wo_parameters}", ddb)
        except psycopg2.errors.ConfigurationLimitExceeded as cle:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql_wo_parameters}", cle)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)
        except psycopg2.OperationalError as oe:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql_wo_parameters}", oe)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)
        except Exception as e:
            cur.connection.rollback()

            if not mute_exceptions:
                config.logger.exception(f"UNSTABLE: {sql_wo_parameters}", e)
            if force_warning:
                config.has_warnings = True
            else:
                config.has_failures = True

            if config.exit_on_fail:
                exit(1)

            raise e

    return parameters


def parse_clear_and_parametrized_sql(sql):
    parameters = []
    sql_wo_parameters = copy(sql)
    str_param_skew = 0
    str_wo_param_skew = 0
    changed_var_name = '%s'

    for match in re.finditer(PARAMETER_VARIABLE, sql, re.MULTILINE):
        var_value = match.groups()[1]

        if var_value.isnumeric():
            correct_value = int(var_value) if var_value.isdigit() else float(var_value)
        else:
            correct_value = var_value.replace("'", "")

        sql = changed_var_name.join(
            [sql[:str_param_skew + match.start(1)],
             sql[str_param_skew + match.end(1):]])
        str_param_skew += len(changed_var_name) - (match.end(1) - match.start(1))

        sql_wo_parameters = var_value.join(
            [sql_wo_parameters[:str_wo_param_skew + match.start(1)],
             sql_wo_parameters[str_wo_param_skew + match.end(1):]])
        str_wo_param_skew += len(var_value) - (match.end(1) - match.start(1))

        parameters.append(correct_value)

    return parameters, sql, sql_wo_parameters


def allowed_diff(config, original_execution_time, optimization_execution_time):
    if optimization_execution_time <= 0:
        return False

    return (abs(original_execution_time - optimization_execution_time) /
            optimization_execution_time) < config.skip_percentage_delta


def get_md5(string: str):
    return hashlib.md5(string.encode('utf-8')).hexdigest()


def get_bool_from_object(string: str | bool | int):
    return string in {True, 1, "True", "true", "TRUE", "T"}


def get_model_path(model):
    if model.startswith("/") or model.startswith("."):
        return model
    else:
        return f"sql/{model}"


def disabled_path(query):
    return query.execution_plan.get_estimated_cost() < 10000000000


def get_plan_diff(baseline, changed):
    return "\n".join(
        text for text in difflib.unified_diff(baseline.split("\n"), changed.split("\n")) if
        text[:3] not in ('+++', '---', '@@ '))


def seconds_to_readable_minutes(seconds):
    minutes = seconds // 60
    remaining_seconds = seconds % 60
    return f"{minutes} minute{'s' if minutes != 1 else ''} and {remaining_seconds:.2f} second{'s' if remaining_seconds != 1 else ''}"
