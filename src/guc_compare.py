"""
GUC Comparison Script
=====================
Runs a set of SQL queries twice — once with the "before" value of each GUC and once
with the "after" value — and produces a self-contained index.html report showing
execution times side-by-side.

Each .sql file in the model's queries/ directory may contain multiple statements
separated by semicolons.  Every individual statement is timed and reported
separately, grouped by file in the report.  SET statements inside query files
are skipped (they are not test queries).

No TAQO optimisation enumeration is done.  The goal is purely:
    "Run queries with flag-A settings vs flag-B settings, find regressions."

Usage
-----
    python3 src/guc_compare.py \\
        --model basic \\
        --gucs '{"enable_seqscan": ["on", "off"], "work_mem": ["64MB", "256MB"]}' \\
        --label1 "Default" \\
        --label2 "No SeqScan + 256MB work_mem" \\
        --host 127.0.0.1 --port 5433 \\
        --database taqo_basic \\
        --output report/guc_compare_result \\
        --yes

    # With DDL (drop -> create -> import -> analyze before querying):
    python3 src/guc_compare.py \\
        --model basic \\
        --gucs '{"enable_seqscan": ["on", "off"]}' \\
        --database taqo_basic \\
        --ddl \\
        --ddl-steps drop,create,import,analyze \\
        --output report/guc_compare_result \\
        --yes

The --gucs value is a JSON object where each key is a GUC name and the value is a
two-element list [before_value, after_value].  Before each query run the script
executes  SET <guc_name> = <value>  for every entry.

See --help for the full list of options.
"""

import argparse
import difflib
import html
import json
import logging
import os
import re
import statistics
import sys
import time
import traceback
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import psycopg2
import sqlparse

def _init_logger(verbose: bool) -> logging.Logger:
    level = logging.DEBUG if verbose else logging.INFO
    fmt = logging.Formatter("%(asctime)s:%(levelname)5s: %(message)s")
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(fmt)
    logger = logging.getLogger("guc_compare")
    logger.setLevel(level)
    logger.addHandler(handler)
    return logger


GucMap = Dict[str, Tuple[str, str]]   # {guc_name: (before_value, after_value)}


def parse_gucs(gucs_json: str) -> GucMap:
    """Parse the --gucs JSON argument.

    Expected format:
        '{"enable_seqscan": ["on", "off"], "work_mem": ["64MB", "256MB"]}'

    Returns a dict mapping guc_name -> (before_value, after_value).
    """
    try:
        raw = json.loads(gucs_json)
    except json.JSONDecodeError as e:
        raise ValueError(f"--gucs is not valid JSON: {e}") from e

    if not isinstance(raw, dict):
        raise ValueError("--gucs must be a JSON object (dict)")

    result: GucMap = {}
    for name, pair in raw.items():
        if not isinstance(pair, list) or len(pair) != 2:
            raise ValueError(
                f"Each GUC entry must be a two-element list [before, after]; "
                f"got {name!r}: {pair!r}"
            )
        result[name] = (str(pair[0]), str(pair[1]))

    return result


def gucs_to_set_stmts(gucs: GucMap, side: int) -> List[str]:
    """Return a list of SET statements for the given side (0=before, 1=after)."""
    return [f"SET {name} = {pair[side]};" for name, pair in gucs.items()]


def gucs_display(gucs: GucMap, side: int) -> str:
    """Human-readable multiline string of SET statements for the report."""
    return "\n".join(f"SET {name} = {pair[side]};" for name, pair in gucs.items())


@dataclass
class QueryResult:
    query_number: int
    query_file: str
    query_index: int
    query_sql: str
    times1: List[float] = field(default_factory=list)
    times2: List[float] = field(default_factory=list)
    avg1: float = -1.0
    avg2: float = -1.0
    error1: Optional[str] = None
    error2: Optional[str] = None
    plan1: Optional[str] = None
    plan2: Optional[str] = None


@dataclass
class CompareRun:
    label1: str
    label2: str
    gucs_before: str
    gucs_after: str
    model: str
    timestamp: str
    results: List[QueryResult] = field(default_factory=list)


def _get_model_path(model: str) -> Path:
    if model.startswith("/") or model.startswith("."):
        return Path(model)
    return Path("sql") / model


def _split_sql_file(sql_text: str) -> List[str]:
    """Split a SQL file into individual executable statements.

    - Uses sqlparse to split on semicolons correctly.
    - Skips SET statements (those are session-level, not test queries).
    - Skips blank/comment-only fragments.
    """
    statements = []
    for raw in sqlparse.split(sql_text):
        stmt = raw.strip()
        if not stmt:
            continue
        cleaned = sqlparse.format(stmt, strip_comments=True).strip()
        if not cleaned:
            continue
        if cleaned.lower().startswith("set "):
            continue
        statements.append(cleaned)
    return statements


def _load_queries(model: str, num_queries: int) -> List[Tuple[str, int, str]]:
    """Return list of (filename, query_index, sql_text) for every statement
    across all .sql files in the model's queries/ directory.

    query_index is 1-based within each file.
    num_queries limits the total count across all files (-1 = no limit).
    """
    queries_dir = _get_model_path(model) / "queries"
    if not queries_dir.is_dir():
        raise FileNotFoundError(f"Queries directory not found: {queries_dir}")

    files = sorted(queries_dir.glob("*.sql"))
    if not files:
        raise FileNotFoundError(f"No .sql files found in {queries_dir}")

    result: List[Tuple[str, int, str]] = []
    for f in files:
        stmts = _split_sql_file(f.read_text(encoding="utf-8"))
        for idx, stmt in enumerate(stmts, start=1):
            result.append((f.name, idx, stmt))
            if num_queries > 0 and len(result) >= num_queries:
                return result

    return result

_COPY_RE = re.compile(
    r"(?i)\bCOPY\b\s(.+)\s\bFROM\b\s'(.*)'\s\bWITH\b\s\((.*?)\)",
    re.DOTALL,
)

DDL_STEPS_ORDERED = ["drop", "create", "import", "analyze"]


def _parse_ddl_steps(steps_str: str) -> List[str]:
    requested = [s.strip().lower() for s in steps_str.split(",") if s.strip()]
    unknown = set(requested) - set(DDL_STEPS_ORDERED)
    if unknown:
        raise ValueError(f"Unknown DDL steps: {unknown}. Valid: {DDL_STEPS_ORDERED}")
    return [s for s in DDL_STEPS_ORDERED if s in requested]


def _apply_variables(sql: str, data_path: str) -> str:
    if data_path:
        sql = sql.replace("$DATA_PATH", data_path)
    return sql


def _try_copy(cur, query: str, logger: logging.Logger) -> bool:
    m = _COPY_RE.search(query)
    if not m:
        return False

    table_name = m.group(1).strip()
    local_path  = m.group(2).strip()
    params_str  = m.group(3).strip()

    def _param(name, value_pattern):
        hit = re.search(rf"(?i){name}\s+{value_pattern}", params_str)
        return hit.group(1) if hit else None

    delimiter   = _param("delimiter", r"'(.{1,3})'") or ","
    file_format = _param("format", r"([a-zA-Z]+)")
    null_format = _param("null", r"'([a-zA-Z]*)'") or ""

    if delimiter == "\\t":
        delimiter = "\t"
    if file_format is None or "csv" not in file_format.lower():
        raise ValueError(f"COPY: only CSV format is supported (got {file_format!r})")
    if not os.path.isfile(local_path):
        raise FileNotFoundError(f"COPY: data file not found: {local_path}")

    logger.debug(f"DDL COPY >> {table_name} from {local_path}")
    with open(local_path, "r") as csv_file:
        cur.copy_from(csv_file, table_name, sep=delimiter, null=null_format)
    return True


def _run_ddl_file(conn, sql_path: Path, ddl_timeout_s: int,
                  data_path: str, logger: logging.Logger):
    if not sql_path.exists():
        logger.warning(f"DDL file not found, skipping: {sql_path}")
        return

    logger.info(f"  Executing {sql_path.name} ...")
    sql = _apply_variables(sql_path.read_text(encoding="utf-8"), data_path)

    with conn.cursor() as cur:
        cur.execute(f"SET statement_timeout = '{ddl_timeout_s}s'")
        for stmt in sqlparse.split(sql):
            stmt = stmt.lstrip()
            if not stmt:
                continue
            logger.debug(f"DDL >> {stmt[:120].rstrip()}")
            if not _try_copy(cur, stmt, logger):
                cur.execute(stmt)
    conn.commit()


def run_ddl(conn, model: str, steps: List[str], ddl_timeout_s: int,
            data_path: str, ddl_prefix: str, logger: logging.Logger):
    model_path = _get_model_path(model)
    for step in steps:
        prefixed = model_path / f"{ddl_prefix}.{step}.sql"
        plain    = model_path / f"{step}.sql"
        sql_path = prefixed if (ddl_prefix and prefixed.exists()) else plain
        logger.info(f"DDL step: {step.upper()}")
        _run_ddl_file(conn, sql_path, ddl_timeout_s, data_path, logger)


def _connect(host: str, port: int, username: str, password: str, database: str):
    return psycopg2.connect(
        host=host, port=port, user=username,
        password=password, dbname=database, connect_timeout=30,
    )


def _apply_set_stmts(cur, stmts: List[str], logger: logging.Logger):
    for stmt in stmts:
        logger.debug(f"GUC >> {stmt}")
        cur.execute(stmt)


def _current_ms() -> float:
    return (time.time_ns() // 1_000) / 1_000


def _run_query_timed(conn, set_stmts: List[str], sql: str, num_retries: int,
                     timeout_ms: int, logger: logging.Logger) -> Tuple[List[float], Optional[str]]:
    times: List[float] = []
    last_error: Optional[str] = None

    for i in range(num_retries):
        try:
            with conn.cursor() as cur:
                if timeout_ms > 0:
                    cur.execute(f"SET statement_timeout = {timeout_ms};")
                _apply_set_stmts(cur, set_stmts, logger)
                t0 = _current_ms()
                cur.execute(sql)
                cur.fetchall()
                times.append(_current_ms() - t0)
            conn.rollback()
        except psycopg2.errors.QueryCanceled:
            conn.rollback()
            last_error = "timeout"
            logger.warning(f"  Iteration {i+1}: query timed out")
        except Exception as exc:
            conn.rollback()
            last_error = str(exc)
            logger.warning(f"  Iteration {i+1}: error - {exc}")

    return times, last_error


def _fetch_explain_analyze(conn, set_stmts: List[str], sql: str,
                           timeout_ms: int, logger: logging.Logger) -> Optional[str]:
    """Run EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) and return the plan as a string."""
    try:
        with conn.cursor() as cur:
            if timeout_ms > 0:
                cur.execute(f"SET statement_timeout = {timeout_ms};")
            _apply_set_stmts(cur, set_stmts, logger)
            cur.execute(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) {sql}")
            rows = cur.fetchall()
        conn.rollback()
        return "\n".join(r[0] for r in rows)
    except Exception as exc:
        conn.rollback()
        logger.warning(f"  EXPLAIN ANALYZE failed: {exc}")
        return f"[EXPLAIN ANALYZE failed: {exc}]"


def _safe_avg(times: List[float]) -> float:
    return statistics.mean(times) if times else -1.0


_EXEC_TIME_RE = re.compile(r"Execution Time:\s*([\d.]+)\s*ms", re.IGNORECASE)


def _extract_exec_ms(plan: Optional[str]) -> Optional[float]:
    """Extract the Execution Time value (ms) from an EXPLAIN ANALYZE plan string."""
    if not plan:
        return None
    m = _EXEC_TIME_RE.search(plan)
    return float(m.group(1)) if m else None


def run_comparison(args, gucs: GucMap, logger: logging.Logger) -> CompareRun:
    logger.info("Connecting to database ...")
    conn = _connect(args.host, args.port, args.username, args.password, args.database)
    conn.autocommit = False
    logger.info("Connected.")

    if args.ddl:
        steps = _parse_ddl_steps(args.ddl_steps)
        logger.info(f"Running DDL steps: {steps}")
        run_ddl(conn, args.model, steps, args.ddl_timeout_s,
                args.data_path, args.ddl_prefix, logger)
        logger.info("DDL complete.")

    query_files = _load_queries(args.model, args.num_queries)
    logger.info(f"Loaded {len(query_files)} queries from model '{args.model}'")

    stmts_before = gucs_to_set_stmts(gucs, side=0)
    stmts_after  = gucs_to_set_stmts(gucs, side=1)

    run = CompareRun(
        label1=args.label1,
        label2=args.label2,
        gucs_before=gucs_display(gucs, side=0),
        gucs_after=gucs_display(gucs, side=1),
        model=args.model,
        timestamp=time.strftime("%Y-%m-%d %H:%M:%S"),
    )

    for global_num, (fname, qidx, sql) in enumerate(query_files, start=1):
        logger.info(f"[{global_num}/{len(query_files)}] {fname} query {qidx}")

        qr = QueryResult(
            query_number=global_num,
            query_file=fname,
            query_index=qidx,
            query_sql=sql,
        )

        logger.info(f"  Running with [{args.label1}] ...")
        qr.times1, qr.error1 = _run_query_timed(
            conn, stmts_before, sql, args.num_retries, args.timeout_ms, logger)
        qr.avg1 = _safe_avg(qr.times1)
        logger.info(f"    avg={qr.avg1:.2f} ms  raw={[round(t, 2) for t in qr.times1]}")

        logger.info(f"  Running with [{args.label2}] ...")
        qr.times2, qr.error2 = _run_query_timed(
            conn, stmts_after, sql, args.num_retries, args.timeout_ms, logger)
        qr.avg2 = _safe_avg(qr.times2)
        logger.info(f"    avg={qr.avg2:.2f} ms  raw={[round(t, 2) for t in qr.times2]}")

        logger.info(f"  Fetching EXPLAIN ANALYZE for both GUC sets ...")
        qr.plan1 = _fetch_explain_analyze(conn, stmts_before, sql, args.timeout_ms, logger)
        qr.plan2 = _fetch_explain_analyze(conn, stmts_after,  sql, args.timeout_ms, logger)

        # Overwrite avg1/avg2 with EXPLAIN ANALYZE execution time if available,
        # since that reflects actual DB engine time rather than wall-clock.
        exec1 = _extract_exec_ms(qr.plan1)
        exec2 = _extract_exec_ms(qr.plan2)
        if exec1 is not None:
            qr.avg1 = exec1
            logger.info(f"    [{args.label1}] EXPLAIN ANALYZE exec={exec1:.2f} ms")
        if exec2 is not None:
            qr.avg2 = exec2
            logger.info(f"    [{args.label2}] EXPLAIN ANALYZE exec={exec2:.2f} ms")

        run.results.append(qr)

    conn.close()
    return run


def _save_json(run: CompareRun, path: str):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(asdict(run), f, indent=2)


def _load_json(path: str) -> CompareRun:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    results = [QueryResult(**r) for r in data.pop("results", [])]
    run = CompareRun(**data)
    run.results = results
    # Re-derive avg1/avg2 from EXPLAIN ANALYZE execution time if plans are present.
    # This handles JSONs saved before the exec-time extraction was added.
    for qr in run.results:
        exec1 = _extract_exec_ms(qr.plan1)
        exec2 = _extract_exec_ms(qr.plan2)
        if exec1 is not None:
            qr.avg1 = exec1
        if exec2 is not None:
            qr.avg2 = exec2
    return run



_HTML_STYLE = """
body{font-family:system-ui,sans-serif;margin:0;padding:0;background:#f5f5f5;color:#222;}
h1{background:#2c3e50;color:#fff;margin:0;padding:16px 24px;font-size:1.4rem;}
.meta{background:#34495e;color:#ecf0f1;padding:8px 24px;font-size:.85rem;display:flex;gap:32px;flex-wrap:wrap;}
.meta span{display:inline-block;}
.container{padding:24px;}
.summary-box{display:flex;gap:16px;margin-bottom:24px;flex-wrap:wrap;}
.stat-card{background:#fff;border-radius:8px;padding:16px 24px;box-shadow:0 1px 3px rgba(0,0,0,.12);min-width:140px;}
.stat-card .val{font-size:2rem;font-weight:700;}
.stat-card .lbl{font-size:.8rem;color:#666;margin-top:4px;}
.green{color:#27ae60;}.red{color:#e74c3c;}.gray{color:#888;}.yellow{color:#d4ac0d;}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;
      box-shadow:0 1px 3px rgba(0,0,0,.12);overflow:hidden;margin-bottom:40px;}
thead tr{background:#2c3e50;color:#fff;}
th,td{padding:10px 14px;text-align:left;font-size:.88rem;vertical-align:top;}
tbody tr:nth-child(even){background:#f9f9f9;}
tbody tr:hover{background:#eaf2ff;}
tr.file-header td{background:#dde4ed;color:#2c3e50;font-weight:700;font-size:.9rem;
                   padding:8px 14px;border-top:2px solid #2c3e50;}
tr.timeout-row{background:#fefde7 !important;}
.query-sql{font-family:monospace;font-size:.8rem;white-space:pre-wrap;word-break:break-all;
           background:#f4f4f4;padding:8px;border-radius:4px;max-height:160px;overflow-y:auto;border:1px solid #ddd;}
.badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:.78rem;font-weight:600;}
.badge-green{background:#d4efdf;color:#1e8449;}
.badge-red{background:#fadbd8;color:#922b21;}
.badge-gray{background:#eee;color:#555;}
.badge-yellow{background:#fef9c3;color:#92700a;}
.ratio{font-weight:700;}
details summary{cursor:pointer;color:#2980b9;font-size:.82rem;}
.guc-block{font-family:monospace;font-size:.8rem;background:#f0f0f0;padding:8px;
            border-radius:4px;border:1px solid #ccc;white-space:pre-wrap;margin:4px 0 12px;}
.threshold-bar{display:flex;align-items:center;gap:12px;background:#fff;
               padding:12px 18px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.12);
               margin-bottom:16px;flex-wrap:wrap;}
.threshold-bar label{font-size:.9rem;font-weight:600;color:#2c3e50;}
.threshold-bar input[type=number]{width:80px;padding:4px 8px;border:1px solid #ccc;
               border-radius:4px;font-size:.9rem;}
.threshold-bar button{padding:5px 14px;background:#2c3e50;color:#fff;border:none;
               border-radius:4px;cursor:pointer;font-size:.85rem;}
.threshold-bar button:hover{background:#34495e;}
.threshold-bar button.invert-btn{background:#7d3c98;}
.threshold-bar button.invert-btn:hover{background:#9b59b6;}
.threshold-bar button.invert-btn.active{background:#27ae60;}
.threshold-bar button.invert-btn.active:hover{background:#1e8449;}
#threshold-summary{font-size:.85rem;color:#555;}
.gh-link{display:block;padding:5px 10px;background:#f6f8fa;border:1px solid #d0d7de;
          border-radius:6px;color:#0969da;text-decoration:none;font-size:.82rem;
          font-family:monospace;margin-bottom:5px;white-space:nowrap;}
.gh-link:hover{background:#eef2f7;text-decoration:underline;}
.gh-link::before{content:"📁 ";font-style:normal;}
"""

_GITHUB_BASE = "https://github.com/yugabyte/taqo/tree/main"

_HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>GUC Comparison - {model}</title>
<style>{style}</style>
</head>
<body>
<h1>GUC Comparison Report &mdash; {model}</h1>
<div class="meta">
  <span>Generated: {timestamp}</span>
  <span>Model: {model}</span>
  <span>Queries: {total}</span>
  <span>Retries per query: {retries}</span>
</div>
<div class="container">

<h2>Configuration</h2>
<div style="display:flex;justify-content:space-between;align-items:flex-start;gap:16px;flex-wrap:wrap;margin-bottom:12px;">
<table style="width:auto;margin-bottom:0;">
  <thead><tr><th>Label</th><th>GUC settings applied before each run</th></tr></thead>
  <tbody>
    <tr><td><strong>{label1}</strong></td><td><pre class="guc-block">{gucs_before}</pre></td></tr>
    <tr><td><strong>{label2}</strong></td><td><pre class="guc-block">{gucs_after}</pre></td></tr>
  </tbody>
</table>
<div style="text-align:right;min-width:200px;">
  <div style="font-size:.8rem;color:#888;margin-bottom:6px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;">Model source</div>
  {github_links}
</div>
</div>

<h2>Summary</h2>
<div class="summary-box" id="summary-box">
  <div class="stat-card"><div class="val">{total}</div><div class="lbl">Total queries</div></div>
  <div class="stat-card"><div class="val green" id="cnt-better">{better}</div><div class="lbl">{label2} faster</div></div>
  <div class="stat-card"><div class="val red" id="cnt-worse">{worse}</div><div class="lbl">{label2} slower</div></div>
  <div class="stat-card"><div class="val gray" id="cnt-same">{same}</div><div class="lbl">Within &plusmn;<span id="pct-display">{pct}</span>%</div></div>
  <div class="stat-card"><div class="val yellow" id="cnt-timeout">{timeouts}</div><div class="lbl">Timeouts</div></div>
  <div class="stat-card"><div class="val gray" id="cnt-errors">{errors}</div><div class="lbl">Errors</div></div>
</div>

<h2>Query Results</h2>
<div class="threshold-bar">
  <label for="pct-input">Regression threshold (%)</label>
  <input type="number" id="pct-input" min="0" max="1000" step="1" value="{pct}">
  <button onclick="applyThreshold()">Apply</button>
  <button id="invert-btn" class="invert-btn" onclick="toggleInvert()" title="Swap which side is the baseline for ratio and colour">&#x21c4; Invert comparison</button>
  <span id="threshold-summary"></span>
</div>
<table id="results-table">
  <thead>
    <tr>
      <th>#</th>
      <th id="col-label1">{label1} avg (ms)</th>
      <th id="col-label2">{label2} avg (ms)</th>
      <th id="col-ratio">Ratio ({label2}/{label1})</th>
      <th>Query</th>
    </tr>
  </thead>
  <tbody>
{rows}
  </tbody>
</table>
</div>

<script>
(function() {{
  var inverted = false;
  var cellsSwapped = false;
  var LABEL1 = {label1_js};
  var LABEL2 = {label2_js};

  function classify(ratio, pct) {{
    if (ratio === null) return 'error';
    var diff = Math.abs(ratio - 1.0) * 100;
    if (diff <= pct) return 'same';
    return ratio < 1.0 ? 'better' : 'worse';
  }}

  function effectiveRatio(rawRatio) {{
    if (rawRatio === null) return null;
    return inverted ? (1.0 / rawRatio) : rawRatio;
  }}

  function swapTimeCells(dataRows) {{
    dataRows.forEach(function(row) {{
      var c1 = row.querySelector('.time-col1');
      var c2 = row.querySelector('.time-col2');
      if (!c1 || !c2) return;
      if (inverted && !cellsSwapped) {{
        // swap to show label2's times in col1, label1's in col2
        var tmp = c1.innerHTML;
        c1.innerHTML = c2.innerHTML;
        c2.innerHTML = tmp;
      }} else if (!inverted && cellsSwapped) {{
        // restore original order using stored data attributes
        c1.innerHTML = JSON.parse(row.getAttribute('data-cell1'));
        c2.innerHTML = JSON.parse(row.getAttribute('data-cell2'));
      }}
    }});
    cellsSwapped = inverted;
  }}

  function applyAll() {{
    var pct = parseFloat(document.getElementById('pct-input').value);
    if (isNaN(pct) || pct < 0) return;
    document.getElementById('pct-display').textContent = pct.toFixed(0);

    // update column headers
    document.getElementById('col-label1').textContent =
      (inverted ? LABEL2 : LABEL1) + ' avg (ms)';
    document.getElementById('col-label2').textContent =
      (inverted ? LABEL1 : LABEL2) + ' avg (ms)';
    document.getElementById('col-ratio').textContent =
      'Ratio (' + (inverted ? LABEL1 + '/' + LABEL2 : LABEL2 + '/' + LABEL1) + ')';

    // update summary card labels
    document.querySelector('#cnt-better').parentElement.querySelector('.lbl').textContent =
      (inverted ? LABEL1 : LABEL2) + ' faster';
    document.querySelector('#cnt-worse').parentElement.querySelector('.lbl').textContent =
      (inverted ? LABEL1 : LABEL2) + ' slower';

    var dataRows = Array.from(document.querySelectorAll('#results-table tbody tr[data-ratio]'));
    swapTimeCells(dataRows);

    var better = 0, worse = 0, same = 0, timeouts = 0, errors = 0;
    dataRows.forEach(function(row) {{
      var rawRatio = row.getAttribute('data-ratio');
      var isTimeout = row.getAttribute('data-timeout') === '1';
      var storedRatio = (rawRatio === 'null') ? null : parseFloat(rawRatio);
      var ratio = effectiveRatio(storedRatio);
      var cls = classify(ratio, pct);

      row.style.background = '';
      if (isTimeout) {{
        row.style.background = '#fefde7';
        timeouts++;
      }} else if (cls === 'better') {{
        row.style.background = '#eafaf1';
        better++;
      }} else if (cls === 'worse') {{
        row.style.background = '#fdedec';
        worse++;
      }} else if (cls === 'same') {{
        same++;
      }} else {{
        errors++;
      }}

      var badge = row.querySelector('.ratio .badge');
      if (badge) {{
        badge.className = 'badge';
        if (isTimeout) {{
          badge.classList.add('badge-yellow');
        }} else if (ratio === null) {{
          badge.classList.add('badge-gray');
          badge.textContent = 'N/A';
        }} else {{
          var ratioStr = ratio.toFixed(3) + 'x';
          badge.textContent = ratioStr;
          if (cls === 'same') badge.classList.add('badge-gray');
          else if (cls === 'better') badge.classList.add('badge-green');
          else badge.classList.add('badge-red');
        }}
      }}
    }});

    document.getElementById('cnt-better').textContent = better;
    document.getElementById('cnt-worse').textContent = worse;
    document.getElementById('cnt-same').textContent = same;
    document.getElementById('cnt-timeout').textContent = timeouts;
    document.getElementById('cnt-errors').textContent = errors;
    document.getElementById('threshold-summary').textContent =
      better + ' faster, ' + worse + ' slower, ' + same + ' within \u00b1' + pct.toFixed(0) + '%';
  }}

  window.applyThreshold = applyAll;

  window.toggleInvert = function() {{
    inverted = !inverted;
    var btn = document.getElementById('invert-btn');
    if (inverted) {{
      btn.classList.add('active');
      btn.textContent = '\u21c4 Inverted (' + LABEL1 + '/' + LABEL2 + ')';
    }} else {{
      btn.classList.remove('active');
      btn.textContent = '\u21c4 Invert comparison';
    }}
    applyAll();
  }};

  document.getElementById('pct-input').addEventListener('keydown', function(e) {{
    if (e.key === 'Enter') applyAll();
  }});
}})();

window.openDetail = function(el) {{
  var row = el.closest('tr');
  var detailHtml = JSON.parse(row.getAttribute('data-detail'));
  var blob = new Blob([detailHtml], {{type: 'text/html'}});
  var url = URL.createObjectURL(blob);
  var win = window.open(url, '_blank');
  // revoke after a short delay to allow the browser to load the blob
  if (win) {{ setTimeout(function() {{ URL.revokeObjectURL(url); }}, 10000); }}
}};
</script>
</body>
</html>
"""


def _is_timeout(error: Optional[str]) -> bool:
    return error == "timeout"


def _ratio_badge(avg1: float, avg2: float, pct_threshold: float,
                 has_timeout: bool = False) -> str:
    if avg1 <= 0 or avg2 <= 0:
        if has_timeout:
            return '<span class="badge badge-yellow">timeout</span>'
        return '<span class="badge badge-gray">N/A</span>'
    ratio = avg2 / avg1
    ratio_str = f"{ratio:.3f}x"
    if has_timeout:
        return f'<span class="badge badge-yellow">{ratio_str}</span>'
    if abs(ratio - 1.0) * 100 <= pct_threshold:
        return f'<span class="badge badge-gray">{ratio_str}</span>'
    return (f'<span class="badge badge-green">{ratio_str}</span>'
            if ratio < 1.0 else
            f'<span class="badge badge-red">{ratio_str}</span>')


def _fmt_time(avg: float, error: Optional[str]) -> str:
    if _is_timeout(error):
        label = "timeout" if avg <= 0 else f"{avg:.2f} (partial)"
        return f'<span class="yellow">{label}</span>'
    if error and avg <= 0:
        return f'<span class="red">{html.escape(error)}</span>'
    if avg < 0:
        return '<span class="gray">-</span>'
    return f"{avg:.2f}"


def _classify(avg1: float, avg2: float, pct_threshold: float) -> str:
    if avg1 <= 0 or avg2 <= 0:
        return "error"
    ratio = avg2 / avg1
    if abs(ratio - 1.0) * 100 <= pct_threshold:
        return "same"
    return "better" if ratio < 1.0 else "worse"


def _github_links_html(model: str) -> str:
    """Return HTML anchor tags pointing to the model's directories on GitHub.

    Only generates real links for models resolved under sql/ (i.e. not absolute
    or relative filesystem paths).  For external paths we show plain text.
    """
    if model.startswith("/") or model.startswith("."):
        return f'<span style="font-size:.82rem;color:#555;font-family:monospace;">{html.escape(model)}</span>'
    sql_path = f"sql/{model}"
    queries_path = f"{sql_path}/queries"
    base = _GITHUB_BASE
    return (
        f'<a class="gh-link" href="{base}/{sql_path}" target="_blank" rel="noopener">'
        f'{html.escape(sql_path)}</a>'
        f'<a class="gh-link" href="{base}/{queries_path}" target="_blank" rel="noopener">'
        f'{html.escape(queries_path)}</a>'
    )


def _plan_diff_html(plan1: Optional[str], plan2: Optional[str],
                    label1: str, label2: str) -> str:
    """Render a GitHub-style unified diff between two plan texts."""
    e = html.escape
    lines1 = (plan1 or "").splitlines()
    lines2 = (plan2 or "").splitlines()

    sm = difflib.SequenceMatcher(None, lines1, lines2, autojunk=False)
    rows = []
    ln1 = ln2 = 1

    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            for l in lines1[i1:i2]:
                rows.append(
                    f"<tr class='eq'>"
                    f"<td class='ln'>{ln1}</td><td class='ln'>{ln2}</td>"
                    f"<td class='sign'>&nbsp;</td><td class='code'>{e(l)}</td>"
                    f"</tr>"
                )
                ln1 += 1; ln2 += 1
        elif tag in ("replace", "delete"):
            for l in lines1[i1:i2]:
                rows.append(
                    f"<tr class='del'>"
                    f"<td class='ln'>{ln1}</td><td class='ln'></td>"
                    f"<td class='sign'>-</td><td class='code'>{e(l)}</td>"
                    f"</tr>"
                )
                ln1 += 1
            if tag == "replace":
                for l in lines2[j1:j2]:
                    rows.append(
                        f"<tr class='ins'>"
                        f"<td class='ln'></td><td class='ln'>{ln2}</td>"
                        f"<td class='sign'>+</td><td class='code'>{e(l)}</td>"
                        f"</tr>"
                    )
                    ln2 += 1
        elif tag == "insert":
            for l in lines2[j1:j2]:
                rows.append(
                    f"<tr class='ins'>"
                    f"<td class='ln'></td><td class='ln'>{ln2}</td>"
                    f"<td class='sign'>+</td><td class='code'>{e(l)}</td>"
                    f"</tr>"
                )
                ln2 += 1

    return (
        "<div class='diff-box'>"
        "<div class='diff-header'>"
        f"<span class='diff-lbl del'>&#x2212; {e(label1)}</span>"
        f"<span class='diff-lbl ins'>&#x2b; {e(label2)}</span>"
        "</div>"
        "<table class='diff-table'><tbody>"
        + "".join(rows)
        + "</tbody></table></div>"
    )


def _detail_page_html(qr: QueryResult, label1: str, label2: str,
                      gucs_before: str, gucs_after: str) -> str:
    """Return a self-contained HTML string for the query detail page."""
    e = html.escape

    def plan_block(plan: Optional[str], label: str, gucs: str) -> str:
        if plan:
            plan_text = e(plan)
        else:
            plan_text = "<em style='color:#888'>No plan available (query may have timed out or errored)</em>"
        return (
            f"<section class='plan-section'>"
            f"<h2>{e(label)}</h2>"
            f"<div class='guc-box'><strong>GUCs applied:</strong> <code>{e(gucs)}</code></div>"
            f"<pre class='plan'>{plan_text}</pre>"
            f"</section>"
        )

    diff_html = _plan_diff_html(qr.plan1, qr.plan2, label1, label2)

    return (
        "<!DOCTYPE html>"
        "<html lang='en'><head><meta charset='UTF-8'>"
        f"<title>Query Detail \u2014 {e(qr.query_file)} Q{qr.query_index}</title>"
        "<style>"
        "*{box-sizing:border-box;}"
        "body{font-family:system-ui,sans-serif;margin:0;padding:0;background:#f5f5f5;color:#222;}"
        "header{background:#2c3e50;color:#fff;padding:14px 24px;}"
        "header h1{margin:0;font-size:1.2rem;}"
        "header p{margin:4px 0 0;font-size:.85rem;opacity:.8;}"
        ".container{padding:24px;max-width:1200px;margin:0 auto;}"
        ".box{background:#fff;border-radius:8px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.12);margin-bottom:24px;}"
        ".box h2{margin:0 0 10px;font-size:1rem;color:#2c3e50;border-bottom:2px solid #2c3e50;padding-bottom:6px;}"
        "pre.sql{font-family:monospace;font-size:.85rem;white-space:pre-wrap;word-break:break-all;"
        "background:#f4f4f4;padding:12px;border-radius:6px;border:1px solid #ddd;margin:0;max-height:300px;overflow-y:auto;}"
        ".guc-box{font-size:.8rem;color:#555;margin-bottom:10px;background:#f0f0f0;padding:6px 10px;"
        "border-radius:4px;border:1px solid #ccc;}"
        "pre.plan{font-family:monospace;font-size:.78rem;white-space:pre;overflow:auto;"
        "background:#1e1e1e;color:#d4d4d4;padding:14px;border-radius:6px;margin:0;max-height:60vh;}"
        ".plan-section{background:#fff;border-radius:8px;padding:16px;"
        "box-shadow:0 1px 3px rgba(0,0,0,.12);margin-bottom:24px;}"
        ".plan-section h2{margin:0 0 8px;font-size:1rem;color:#2c3e50;"
        "border-bottom:2px solid #2c3e50;padding-bottom:6px;}"
        ".diff-box{background:#fff;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.12);margin-bottom:24px;overflow:hidden;}"
        ".diff-header{display:flex;gap:16px;padding:8px 14px;border-bottom:1px solid #ddd;background:#f6f8fa;}"
        ".diff-lbl{font-size:.85rem;font-weight:600;font-family:monospace;}"
        ".diff-lbl.del{color:#c0392b;}"
        ".diff-lbl.ins{color:#27ae60;}"
        ".diff-table{width:100%;border-collapse:collapse;font-family:monospace;font-size:.78rem;}"
        ".diff-table td{padding:1px 6px;white-space:pre;vertical-align:top;}"
        ".diff-table td.ln{width:36px;min-width:36px;text-align:right;color:#999;user-select:none;"
        "border-right:1px solid #eee;padding-right:6px;background:#f6f8fa;}"
        ".diff-table td.sign{width:18px;min-width:18px;text-align:center;user-select:none;font-weight:700;}"
        ".diff-table td.code{width:100%;}"
        ".diff-table tr.eq td{color:#444;}"
        ".diff-table tr.del td{background:#fff0f0;}"
        ".diff-table tr.del td.sign{color:#c0392b;}"
        ".diff-table tr.del td.code{color:#c0392b;}"
        ".diff-table tr.del td.ln{background:#ffd7d7;color:#999;}"
        ".diff-table tr.ins td{background:#f0fff4;}"
        ".diff-table tr.ins td.sign{color:#1a7f37;}"
        ".diff-table tr.ins td.code{color:#1a7f37;}"
        ".diff-table tr.ins td.ln{background:#ccffd8;color:#999;}"
        "</style></head><body>"
        f"<header><h1>{e(qr.query_file)} &mdash; Q{qr.query_index}</h1>"
        f"<p>Query #{qr.query_number}</p></header>"
        "<div class='container'>"
        "<div class='box'><h2>SQL</h2>"
        f"<pre class='sql'>{e(qr.query_sql)}</pre></div>"
        "<div class='box'><h2>Plan diff &mdash; " + e(label1) + " vs " + e(label2) + "</h2>"
        + diff_html
        + "</div>"
        + plan_block(qr.plan1, label1, gucs_before)
        + plan_block(qr.plan2, label2, gucs_after)
        + "</div></body></html>"
    )


def generate_html(run: CompareRun, pct_threshold: float, num_retries: int = 0) -> str:
    total = len(run.results)
    better = worse = same = timeouts = errors = 0
    for qr in run.results:
        has_timeout = _is_timeout(qr.error1) or _is_timeout(qr.error2)
        if has_timeout:
            timeouts += 1
        else:
            cls = _classify(qr.avg1, qr.avg2, pct_threshold)
            if cls == "better":   better += 1
            elif cls == "worse":  worse  += 1
            elif cls == "same":   same   += 1
            else:                 errors += 1

    rows_html = []
    current_file = None

    for qr in run.results:
        # inject a file-group header row whenever the file changes
        if qr.query_file != current_file:
            current_file = qr.query_file
            fname_escaped = html.escape(current_file)
            rows_html.append(
                f'    <tr class="file-header">'
                f'<td colspan="5">{fname_escaped}</td></tr>'
            )

        has_timeout = _is_timeout(qr.error1) or _is_timeout(qr.error2)
        cls = _classify(qr.avg1, qr.avg2, pct_threshold)

        if has_timeout:
            row_style = 'style="background:#fefde7;"'
        elif cls == "better":
            row_style = 'style="background:#eafaf1;"'
        elif cls == "worse":
            row_style = 'style="background:#fdedec;"'
        else:
            row_style = ""

        # data-ratio for JS re-classification; data-timeout for JS yellow-lock
        ratio_val = (f"{qr.avg2 / qr.avg1:.6f}"
                     if qr.avg1 > 0 and qr.avg2 > 0 else "null")
        timeout_attr = '1' if has_timeout else '0'

        sql_escaped = html.escape(qr.query_sql)

        def _make_cell(avg: float, error: Optional[str], plan: Optional[str],
                       wall_times: List[float]) -> str:
            exec_ms = _extract_exec_ms(plan)
            if exec_ms is not None:
                return _fmt_time(avg, error)
            else:
                # Fallback: wall-clock avg when no plan available
                wall_raw = ", ".join(f"{t:.2f}" for t in wall_times) or "-"
                return (f'{_fmt_time(avg, error)}'
                        f'<br><small class="gray">wall: {wall_raw} ms</small>')

        cell1_html = _make_cell(qr.avg1, qr.error1, qr.plan1, qr.times1)
        cell2_html = _make_cell(qr.avg2, qr.error2, qr.plan2, qr.times2)
        # Store both cell contents as JSON strings so JS can swap them on invert.
        # Use single-quote-delimited attributes; json.dumps uses " so we only need to
        # escape & and ' (not "), which json.dumps never emits unescaped anyway.
        def _sq_attr(val: str) -> str:
            """JSON-encode val and make it safe for use inside a single-quoted HTML attribute."""
            return json.dumps(val).replace("&", "&amp;").replace("'", "&#x27;")

        cell1_attr = _sq_attr(cell1_html)
        cell2_attr = _sq_attr(cell2_html)

        detail_html = _detail_page_html(qr, run.label1, run.label2,
                                        run.gucs_before, run.gucs_after)
        detail_attr = _sq_attr(detail_html)

        rows_html.append(f"""\
    <tr {row_style} data-ratio="{ratio_val}" data-timeout="{timeout_attr}" data-cell1='{cell1_attr}' data-cell2='{cell2_attr}' data-detail='{detail_attr}'>
      <td>Q{qr.query_index}</td>
      <td class="time-col1">{cell1_html}</td>
      <td class="time-col2">{cell2_html}</td>
      <td class="ratio">{_ratio_badge(qr.avg1, qr.avg2, pct_threshold, has_timeout)}</td>
      <td><a onclick="openDetail(this)" style="cursor:pointer;color:#2980b9;font-size:.82rem;">open query &amp; plans &#8599;</a></td>
    </tr>""")

    return _HTML_TEMPLATE.format(
        style=_HTML_STYLE,
        model=html.escape(run.model),
        timestamp=html.escape(run.timestamp),
        total=total,
        retries=num_retries if num_retries > 0 else "(from JSON)",
        better=better,
        worse=worse,
        same=same,
        timeouts=timeouts,
        errors=errors,
        pct=f"{pct_threshold:.0f}",
        label1=html.escape(run.label1),
        label2=html.escape(run.label2),
        label1_js=json.dumps(run.label1),
        label2_js=json.dumps(run.label2),
        gucs_before=html.escape(run.gucs_before),
        gucs_after=html.escape(run.gucs_after),
        github_links=_github_links_html(run.model),
        rows="\n".join(rows_html),
    )



def _parse_args():
    parser = argparse.ArgumentParser(
        description="Compare query execution times with two sets of GUC settings",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument("--model", default="basic",
                        help="Test model name (sql/<model>/queries/) or absolute/relative path")
    parser.add_argument("--gucs", default="{}",
                        help=(
                            'JSON object mapping GUC name to [before_value, after_value]. '
                            'Example: \'{"enable_seqscan": ["on", "off"], "work_mem": ["64MB", "256MB"]}\''
                        ))
    parser.add_argument("--label1", default="Before",
                        help="Human-readable name for the before/run-1 GUC set")
    parser.add_argument("--label2", default="After",
                        help="Human-readable name for the after/run-2 GUC set")

    # ---- DDL ----
    parser.add_argument("--ddl", action="store_true",
                        help="Run DDL steps before executing queries")
    parser.add_argument("--ddl-steps", default="drop,create,import,analyze",
                        help="Comma-separated DDL steps to run (default: drop,create,import,analyze)")
    parser.add_argument("--ddl-timeout-s", default=7200, type=int,
                        help="statement_timeout for DDL statements in seconds (default 7200)")
    parser.add_argument("--ddl-prefix", default="",
                        help="File prefix for DDL files, e.g. 'postgres' uses postgres.create.sql")
    parser.add_argument("--data-path", default=".",
                        help="Path substituted for $DATA_PATH in DDL files (default: .)")

    # ---- connection ----
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default=5433, type=int)
    parser.add_argument("--username", default="yugabyte")
    parser.add_argument("--password", default="yugabyte")
    parser.add_argument("--database", default=None,
                        help="Database name to connect to (required unless --from-json is used)")

    # ---- execution ----
    parser.add_argument("--num-retries", default=3, type=int,
                        help="Number of timed iterations per query per GUC set (default 3)")
    parser.add_argument("--timeout-ms", default=180000, type=int,
                        help="statement_timeout for test queries in ms (default 180000 = 180s, 0 = disabled)")
    parser.add_argument("--num-queries", default=-1, type=int,
                        help="Limit total number of individual statements to run (debug; -1 = all)")
    parser.add_argument("--pct-threshold", default=5.0, type=float,
                        help="Percentage difference below which runs are considered equal (default 5)")

    # ---- output ----
    parser.add_argument("--output", default="report/guc_compare",
                        help="Output base path (no extension). .json and .html will be written.")
    parser.add_argument("--from-json",
                        help="Skip collection, regenerate HTML from an existing JSON result file")

    # ---- misc ----
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--yes", action="store_true",
                        help="Skip confirmation prompt")

    return parser.parse_args()


def main():
    args = _parse_args()
    logger = _init_logger(args.verbose)

    if args.from_json:
        logger.info(f"Loading results from {args.from_json} ...")
        run = _load_json(args.from_json)
        html_content = generate_html(run, args.pct_threshold)
        html_path = args.output.removesuffix(".json") + ".html" if args.output != "report/guc_compare" else args.from_json.removesuffix(".json") + ".html"
        os.makedirs(os.path.dirname(os.path.abspath(html_path)), exist_ok=True)
        Path(html_path).write_text(html_content, encoding="utf-8")
        logger.info(f"Report written to {os.path.abspath(html_path)}")
        return

    if not args.database:
        print("ERROR: --database is required unless --from-json is used.", file=sys.stderr)
        sys.exit(1)

    try:
        gucs = parse_gucs(args.gucs)
    except ValueError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    if args.ddl:
        try:
            _parse_ddl_steps(args.ddl_steps)   # validate early
        except ValueError as e:
            print(f"ERROR: {e}", file=sys.stderr)
            sys.exit(1)

    logger.info("------------------------------------------------------------")
    logger.info("GUC Comparison - Query Timing Framework")
    logger.info(f"  Model     : {args.model}")
    logger.info(f"  Label 1   : {args.label1}")
    logger.info(f"  Label 2   : {args.label2}")
    for name, (before, after) in gucs.items():
        logger.info(f"  {name:30s}  before={before!r:15}  after={after!r}")
    if args.ddl:
        logger.info(f"  DDL steps : {args.ddl_steps}")
    logger.info(f"  DB        : {args.username}@{args.host}:{args.port}/{args.database}")
    logger.info(f"  Retries   : {args.num_retries} per GUC set")
    logger.info(f"  Timeout   : {args.timeout_ms} ms")
    logger.info(f"  Threshold : +/-{args.pct_threshold}%")
    logger.info(f"  Output    : {args.output}.[json|html]")
    logger.info("------------------------------------------------------------")

    if not args.yes:
        input("Validate configuration carefully and press Enter to start ...")

    try:
        run = run_comparison(args, gucs, logger)
    except Exception:
        traceback.print_exc()
        sys.exit(1)

    json_path = args.output.removesuffix(".json") + ".json"
    _save_json(run, json_path)
    logger.info(f"Raw results saved to {os.path.abspath(json_path)}")

    html_path = args.output.removesuffix(".json") + ".html"
    os.makedirs(os.path.dirname(os.path.abspath(html_path)), exist_ok=True)
    Path(html_path).write_text(
        generate_html(run, args.pct_threshold, args.num_retries), encoding="utf-8")
    logger.info(f"Report written to {os.path.abspath(html_path)}")

    total  = len(run.results)
    better = sum(1 for r in run.results if _classify(r.avg1, r.avg2, args.pct_threshold) == "better")
    worse  = sum(1 for r in run.results if _classify(r.avg1, r.avg2, args.pct_threshold) == "worse")
    same   = sum(1 for r in run.results if _classify(r.avg1, r.avg2, args.pct_threshold) == "same")
    logger.info("------------------------------------------------------------")
    logger.info(
        f"Done.  {total} queries | "
        f"{better} faster with '{args.label2}' | "
        f"{worse} slower | "
        f"{same} within +/-{args.pct_threshold}% | "
        f"{total - better - worse - same} error(s)"
    )
    logger.info("------------------------------------------------------------")


if __name__ == "__main__":
    main()
