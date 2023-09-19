import os
import shutil
import subprocess
import time
from pathlib import Path

from config import Config


class ReportActions:
    report = ""

    def add_double_newline(self):
        self.report += "\n\n"

    def start_table(self, columns: str = "1"):
        self.report += f"[cols=\"{columns}\"]\n" \
                       "|===\n"

    def start_table_row(self):
        self.report += "a|"

    def end_table_row(self):
        self.report += "\n"

    def end_table(self):
        self.report += "|===\n"

    def start_source(self, additional_tags=None, linenums=True):
        tags = f",{','.join(additional_tags)}" if additional_tags else ""
        tags += ",linenums" if linenums else ""

        self.report += f"[source{tags}]\n----\n"

    def end_source(self):
        self.report += "\n----\n"

    def start_collapsible(self, name, sep='===='):
        self.report += f"""\n\n.{name}\n[%collapsible]\n{sep}\n"""

    def end_collapsible(self, sep='===='):
        self.report += f"""\n{sep}\n\n"""


class AbstractReportAction(ReportActions):
    def __init__(self):
        self.config = Config()
        self.logger = self.config.logger

        self.report = f"= Optimizer {self.get_report_name()} Test Report \n" \
                      f":source-highlighter: coderay\n" \
                      f":coderay-linenums-mode: inline\n\n"

        self.start_collapsible("Reporting configuration")
        self.start_source()
        self.report += str(self.config)
        self.end_source()
        self.end_collapsible()

        self.reported_queries_counter = 0
        self.queries = []
        self.sub_reports = []

        self.start_date = time.strftime("%Y%m%d-%H%M%S")

        if self.config.clear:
            self.logger.info("Clearing report directory")
            shutil.rmtree("report", ignore_errors=True)

        if not os.path.isdir("report"):
            os.mkdir("report")

        if not os.path.isdir(f"report/{self.start_date}"):
            os.mkdir(f"report/{self.start_date}")
            os.mkdir(f"report/{self.start_date}/imgs")
            os.mkdir(f"report/{self.start_date}/tags")

    def get_report_name(self):
        return ""

    def report_model(self, model_queries):
        if model_queries:
            self.start_collapsible("Model queries")
            self.start_source(["sql"])
            self.report += "\n".join(
                [query if query.endswith(";") else f"{query};" for query in model_queries])
            self.end_source()
            self.end_collapsible()

    def report_config(self, config, collapsible_name):
        if config:
            self.start_collapsible(f"Collect configuration {collapsible_name}")
            self.start_source(["sql"])
            self.report += config
            self.end_source()
            self.end_collapsible()

    def create_sub_report(self, name):
        subreport = SubReport(name)
        self.sub_reports.append(subreport)
        return subreport

    def publish_report(self, report_name):
        report_adoc = f"report/{self.start_date}/index_{self.config.output}.adoc"

        with open(report_adoc, "w") as file:
            file.write(self.report)

        for sub_report in self.sub_reports:
            with open(f"report/{self.start_date}/tags/{sub_report.name}.adoc", "w") as file:
                file.write(sub_report.report)

        self.logger.info(f"Generating report file from {report_adoc} and compiling html")
        asciidoc_return_code = subprocess.run(
            f'{self.config.asciidoctor_path} '
            f'-a stylesheet={os.path.abspath("css/adoc.css")} '
            f'{report_adoc}',
            shell=True).returncode

        for sub_report in self.sub_reports:
            subprocess.call(
                f'{self.config.asciidoctor_path} '
                f'-a stylesheet={os.path.abspath("css/adoc.css")} '
                f"report/{self.start_date}/tags/{sub_report.name}.adoc",
                shell=True)

        if asciidoc_return_code != 0:
            self.logger.exception("Failed to generate HTML file! Check asciidoctor path")
        else:
            report_html_path = Path(f'report/{self.start_date}/index_{self.config.output}.html')
            self.logger.info(f"Done! Check report at {report_html_path.absolute()}")


class SubReport(ReportActions):
    def __init__(self, name):
        self.config = Config()
        self.logger = self.config.logger

        self.name = name
        self.report = f"= {name} report \n" \
                      f":source-highlighter: coderay\n" \
                      f":coderay-linenums-mode: inline\n\n"

