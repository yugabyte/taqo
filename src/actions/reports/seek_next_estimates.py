from sql_formatter.core import format_sql

from collect import CollectResult
from objects import Query, PlanNodeVisitor, ScanNode
from actions.report import AbstractReportAction
from utils import allowed_diff, get_plan_diff
from config import Config
from typing import List

class PlanScanNodeVisitor(PlanNodeVisitor):
    def __init__(self, query_scan_nodes):
        super().__init__()
        self.query_scan_nodes = query_scan_nodes
        
    def visit_scan_node(self, node):
        print("GAURAV")
        self.query_scan_nodes.append(node)

class SeekNextEstimatesReport(AbstractReportAction):
    def __init__(self):
        super().__init__()
        self.config = Config()
        self.logger = self.config.logger
        self.loq = []
        self.query_scan_nodes: List[ScanNode] = list()

    def get_report_name(self):
        return "Default/Analyze/Analyze+Statistics"

    @classmethod
    def generate_report(cls, loq: CollectResult):
        report = SeekNextEstimatesReport()

        report.build_xls_report(loq)

    def build_xls_report(self, loq):
        for query in loq.queries:
            if not (plan := query.get_best_optimization(self.config).execution_plan):
                print(f"=== Query : [{query.query}]"
                        " does not have any valid plan\n")
            else:
                if not (ptree := plan.parse_plan()):
                    print(f"=== Failed to parse plan ===\n{plan.full_str}\n")
                else:
                    PlanScanNodeVisitor(self.query_scan_nodes).visit(ptree)
            
            for scan_node in self.query_scan_nodes:
                print (f"{scan_node.name}, {scan_node.get_property('estimated_seeks')}, {scan_node.get_property('estimated_nexts')}, {scan_node.get_property('actual_seeks')}, {scan_node.get_property('actual_nexts')} ")

    #     import xlsxwriter

    #     workbook = xlsxwriter.Workbook(f'report/{self.start_date}/report_seek_next_estimates.xls')
    #     worksheet = workbook.add_worksheet()

    #     head_format = workbook.add_format()
    #     head_format.set_bold()
    #     head_format.set_bg_color('#999999')

    #     eq_format = workbook.add_format()
    #     eq_format.set_bold()
    #     eq_format.set_bg_color('#d9ead3')

    #     eq_bad_format = workbook.add_format()
    #     eq_bad_format.set_bold()
    #     eq_bad_format.set_bg_color('#fff2cc')

    #     eq_good_format = workbook.add_format()
    #     eq_good_format.set_bold()
    #     eq_good_format.set_bg_color('#d9ead3')

    #     bm_format = workbook.add_format()
    #     bm_format.set_bold()
    #     bm_format.set_bg_color('#cfe2f3')

    #     pg_comparison_format = workbook.add_format()
    #     pg_comparison_format.set_bold()
    #     pg_comparison_format.set_bg_color('#fce5cd')

    #     # Start from the first cell. Rows and columns are zero indexed.
    #     yb_bests = 0
    #     pg_bests = 0
    #     total = 0
    #     for queries in self.queries.values():
    #         for query in queries:
    #             yb_query = query[0]
                
    #             # for query_optimization in yb_query.optimizations:
    #             #     if not (plan := query_optimization.execution_plan):
    #             #         self.logger.warn(f"=== Query : [{yb_query.query}]"
    #             #                         " does not have any valid plan\n")
    #             #         return

    #             #     if not (ptree := plan.parse_plan()):
    #             #         self.logger.warn(f"=== Failed to parse plan ===\n{plan.full_str}\n")
    #             #     else:

    #     worksheet.write(0, 0, "YB", head_format)
    #     worksheet.write(0, 1, "YB Best", head_format)
    #     worksheet.write(0, 2, "YB EQ", head_format)
    #     worksheet.write(0, 3, "PG", head_format)
    #     worksheet.write(0, 4, "PG Best", head_format)
    #     worksheet.write(0, 5, "PG EQ", head_format)
    #     worksheet.write(0, 6, "Ratio YB vs PG", head_format)
    #     worksheet.write(0, 7, "Default EQ", head_format)
    #     worksheet.write(0, 8, "Best YB vs PG", head_format)
    #     worksheet.write(0, 9, "Best EQ", head_format)
    #     worksheet.write(0, 10, "Query", head_format)
    #     worksheet.write(0, 11, "Query Hash", head_format)

    #     row = 1
    #     # Iterate over the data and write it out row by row.
    #     for tag, queries in self.queries.items():
    #         for query in queries:
    #             yb_query: PostgresQuery = query[0]
    #             pg_query: PostgresQuery = query[1]

    #             yb_best = yb_query.get_best_optimization(self.config, )
    #             pg_best = pg_query.get_best_optimization(self.config, )

    #             default_yb_equality = yb_query.compare_plans(yb_best.execution_plan)
    #             default_pg_equality = pg_query.compare_plans(pg_best.execution_plan)

    #             default_yb_pg_equality = yb_query.compare_plans(pg_query.execution_plan)
    #             best_yb_pg_equality = yb_best.compare_plans(pg_best.execution_plan)

    #             ratio_x3 = yb_query.execution_time_ms / (3 * pg_query.execution_time_ms) \
    #                 if pg_query.execution_time_ms > 0 else 99999999
    #             ratio_x3_str = "{:.2f}".format(yb_query.execution_time_ms / pg_query.execution_time_ms
    #                                            if pg_query.execution_time_ms > 0 else 99999999)
    #             ratio_color = ratio_x3 > 1.0

    #             ratio_best = yb_best.execution_time_ms / (3 * pg_best.execution_time_ms) \
    #                 if yb_best.execution_time_ms > 0 and pg_best.execution_time_ms > 0 else 99999999
    #             ratio_best_x3_str = "{:.2f}".format(
    #                 yb_best.execution_time_ms / pg_best.execution_time_ms
    #                 if yb_best.execution_time_ms > 0 and pg_best.execution_time_ms > 0 else 99999999)
    #             ratio_best_color = ratio_best > 1.0

    #             bitmap_flag = pg_query.execution_plan and "bitmap" in pg_query.execution_plan.full_str.lower()

    #             best_pg_format = None
    #             if ratio_best_color and best_yb_pg_equality:
    #                 best_pg_format = eq_bad_format
    #             elif best_yb_pg_equality:
    #                 best_pg_format = eq_good_format
    #             elif ratio_best_color:
    #                 best_pg_format = pg_comparison_format

    #             df_pf_format = None
    #             if ratio_color and default_yb_pg_equality:
    #                 df_pf_format = eq_bad_format
    #             elif default_yb_pg_equality:
    #                 df_pf_format = eq_good_format
    #             elif ratio_color:
    #                 df_pf_format = pg_comparison_format

    #             worksheet.write(row, 0, '{:.2f}'.format(yb_query.execution_time_ms))
    #             worksheet.write(row, 1,
    #                             f"{'{:.2f}'.format(yb_best.execution_time_ms)}",
    #                             eq_format if default_yb_equality else None)
    #             worksheet.write(row, 2, default_yb_equality)
    #             worksheet.write(row, 3,
    #                             f"{'{:.2f}'.format(pg_query.execution_time_ms)}",
    #                             bm_format if bitmap_flag else None)
    #             worksheet.write(row, 4,
    #                             f"{'{:.2f}'.format(pg_best.execution_time_ms)}",
    #                             eq_format if default_pg_equality else None)
    #             worksheet.write(row, 5, default_pg_equality)
    #             worksheet.write(row, 6, f"{ratio_x3_str}", df_pf_format)
    #             worksheet.write(row, 7, default_yb_pg_equality)
    #             worksheet.write(row, 8, f"{ratio_best_x3_str}", best_pg_format)
    #             worksheet.write(row, 9, best_yb_pg_equality)
    #             worksheet.write(row, 10, f'{format_sql(pg_query.query)}')
    #             worksheet.write(row, 11, f'{pg_query.query_hash}')
    #             row += 1

    #     workbook.close()

    # def add_query(self,
    #               default: Query,
    #               default_analyze: Query,
    #               ta: Query,
    #               ta_analyze: Query,
    #               stats: Query,
    #               stats_analyze: Query
    #               ):
    #     queries_tuple = [default, default_analyze, ta, ta_analyze, stats, stats_analyze]
    #     if not default.compare_plans(default_analyze.execution_plan) or \
    #             not ta.compare_plans(ta_analyze.execution_plan) or \
    #             not stats.compare_plans(stats_analyze.execution_plan):
    #         self.different_explain_plans.append(queries_tuple)

    #     if default.compare_plans(stats_analyze.execution_plan):
    #         self.same_execution_plan.append(queries_tuple)
    #     elif allowed_diff(self.config, default.execution_time_ms, stats_analyze.execution_time_ms):
    #         self.almost_same_execution_time.append(queries_tuple)
    #     elif default.execution_time_ms < stats_analyze.execution_time_ms:
    #         self.worse_execution_time.append(queries_tuple)
    #     else:
    #         self.improved_execution_time.append(queries_tuple)

    # def build_report(self):
    #     # link to top
    #     self.content += "\n[#top]\n== All results by analysis type\n"
    #     # different results links
    #     self.content += "\n<<error>>\n"
    #     self.content += "\n<<worse>>\n"
    #     self.content += "\n<<same_time>>\n"
    #     self.content += "\n<<improved>>\n"
    #     self.content += "\n<<same_plan>>\n"

    #     self.content += f"\n[#error]\n== ERROR: Different EXPLAIN and EXPLAIN ANALYZE plans ({len(self.different_explain_plans)})\n\n"
    #     for query in self.different_explain_plans:
    #         self.__report_query(*query)

    #     self.content += f"\n[#worse]\n== Worse execution time queries ({len(self.worse_execution_time)})\n\n"
    #     for query in self.worse_execution_time:
    #         self.__report_query(*query)

    #     self.content += f"\n[#same_time]\n== Almost same execution time queries ({len(self.almost_same_execution_time)})\n\n"
    #     for query in self.almost_same_execution_time:
    #         self.__report_query(*query)

    #     self.content += f"\n[#improved]\n== Improved execution time ({len(self.improved_execution_time)})\n\n"
    #     for query in self.improved_execution_time:
    #         self.__report_query(*query)

    #     self.content += f"\n[#same_plan]\n\n== Same execution plan ({len(self.same_execution_plan)})\n\n"
    #     for query in self.same_execution_plan:
    #         self.__report_query(*query)

    # # noinspection InsecureHash
    # def __report_query(self,
    #                    default: Query,
    #                    default_analyze: Query,
    #                    analyze: Query,
    #                    analyze_analyze: Query,
    #                    all: Query,
    #                    all_analyze: Query):
    #     self.reported_queries_counter += 1

    #     self.content += f"=== Query {default.query_hash}"
    #     self.content += f"\n{default.tag}\n"
    #     self.content += "\n<<top,Go to top>>\n"
    #     self.add_double_newline()

    #     self.start_source(["sql"])
    #     self.content += format_sql(default.query.replace("|", "\|"))
    #     self.end_source()

    #     self.add_double_newline()

    #     self.start_table("7")
    #     self.content += "|Metric|Default|Default+QA|TA|TA + QA|S+TA|S+TA+QA\n"
    #     self.start_table_row()
    #     self.content += f"Cardinality|{default.result_cardinality}|{default_analyze.result_cardinality}|" \
    #                    f"{analyze.result_cardinality}|{analyze_analyze.result_cardinality}|" \
    #                    f"{all.result_cardinality}|{all_analyze.result_cardinality}"
    #     self.end_table_row()
    #     self.start_table_row()
    #     self.content += f"Optimizer cost|{default.execution_plan.get_estimated_cost()}|{default_analyze.execution_plan.get_estimated_cost()}|" \
    #                    f"{analyze.execution_plan.get_estimated_cost()}|{analyze_analyze.execution_plan.get_estimated_cost()}|" \
    #                    f"{all.execution_plan.get_estimated_cost()}|{all_analyze.execution_plan.get_estimated_cost()}"
    #     self.end_table_row()
    #     self.start_table_row()
    #     self.content += f"Execution time|{default.execution_time_ms}|{default_analyze.execution_time_ms}|" \
    #                    f"{analyze.execution_time_ms}|{analyze_analyze.execution_time_ms}|" \
    #                    f"{all.execution_time_ms}|{all_analyze.execution_time_ms}"
    #     self.end_table_row()
    #     self.end_table()

    #     self.start_table()

    #     self.start_table_row()

    #     self.start_collapsible("Default approach plan (w/o analyze)")
    #     self.start_source(["diff"])
    #     self.content += default.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_collapsible("Default approach plan with EXPLAIN ANALYZE (w/o analyze)")
    #     self.start_source(["diff"])
    #     self.content += default_analyze.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_collapsible("Plan with analyzed table (w/ analyze)")
    #     self.start_source(["diff"])
    #     self.content += analyze.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_collapsible("Plan with analyzed table with EXPLAIN ANALYZE (w/ analyze)")
    #     self.start_source(["diff"])
    #     self.content += analyze_analyze.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_collapsible("Stats + table analyze (w/ analyze and statistics)")
    #     self.start_source(["diff"])
    #     self.content += all.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_collapsible(
    #         "Stats + table analyze with EXPLAIN ANALYZE (w/ analyze and statistics)")
    #     self.start_source(["diff"])
    #     self.content += all_analyze.execution_plan.full_str
    #     self.end_source()
    #     self.end_collapsible()

    #     self.start_source(["diff"])

    #     diff = get_plan_diff(
    #         default.execution_plan.full_str,
    #         all_analyze.execution_plan.full_str
    #     )
    #     if not diff:
    #         diff = default.execution_plan.full_str

    #     self.content += diff
    #     self.end_source()
    #     self.end_table_row()

    #     self.content += "\n"

    #     self.end_table()

    #     self.add_double_newline()
