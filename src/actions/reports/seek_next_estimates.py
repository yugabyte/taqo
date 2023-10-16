from sql_formatter.core import format_sql

from collect import CollectResult
from objects import Query, PlanNodeVisitor, ScanNode
from actions.report import AbstractReportAction
from utils import allowed_diff, get_plan_diff
from config import Config
from typing import List
import re

class QueryScanNode:
    def __init__(self, query: Query, scan_node: ScanNode):
        self.query_str = query.query
        self.query_hash = query.query_hash
        self.scan_node_name = scan_node.name
        self.scan_node_is_partial_aggregate = scan_node.is_scan_with_partial_aggregate()
        self.estimated_seeks = scan_node.get_property('estimated_seeks')
        self.actual_seeks = scan_node.get_property('actual_seeks')
        self.estimated_nexts = scan_node.get_property('estimated_nexts')
        self.actual_nexts = scan_node.get_property('actual_nexts')

class PlanScanNodeVisitor(PlanNodeVisitor):
    def __init__(self, query_scan_nodes: List[QueryScanNode], query: Query):
        super().__init__()
        self.query = query
        self.query_scan_nodes = query_scan_nodes
        
    def visit_scan_node(self, node):
        self.query_scan_nodes.append(QueryScanNode(self.query, node))

class SeekNextEstimatesReport(AbstractReportAction):
    def __init__(self):
        super().__init__()
        self.config = Config()
        self.logger = self.config.logger
        self.loq = []
        self.query_scan_nodes: List[QueryScanNode] = list()

    def get_report_name(self):
        return "Default/Analyze/Analyze+Statistics"

    @classmethod
    def generate_report(cls, loq: CollectResult):
        report = SeekNextEstimatesReport()

        report.build_xls_report(loq)

    def build_xls_report(self, loq):
        import xlsxwriter

        workbook = xlsxwriter.Workbook(f'report/{self.start_date}/report_seek_next_estimates.xls')
        worksheet = workbook.add_worksheet()

        head_format = workbook.add_format()
        head_format.set_bold()
        head_format.set_bg_color('#999999')

        eq_format = workbook.add_format()
        eq_format.set_bold()
        eq_format.set_bg_color('#d9ead3')

        eq_bad_format = workbook.add_format()
        eq_bad_format.set_bold()
        eq_bad_format.set_bg_color('#fff2cc')

        eq_good_format = workbook.add_format()
        eq_good_format.set_bold()
        eq_good_format.set_bg_color('#d9ead3')

        bm_format = workbook.add_format()
        bm_format.set_bold()
        bm_format.set_bg_color('#cfe2f3')

        pg_comparison_format = workbook.add_format()
        pg_comparison_format.set_bold()
        pg_comparison_format.set_bg_color('#fce5cd')
        
        worksheet.write(0, 0, "Query", head_format)
        worksheet.write(0, 1, "Query Hash", head_format)
        worksheet.write(0, 2, "Scan Node Name", head_format)
        worksheet.write(0, 3, "Partial Aggregate", head_format)
        worksheet.write(0, 4, "LIMIT clause", head_format)
        worksheet.write(0, 5, "Estimated Seeks", head_format)
        worksheet.write(0, 6, "Actual Seeks", head_format)
        worksheet.write(0, 7, "Estimated Nexts", head_format)
        worksheet.write(0, 8, "Actual Nexts", head_format)
        
        limit_pattern = re.compile(r'\bLIMIT\b|\blimit\b')
        
        row = 1
        for query in loq.queries:
            if not (plan := query.execution_plan):
                print(f"=== Query : [{query.query}]"
                        " does not have any valid plan\n")
            else:
                if not (ptree := plan.parse_plan()):
                    print(f"=== Failed to parse plan ===\n{plan.full_str}\n")
                else:
                    PlanScanNodeVisitor(self.query_scan_nodes, query).visit(ptree)
            
        for query_scan_node in self.query_scan_nodes:
            worksheet.write(row, 0, f'{query_scan_node.query_str}')
            worksheet.write(row, 1, f'{query_scan_node.query_hash}')
            worksheet.write(row, 2, f'{query_scan_node.scan_node_name}')
            worksheet.write(row, 3, f'{query_scan_node.scan_node_is_partial_aggregate}')
            worksheet.write(row, 4, f'{re.search(limit_pattern, query_scan_node.query_str) != None}')
            worksheet.write(row, 5, f"{query_scan_node.estimated_seeks}")
            worksheet.write(row, 6, f"{query_scan_node.actual_seeks}")
            worksheet.write(row, 7, f"{query_scan_node.estimated_nexts}")
            worksheet.write(row, 8, f"{query_scan_node.actual_nexts}")
            row += 1

        workbook.close()