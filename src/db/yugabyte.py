import os
import re
import shutil
import subprocess
from time import sleep
from typing import List

import requests
from psycopg2._psycopg import cursor

from collect import CollectResult, ResultsLoader
from config import ConnectionConfig, DDLStep
from db.postgres import Postgres, PostgresExecutionPlan, PLAN_TREE_CLEANUP, PostgresQuery
from objects import ExecutionPlan, QueryStats, Query
from utils import evaluate_sql, seconds_to_readable_minutes

DEFAULT_USERNAME = 'yugabyte'
DEFAULT_PASSWORD = 'yugabyte'

JDBC_STRING_PARSE = r'\/\/(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)):(\d+)\/([a-z]+)(\?user=([a-z]+)&password=([a-z]+))?'

PLAN_CLEANUP_REGEX = r"\s\(actual time.*\)|\s\(never executed\)|\s\(cost.*\)|" \
                     r"\sMemory:.*|Planning Time.*|Execution Time.*|Peak Memory Usage.*|" \
                     r"Storage Read Requests:.*|Storage Read Execution Time:.*|Storage Write Requests:.*|" \
                     r"Catalog Reads Requests:.*|Catalog Reads Execution Time:.*|Catalog Writes Requests:.*|" \
                     r"Storage Flushes Requests:.*|Storage Execution Time:.*|" \
                     r"Storage Table Read Requests:.*|Storage Table Read Execution Time:.*|Output:.*|" \
                     r"Storage Index Read Requests:.*|Storage Index Read Execution Time:.*|" \
                     r"Metric rocksdb_.*:.*|" \
                     r"Read RPC Count:.*|Read RPC Wait Time:.*|DocDB Scanned Rows:.*|" \
                     r".*Partial Aggregate:.*|YB\s|Remote\s|" \
                     r"JIT:.*|\s+Functions:.*|\s+Options:.*|\s+Timing:.*"
PLAN_RPC_CALLS = r"\nRead RPC Count:\s(\d+)"
PLAN_RPC_WAIT_TIMES = r"\nRead RPC Wait Time:\s([+-]?([0-9]*[.])?[0-9]+)"
PLAN_DOCDB_SCANNED_ROWS = r"\nDocDB Scanned Rows:\s(\d+)"
PLAN_PEAK_MEMORY = r"\nPeak memory:\s(\d+)"

VERSION = r"version\s((\d+\.\d+\.\d+\.\d+)\s+build\s+(\d+)\s+revision\s+([0-9a-z]+))"


def yb_db_factory(config):
    if not config.revision:
        return Yugabyte(config)
    elif 'tar' in config.revision:
        return YugabyteLocalCluster(config)
    else:
        return YugabyteLocalRepository(config)


class Yugabyte(Postgres):
    def run_compaction(self, tables: list[str]):
        tables_to_optimize = [tables[0], ] if self.config.colocated_database else tables

        self.logger.info(f"Evaluating flush on tables {[table.name for table in tables_to_optimize]}")
        for table in tables_to_optimize:
            subprocess.call(f'./yb-admin -init_master_addrs {self.config.connection.host}:7100 '
                            f'flush_table ysql.{self.config.connection.database} {table.name}',
                            shell=True,
                            cwd=self.config.yugabyte_bin_path)

        # Flush sys catalog tables
        subprocess.call(f'./yb-admin -init_master_addrs {self.config.connection.host}:7100 '
                        f'flush_sys_catalog',
                        shell=True,
                        cwd=self.config.yugabyte_bin_path)

        self.logger.info("Waiting for 2 minutes to operations to complete")
        sleep(self.config.compaction_timeout)

        self.logger.info(f"Evaluating compaction on system tables")
        # Compact sys catalog tables
        subprocess.call(f'./yb-admin -init_master_addrs {self.config.connection.host}:7100 '
                        f'compact_sys_catalog',
                        shell=True,
                        cwd=self.config.yugabyte_bin_path)

        self.logger.info(f"Evaluating compaction on tables {[table.name for table in tables_to_optimize]}")
        for table in tables_to_optimize:
            retries = 1
            while retries < 5:
                try:
                    result = subprocess.check_output(
                        f'./yb-admin -init_master_addrs {self.config.connection.host}:7100 '
                        f'compact_table ysql.{self.config.connection.database} {table.name}',
                        shell=True,
                        cwd=self.config.yugabyte_bin_path)
                    self.logger.info(result)
                    break
                except Exception as e:
                    retries += 1

                    self.logger.info(f"Waiting for {seconds_to_readable_minutes(self.config.compaction_timeout)} "
                                     f"minutes to operations to complete for {table.name}")
                    sleep(self.config.compaction_timeout)

    def establish_connection_from_output(self, out: str):
        self.logger.info("Reinitializing connection based on cluster creation output")
        parsing = re.findall(JDBC_STRING_PARSE, out)[0]

        self.config.connection = ConnectionConfig(host=parsing[0], port=parsing[4],
                                                  username=parsing[7] or DEFAULT_USERNAME,
                                                  password=parsing[8] or DEFAULT_PASSWORD,
                                                  database=self.config.connection.database or
                                                           parsing[5], )

        self.logger.info(f"Connection - {self.config.connection}")

    def create_test_database(self):
        if DDLStep.DATABASE in self.config.ddls:
            self.establish_connection("postgres")
            conn = self.connection.conn
            try:
                with conn.cursor() as cur:
                    colocated = " WITH COLOCATED = true" if self.config.colocated_database else ""
                    evaluate_sql(cur, f'CREATE DATABASE {self.config.connection.database}{colocated};')
            except Exception as e:
                self.logger.exception(f"Failed to create testing database {e}")

    def prepare_query_execution(self, cur, query_object):
        super().prepare_query_execution(cur, query_object)

    def change_version_and_compile(self, revision_or_path=None):
        pass

    def destroy(self):
        pass

    def start_database(self):
        pass

    def stop_database(self):
        pass

    def call_upgrade_ysql(self):
        pass

    def get_execution_plan(self, execution_plan: str):
        return YugabyteExecutionPlan(execution_plan)

    def reset_query_statics(self, cur: cursor):
        evaluate_sql(cur, "SELECT pg_stat_statements_reset()")

    def get_revision_version(self, cur: cursor):
        model_result = ""
        try:
            model_result = re.findall(VERSION,
                                      requests.get(f'http://{self.config.connection.host}:7000/tablet-servers').text,
                                      re.MULTILINE)

            if model_result:
                version = f"{model_result[0][1]}-b{model_result[0][2]}"
                revision = model_result[0][3]

                return revision, version
        except Exception:
            self.logger.error(model_result)

        return 'UNKNOWN', 'UNKNOWN'

    def get_flags(self, port, prefix):
        response = requests.get(f'http://{self.config.connection.host}:{port}/varz?raw')

        if response.status_code == 200:
            lines = response.text.splitlines()

            processed_lines = []
            for line in lines:
                if '--' in line:
                    line = line.replace('Command-line Flags', '')
                    line = line.replace('--', f'{prefix}=', 1)
                    processed_lines.append(line)

            processed_lines.sort()

            return processed_lines

    def get_database_config(self, cur: cursor):
        try:
            return '\n'.join(self.get_flags(7000, 'MASTER') + self.get_flags(9000, 'TSERVER'))
        except Exception as e:
            self.logger.error(e)

        return ''

    def collect_query_statistics(self, cur: cursor, query: Query, query_str: str):
        try:
            tuned_query = query_str.replace("'", "''")
            evaluate_sql(cur,
                         "select query, calls, total_time, min_time, max_time, mean_time, rows, yb_latency_histogram "
                         f"from pg_stat_statements where query like '%{tuned_query}%';",
                         force_warning=True,
                         mute_exceptions=True)
            result = cur.fetchall()

            query.query_stats = QueryStats(
                calls=result[0][1],
                total_time=result[0][2],
                min_time=result[0][3],
                max_time=result[0][4],
                mean_time=result[0][5],
                rows=result[0][6],
                latency=result[0][7],
            )
        except Exception:
            # TODO do nothing
            pass


class YugabyteQuery(PostgresQuery):
    execution_plan: 'YugabyteExecutionPlan' = None


class YugabyteExecutionPlan(PostgresExecutionPlan):
    def get_rpc_calls(self, execution_plan: 'ExecutionPlan' = None):
        try:
            return int(re.sub(
                PLAN_RPC_CALLS, '',
                execution_plan.full_str if execution_plan else self.full_str).strip())
        except Exception:
            return 0

    def get_rpc_wait_times(self, execution_plan: 'ExecutionPlan' = None):
        try:
            return int(
                re.sub(PLAN_RPC_WAIT_TIMES, '',
                       execution_plan.full_str if execution_plan else self.full_str).strip())
        except Exception:
            return 0

    def get_scanned_rows(self, execution_plan: 'ExecutionPlan' = None):
        try:
            return int(
                re.sub(PLAN_DOCDB_SCANNED_ROWS, '',
                       execution_plan.full_str if execution_plan else self.full_str).strip())
        except Exception:
            return 0

    def get_peak_memory(self, execution_plan: 'ExecutionPlan' = None):
        try:
            return int(
                re.sub(PLAN_PEAK_MEMORY, '',
                       execution_plan.full_str if execution_plan else self.full_str).strip())
        except Exception:
            return 0

    def get_no_tree_plan_str(self, plan_str):
        return re.sub(PLAN_TREE_CLEANUP, '\n', plan_str).strip()

    def get_clean_plan(self, execution_plan: 'ExecutionPlan' = None):
        no_tree_plan = re.sub(PLAN_TREE_CLEANUP, '\n',
                              execution_plan.full_str if execution_plan else self.full_str).strip()
        return re.sub(PLAN_CLEANUP_REGEX, '', no_tree_plan).strip()


class YugabyteLocalCluster(Yugabyte):
    def __init__(self, config):
        super().__init__(config)
        self.path = None

    def unpack_release(self, path):
        if not path:
            raise AttributeError("Can't pass empty path into unpack_release method")

        self.logger.info(f"Cleaning /tmp/taqo directory and unpacking {path}")
        shutil.rmtree('/tmp/taqo', ignore_errors=True)
        os.mkdir('/tmp/taqo')
        subprocess.call(['tar', '-xf', path, '-C', '/tmp/taqo'])

        self.path = '/tmp/taqo/' + list(os.walk('/tmp/taqo'))[0][1][0]

    def start_database(self):
        self.logger.info(f"Starting Yugabyte cluster with {self.config.num_nodes} nodes")

        launch_cmds = [
            'python3',
            'bin/yb-ctl',
            '--replication_factor',
            str(self.config.num_nodes),
            'create'
        ]

        if self.config.tserver_flags:
            launch_cmds.append(f'--tserver_flags={self.config.tserver_flags}')

        if self.config.master_flags:
            launch_cmds.append(f'--master_flags={self.config.master_flags}')

        out = subprocess.check_output(launch_cmds,
                                      stderr=subprocess.PIPE,
                                      cwd=self.path, )

        if 'For more info, please use: yb-ctl status' not in str(out):
            self.logger.error(f"Failed to start Yugabyte cluster\n{str(out)}")
            exit(1)

        self.establish_connection_from_output(str(out))

        self.logger.info("Waiting for 15 seconds for connection availability")
        sleep(15)

    def destroy(self):
        if self.config.allow_destroy_db:
            self.logger.info("Destroying existing Yugabyte var/ directory")

            out = subprocess.check_output(['python3', 'bin/yb-ctl', 'destroy'],
                                          stderr=subprocess.PIPE,
                                          cwd=self.path, )

            if 'error' in str(out.lower()):
                self.logger.error(f"Failed to destroy Yugabyte\n{str(out.lower())}")

    def stop_database(self):
        self.logger.info("Stopping Yugabyte node if exists")
        out = subprocess.check_output(['python3', 'bin/yb-ctl', 'stop'],
                                      stderr=subprocess.PIPE,
                                      cwd=self.path, )

        if 'error' in str(out.lower()):
            self.logger.error(f"Failed to stop Yugabyte\n{str(out.lower())}")

    def change_version_and_compile(self, revision_or_path=None):
        self.unpack_release(revision_or_path)

    def call_upgrade_ysql(self):
        self.logger.info("Calling upgrade_ysql and trying to upgrade metadata")

        out = subprocess.check_output(
            ['bin/yb-admin', 'upgrade_ysql', '-master_addresses', f"{self.config.yugabyte_master_addresses}:7100"],
            stderr=subprocess.PIPE,
            cwd=self.path, )

        if 'error' in str(out.lower()):
            self.logger.error(f"Failed to upgrade YSQL\n{str(out)}")


class YugabyteLocalRepository(Yugabyte):
    def __init__(self, config):
        super().__init__(config)

        self.path = self.config.source_path

    def change_version_and_compile(self, revision_or_path=None):
        if revision_or_path:
            self.logger.info(f"Checkout revision '{revision_or_path}' for yugabyte repository")
            try:
                subprocess.check_output(['git', 'fetch'],
                                        stderr=subprocess.STDOUT,
                                        cwd=self.path,
                                        universal_newlines=True)
            except subprocess.CalledProcessError as exc:
                self.logger.error(f"Failed to fetch \n{exc.returncode}, {exc.output}")

            try:
                subprocess.check_output(['git', 'checkout', revision_or_path],
                                        stderr=subprocess.STDOUT,
                                        cwd=self.path,
                                        universal_newlines=True)
            except subprocess.CalledProcessError as exc:
                self.logger.error(
                    f"Failed to checkout revision '{revision_or_path}'\n{exc.returncode}, {exc.output}")

        self.logger.info(f"Building yugabyte from source code '{self.path}'")
        subprocess.call(['./yb_build.sh',
                         'release',
                         '--clean-force' if self.config.clean_build else '',
                         '--build-yugabyted-ui',
                         '--no-tests',
                         '--skip-java-build'],
                        stdout=subprocess.STDOUT,
                        stderr=subprocess.STDOUT,
                        cwd=self.path)

    def call_upgrade_ysql(self):
        pass

    def destroy(self):
        if self.config.allow_destroy_db:
            self.logger.info("Destroying existing Yugabyte var/ directory")

            out = subprocess.check_output(['python3', 'bin/yb-ctl', 'destroy'],
                                          stderr=subprocess.PIPE,
                                          cwd=self.path, )

            if 'error' in str(out.lower()):
                self.logger.error(f"Failed to destroy Yugabyte\n{str(out.lower())}")

    def start_database(self):
        self.logger.info("Starting Yugabyte node")

        subprocess.call(['python3', 'bin/yb-ctl', 'start'],
                        # stdout=subprocess.DEVNULL,
                        stderr=subprocess.STDOUT,
                        cwd=self.path)

        out = subprocess.check_output(['python3', 'bin/yb-ctl', 'status'],
                                      stderr=subprocess.PIPE,
                                      cwd=self.path, )

        # temporarily disabled status check
        # if 'Running.' not in str(out):
        #     self.logger.error(f"Failed to start Yugabyte\n{str(out)}")
        #     exit(1)

        self.establish_connection_from_output(str(out))

        self.logger.info("Waiting for 15 seconds for connection availability")
        sleep(15)

    def stop_database(self):
        self.logger.info("Stopping Yugabyte node if exists")
        out = subprocess.check_output(['python3', 'bin/yb-ctl', 'stop'],
                                      stderr=subprocess.PIPE,
                                      cwd=self.path, )

        if 'error' in str(out.lower()):
            self.logger.error(f"Failed to stop Yugabyte\n{str(out.lower())}")

        self.logger.info("Killing all master and tserver processes")
        subprocess.call(["pkill yb-master"],
                        shell=True)
        subprocess.call(["pkill yb-tserver"],
                        shell=True)


class YugabyteCollectResult(CollectResult):
    queries: List[YugabyteQuery] = None


class YugabyteResultsLoader(ResultsLoader):

    def __init__(self):
        super().__init__()
        self.clazz = YugabyteCollectResult
