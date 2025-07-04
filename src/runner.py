import argparse
from os.path import exists

from pyhocon import ConfigFactory

from actions.reports.score_stats import ScoreStatsReport
from config import Config, init_logger, ConnectionConfig, DDLStep
from db.factory import create_database
from db.postgres import DEFAULT_USERNAME, DEFAULT_PASSWORD, PostgresResultsLoader
from actions.reports.cost import CostReport
from actions.reports.regression import RegressionReport
from actions.reports.score import ScoreReport
from actions.reports.selectivity import SelectivityReport
from actions.reports.taqo import TaqoReport
from actions.collect import CollectAction

from utils import get_bool_from_object, get_model_path


def parse_ddls(ddl_ops: str):
    result = set()

    if ddl_ops == "none":
        return result

    ddl_ops = ddl_ops.lower()
    for e in DDLStep:
        if str(e.name).lower() in ddl_ops:
            result.add(e)

    return result


def parse_model_config(model):
    path_to_file = f"{get_model_path(model)}/model.conf"

    if exists(path_to_file):
        parsed_model_config = ConfigFactory.parse_file(path_to_file)
        global_option_index = get_bool_from_object(configuration.get("all-index-check", True))
        global_option_timeout = configuration.get("test-query-timeout", 1200)
        global_compaction_timeout = configuration.get("compaction-timeout", 120)
        global_option_bitmap = configuration.get("bitmap-enabled", False)

        configuration['all-index-check'] = global_option_index and parsed_model_config.get("all-index-check", True)
        configuration['load-catalog-tables'] = parsed_model_config.get("load-catalog-tables", False)
        configuration['test-query-timeout'] = parsed_model_config.get("test-query-timeout", global_option_timeout)
        configuration['compaction-timeout'] = parsed_model_config.get("compaction-timeout", global_compaction_timeout)
        configuration['bitmap-enabled'] = parsed_model_config.get("bitmap-enabled", global_option_bitmap)


def define_database_name(args):
    if args.database:
        return args.database
    else:
        if args.colocated:
            return f"taqo_{model.replace('-', '_')}"
        else:
            return f"taqo_{model.replace('-', '_')}_non_colocated"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Query Optimizer Testing framework for PostgreSQL compatible DBs')

    parser.add_argument('action',
                        help='Action to perform - collect or report')
    parser.add_argument('--options',
                        help='Options to overwrite configuration file properties',
                        nargs='+', type=str)

    parser.add_argument('--db',
                        default="yugabyte",
                        help='Database to run against')

    parser.add_argument('--baseline',
                        default="",
                        help='Link to baseline run results (JSON)')
    parser.add_argument('--config',
                        default="config/default.conf",
                        help='Configuration file path')
    parser.add_argument('-p', '--yugabyte-bin-path',
                        default="",
                        help='Path to Yugabyte distrib binary files')
    parser.add_argument('-m', '--yugabyte-master-addresses',
                        default="",
                        help='List of Yugabyte master nodes to use yb-admin command')
    parser.add_argument('--yugabyte-stats',
                        action=argparse.BooleanOptionalAction,
                        default=True,
                        help='Do collect stats from pg_stat_statements_reset')

    parser.add_argument('--type',
                        help='Report type - taqo, score, regression, comparison, selectivity or cost')

    # report mode flags

    # TAQO, Score, Comparison or Cost (--pg-results optional for TAQO, N/A for Cost)
    parser.add_argument('--results',
                        default=None,
                        help='TAQO/Comparison: Path to results with optimizations for YB')
    parser.add_argument('--pg-results',
                        default=None,
                        help='TAQO/Comparison: Path to results for PG, optimizations are optional')
    parser.add_argument('--pg-server-results',
                        default='',
                        help='TAQO/Comparison: Path to results for PG server side, optimizations are optional')

    # Regression
    parser.add_argument('--v1-results',
                        default=None,
                        help='Regression: Results for first version')
    parser.add_argument('--v2-results',
                        help='Regression: Results for second version')
    parser.add_argument('--v1-name',
                        default='First',
                        help='Regression: First version reporting name')
    parser.add_argument('--v2-name',
                        default='Second',
                        help='Regression: Second version reporting name')

    # Selectivity
    parser.add_argument('--default-results',
                        default=None,
                        help='Results for no optimizer tuned DB')
    parser.add_argument('--default-analyze-results',
                        default=None,
                        help='Results for no optimizer tuned DB with EXPLAIN ANALYZE')
    parser.add_argument('--ta-results',
                        default=None,
                        help='Results with table analyze')
    parser.add_argument('--ta-analyze-results',
                        default=None,
                        help='Results with table analyze with EXPLAIN ANALYZE')
    parser.add_argument('--stats-results',
                        default=None,
                        help='Results with table analyze and enabled statistics')
    parser.add_argument('--stats-analyze-results',
                        default=None,
                        help='Results with table analyze and enabled statistics and EXPLAIN ANALYZE')

    # Cost
    parser.add_argument('--interactive',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Popup an interactive chart then quit (no boxplot chart support)')

    # collect mode flags

    parser.add_argument('--ddl-prefix',
                        default="",
                        help='DDL file prefix (default empty, might be postgres)')

    parser.add_argument('--user-optimization-guc',
                        default="",
                        help='Additional user defined queries to multiply optimizations number. (E.g. tune parallel)')
    parser.add_argument('--remote-data-path',
                        default=None,
                        help='Path to remote data files ($DATA_PATH/*.csv)')

    parser.add_argument('--plans-only',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Collect only execution plans, execution time will be equal to cost')
    parser.add_argument('--bitmap-enabled',
                        action=argparse.BooleanOptionalAction,
                        default=None,
                        help='Enable bitmap scan for PG and YB databases')
    parser.add_argument('--optimizations',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Evaluate optimizations for each query')
    parser.add_argument('--model',
                        default="simple",
                        help='Test model to use - complex, tpch, subqueries, any other custom model')

    parser.add_argument('--basic-multiplier',
                        default=10,
                        help='Basic model data multiplier (Default 10)')
    parser.add_argument('--source-path',
                        help='Path to yugabyte-db source code')
    parser.add_argument('--revision',
                        help='Git revision or path to release build')
    parser.add_argument('--ddls',
                        default="database,create,analyze,import,compact,drop",
                        help='Model creation queries, comma separated: database,create,analyze,import,compact,drop')

    parser.add_argument('--clean-db',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Keep database after test')
    parser.add_argument('--colocated',
                        action=argparse.BooleanOptionalAction,
                        default=True,
                        help='Do create database with compaction flag (Yugabyte only, default true)')
    parser.add_argument('--allow-destroy-db',
                        action=argparse.BooleanOptionalAction,
                        default=True,
                        help='Allow to run yb-ctl/yugabyted destory')
    parser.add_argument('--clean-build',
                        action=argparse.BooleanOptionalAction,
                        default=True,
                        help='Build yb_build with --clean-force flag')

    parser.add_argument('--num-nodes',
                        default=0,
                        help='Number of nodes')

    parser.add_argument('--tserver-flags',
                        default=None,
                        help='Comma separated tserver flags')
    parser.add_argument('--master-flags',
                        default=None,
                        help='Comma separated master flags')

    parser.add_argument('--host',
                        default="127.0.0.1",
                        help='Target host IP for postgres compatible database')
    parser.add_argument('--port',
                        default=5433,
                        help='Target port for postgres compatible database')
    parser.add_argument('--username',
                        default=DEFAULT_USERNAME,
                        help='Username for connection')
    parser.add_argument('--password',
                        default=DEFAULT_PASSWORD,
                        help='Password for user for connection')
    parser.add_argument('--database',
                        help='Target database in postgres compatible database')

    parser.add_argument('--explain-clause',
                        default=None,
                        help='Explain clause that will be placed before query. Default "EXPLAIN"')
    parser.add_argument('--server-side-execution',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Evaluate queries on server side, for PG using "EXPLAIN ANALYZE"')
    parser.add_argument('--session-props',
                        default="",
                        help='Additional session properties queries')
    parser.add_argument('--num-queries',
                        default=-1,
                        help='Number of queries to evaluate')
    parser.add_argument('--parametrized',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Run parametrized query instead of normal')

    parser.add_argument('--output',
                        help='Output JSON file name in report folder, [.json] will be added')

    # collect/report mode common flags

    parser.add_argument('--clear',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Clear logs directory')
    parser.add_argument('--exit-on-fail',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Exit on query failures (DDL failure is not configurable)')

    parser.add_argument('--yes',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Confirm test start')
    parser.add_argument('--verbose',
                        action=argparse.BooleanOptionalAction,
                        default=False,
                        help='Enable DEBUG logging')

    args = parser.parse_args()

    configuration = ConfigFactory.parse_file(args.config)
    ddls = parse_ddls(args.ddls)
    model = args.model

    parse_model_config(model)

    options_config = {}
    if args.options:
        for option in args.options:
            key, value = option.split('=', 1)
            if value.startswith('int:'):
                value = int(value.replace('int:', ''))
            elif value.startswith('bool:'):
                """
                --to key1=bool:True
                """
                value = value.replace('bool:', '').lower() == 'true'

            options_config[key] = value

    configuration = configuration | options_config
    loader = PostgresResultsLoader()

    user_optimization_guc = []
    if args.user_optimization_guc:
        for guc in args.user_optimization_guc.split(":"):
            optimization_guc = ""
            if 'set' not in guc:
                optimization_guc += f"set {guc};"
            else:
                optimization_guc += f"{guc};"
            user_optimization_guc.append(optimization_guc)

    config = Config(
        logger=init_logger("DEBUG" if args.verbose else "INFO"),
        exit_on_fail=args.exit_on_fail,

        source_path=args.source_path or configuration.get("source-path", None),
        num_nodes=int(args.num_nodes) or configuration.get("num-nodes", 3),

        revision=args.revision or None,
        tserver_flags=args.tserver_flags,
        master_flags=args.master_flags,
        clean_db=args.clean_db,
        allow_destroy_db=args.allow_destroy_db,
        clean_build=args.clean_build,
        colocated_database=args.colocated,
        bitmap_enabled=configuration.get("bitmap-enabled", False) if args.bitmap_enabled is None else args.bitmap_enabled,
        yugabyte_bin_path=args.yugabyte_bin_path or configuration.get("yugabyte-bin-path", None),
        yugabyte_master_addresses=args.yugabyte_master_addresses if args.yugabyte_master_addresses else args.host,
        yugabyte_collect_stats=args.yugabyte_stats,

        connection=ConnectionConfig(host=args.host,
                                    port=args.port,
                                    username=args.username,
                                    password=args.password,
                                    database=define_database_name(args)),

        model=model,
        all_index_check=configuration.get("all-index-check", True),
        load_catalog_tables=configuration.get("load-catalog-tables", False),
        baseline_path=args.baseline,
        baseline_results=loader.get_queries_from_previous_result(args.baseline) if args.baseline else None,
        output=args.output,
        ddls=ddls,
        remote_data_path=args.remote_data_path,
        user_optimization_guc=user_optimization_guc,
        ddl_prefix=args.ddl_prefix or (args.db if args.db != "yugabyte" else ""),
        with_optimizations=args.optimizations,
        plans_only=args.plans_only,
        server_side_execution=get_bool_from_object(args.server_side_execution),

        explain_clause=args.explain_clause or configuration.get("explain-clause", "EXPLAIN"),
        session_props=configuration.get("session-props") +
                      (args.session_props.split(",") if args.session_props else []),
        basic_multiplier=int(args.basic_multiplier),

        skip_percentage_delta=float(configuration.get("skip-percentage-delta", 0.05)),
        skip_timeout_delta=int(configuration.get("skip-timeout-delta", 1)),
        ddl_query_timeout=int(configuration.get("ddl-query-timeout", 3600)),
        test_query_timeout=int(configuration.get("test-query-timeout", 1200)),
        compaction_timeout=int(configuration.get("compaction-timeout", 120)),
        look_near_best_plan=get_bool_from_object(configuration.get("look-near-best-plan", True)),
        all_pairs_threshold=int(configuration.get("all-pairs-threshold", 3)),

        num_queries=int(args.num_queries)
        if int(args.num_queries) > 0 else configuration.get("num-queries", -1),
        num_retries=int(configuration.get("num-retries", 5)),
        num_warmup=int(configuration.get("num-warmup", 1)),

        parametrized=get_bool_from_object(args.parametrized),

        asciidoctor_path=configuration.get("asciidoctor-path", "asciidoc"),

        clear=args.clear)

    config.database = create_database(args.db, config)

    config.logger.info("------------------------------------------------------------")
    config.logger.info("Query Optimizer Testing Framework for Postgres compatible DBs")

    if args.action == "collect":
        config.logger.info("")
        config.logger.info(f"Collecting results for model: {config.model}")
        config.logger.info("Configuration:")
        config.logger.info(str(config))
        config.logger.info("------------------------------------------------------------")

        if args.output is None:
            print("ARGUMENTS VALIDATION ERROR: --output arg is required for collect task")
            exit(1)

        if not args.yes:
            input("Validate configuration carefully and press Enter...")

        config.logger.info("Evaluating scenario")
        CollectAction().evaluate()
    elif args.action == "report":
        config.logger.info("")
        config.logger.info(f"Generation {args.type} report")
        config.logger.info(
            f"Allowed execution time percentage deviation: {config.skip_percentage_delta * 100}%")
        config.logger.info("------------------------------------------------------------")

        if args.type == "taqo":
            yb_queries = loader.get_queries_from_previous_result(args.results)
            pg_queries = loader.get_queries_from_previous_result(
                args.pg_results) if args.pg_results else None

            TaqoReport.generate_report(yb_queries, pg_queries)
        elif args.type == "score":
            yb_queries = loader.get_queries_from_previous_result(args.results)
            pg_queries = loader.get_queries_from_previous_result(
                args.pg_results) if args.pg_results else None
            pg_server_results = loader.get_queries_from_previous_result(
                args.pg_server_results) if args.pg_server_results else None

            ScoreReport.generate_report(config.logger, yb_queries, pg_queries, pg_server_results)
        elif args.type == "score_stats":
            yb_queries = loader.get_queries_from_previous_result(args.results)
            pg_queries = loader.get_queries_from_previous_result(
                args.pg_results) if args.pg_results else None
            pg_server_results = loader.get_queries_from_previous_result(
                args.pg_server_results) if args.pg_server_results else None

            ScoreStatsReport.generate_report(config.logger, yb_queries, pg_queries, pg_server_results)
        elif args.type == "regression":
            v1_queries = loader.get_queries_from_previous_result(args.v1_results)
            v2_queries = loader.get_queries_from_previous_result(args.v2_results)

            RegressionReport.generate_report(args.v1_name, args.v2_name, v1_queries, v2_queries)
        elif args.type == "selectivity":
            default_queries = loader.get_queries_from_previous_result(args.default_results)
            default_analyze_queries = loader.get_queries_from_previous_result(
                args.default_analyze_results)
            ta_queries = loader.get_queries_from_previous_result(args.ta_results)
            ta_analyze_queries = loader.get_queries_from_previous_result(args.ta_analyze_results)
            stats_queries = loader.get_queries_from_previous_result(args.stats_results)
            stats_analyze_queries = loader.get_queries_from_previous_result(
                args.stats_analyze_results)

            SelectivityReport.generate_report(default_queries, default_analyze_queries, ta_queries,
                                              ta_analyze_queries, stats_queries, stats_analyze_queries)
        elif args.type == "cost":
            yb_queries = loader.get_queries_from_previous_result(args.results)
            CostReport.generate_report(yb_queries, args.interactive)
        else:
            raise AttributeError(f"Unknown report type defined {args.type}")

    if config.has_failures:
        config.logger.exception("Found issues during TAQO collect execution")
        exit(1)
    if config.has_warnings:
        exit(2)
