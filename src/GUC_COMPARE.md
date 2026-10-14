# guc_compare — GUC Comparison Tool

Runs a set of SQL queries twice — once with a "before" GUC configuration and once
with an "after" configuration — and produces a self-contained HTML report comparing
execution times side by side.

Times are taken from `EXPLAIN (ANALYZE, BUFFERS)` execution time, which reflects
actual DB engine time rather than client-side wall-clock.

---

## Prerequisites

```bash
pip install psycopg2-binary sqlparse
```

---

## Important: Run DDL First

**DDL is disabled by default.** The script assumes the schema and data already exist.
If the target database is empty or stale, pass `-D` (shell wrapper) or `--ddl`
(Python) to run the model's `drop.sql → create.sql → import.sql → analyze.sql`
sequence before querying. Skipping this on a fresh database will produce errors or
meaningless results.

---

## Quick Start

### Using the shell wrapper

```bash
bin/guc-compare.sh \
  -m cost-validation-parallel-query \
  -d taqo_pq \
  -g '{"max_parallel_workers_per_gather": ["2", "0"]}' \
  -L "PQ (2 workers)" \
  -R "No PQ" \
  -D \
  -y
```

This will:
1. Drop, recreate, import, and analyze the schema (`-D`)
2. Run every query in `sql/cost-validation-parallel-query/queries/` twice — once with
   `max_parallel_workers_per_gather = 2` and once with `= 0`
3. Write `report/guc_compare.json` and open `report/guc_compare.html`

### Using the Python script directly (recommended)

```bash
python3 src/guc_compare.py \
  --model cost-validation-parallel-query \
  --database taqo_pq \
  --gucs '{"max_parallel_workers_per_gather": ["2", "0"]}' \
  --label1 "PQ (2 workers)" \
  --label2 "No PQ" \
  --ddl \
  --output report/pq_check \
  --yes
```
Or with you host on custom version
```bash
python3 src/guc_compare.py \
  --model cost-validation-parallel-query \
  --num-retries 1 \
  --database postgres \
  --gucs '{"max_parallel_workers_per_gather": [2, 0]}' \
  --label1 "PQ" \
  --label2 "No PQ" \
  --output report/pq_check_queries \
  --yes \
  --host <host_ip> \
  --timeout-ms 20000
```

---

## Example: Parallel Query vs No Parallel Query

```bash
bin/guc-compare.sh \
  -m cost-validation-parallel-query \
  -d taqo_pq \
  -g '{"max_parallel_workers_per_gather": ["2", "0"]}' \
  -L "PQ" \
  -R "No PQ" \
  -D \
  -r 3 \
  -t 20000 \
  -o report/pq_check \
  -y
```

Sample output (truncated):

```
[1/5] single_table.sql query 1
  Running with [PQ] ...
    avg=41.47 ms  raw=[42.1, 41.2, 41.1]
  Running with [No PQ] ...
    avg=325.34 ms  raw=[326.1, 325.0, 324.9]
  Fetching EXPLAIN ANALYZE for both GUC sets ...
    [PQ] EXPLAIN ANALYZE exec=41.47 ms
    [No PQ] EXPLAIN ANALYZE exec=325.34 ms
...
Done. 22 queries | 18 faster with 'No PQ' | 4 slower | 0 within +/-5%
Report written to report/pq_check.html
```

---

## Example: Comparing work_mem settings

```bash
bin/guc-compare.sh \
  -m cost-validation-parallel-query \
  -d taqo_pq \
  -g '{"work_mem": ["16MB", "256MB"]}' \
  -L "16MB work_mem" \
  -R "256MB work_mem" \
  -r 3 \
  -o report/work_mem_check \
  -y
```

---

## Example: Multiple GUCs at once

```bash
python3 src/guc_compare.py \
  --model cost-validation-parallel-query \
  --database taqo_pq \
  --gucs '{"max_parallel_workers_per_gather": ["2","0"], "work_mem": ["16MB","256MB"]}' \
  --label1 "PQ + 16MB" \
  --label2 "No PQ + 256MB" \
  --output report/combined \
  --yes
```

---

## Regenerating the HTML from saved results

If you already have a `.json` result file and just want to update the report
(e.g. after a code change), no database connection is needed:

```bash
python3 src/guc_compare.py \
  --from-json report/pq_check.json \
  --output report/pq_check
```
Or alternatively with a default threshold value for comparison of before/after
```bash
python3 src/guc_compare.py --from-json report/pq_check_tmp.json --output report/pq_check_tmp --pct-threshold 200
```

---

## HTML Report Features

- **Summary cards** — total queries, faster, slower, within threshold, timeouts, errors
- **Regression threshold selector** — adjust the % threshold live; rows recolour instantly
- **Invert comparison** button — swap which side is the baseline; ratios become 1/ratio
- **Row colours** — green (faster), red (slower), yellow (timeout)
- **GitHub links** — direct links to the model's `sql/` and `queries/` directories
- **Query detail page** — click "open query & plans ↗" on any row to open a new tab with:
  - The SQL
  - A unified diff of the two EXPLAIN ANALYZE plans (red = removed lines, green = added)
  - Full plan for each GUC set

---

## All Options

| Flag (shell) | Flag (Python) | Default | Description |
|---|---|---|---|
| `-m` | `--model` | `basic` | Model name under `sql/` or absolute path |
| `-d` | `--database` | *(required)* | Database to connect to |
| `-g` | `--gucs` | `{}` | JSON: `{"guc": ["before", "after"]}` |
| `-L` | `--label1` | `Before` | Label for the before GUC set |
| `-R` | `--label2` | `After` | Label for the after GUC set |
| `-D` | `--ddl` | off | Run DDL before querying (**recommended on fresh DB**) |
| `-S` | `--ddl-steps` | `drop,create,import,analyze` | Which DDL steps to run |
| `-T` | `--ddl-timeout-s` | `7200` | Timeout for DDL statements (seconds) |
| `-x` | `--ddl-prefix` | *(none)* | DDL file prefix, e.g. `postgres` → `postgres.create.sql` |
| `-X` | `--data-path` | `.` | Path substituted for `$DATA_PATH` in DDL files |
| `-H` | `--host` | `127.0.0.1` | DB host |
| `-p` | `--port` | `5433` | DB port |
| `-u` | `--username` | `yugabyte` | DB username |
| `-P` | `--password` | `yugabyte` | DB password |
| `-r` | `--num-retries` | `3` | Timed iterations per query per GUC set |
| `-t` | `--timeout-ms` | `180000` | Per-query statement timeout in ms (0 = off) |
| `-n` | `--num-queries` | `-1` | Limit total queries run (-1 = all) |
| `-o` | `--output` | `report/guc_compare` | Output base path (`.json` and `.html` appended) |
| | `--from-json` | *(none)* | Regenerate HTML from an existing JSON file |
| | `--pct-threshold` | `5.0` | % difference below which runs are considered equal |
| `-v` | `--verbose` | off | Debug logging |
| `-y` | `--yes` | off | Skip confirmation prompt |

---

## How Times Are Measured

Displayed execution times come from `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)` —
the `Execution Time` line that PostgreSQL/YugabyteDB reports at the bottom of the
plan. This is pure DB-engine time and excludes network transfer and client overhead.

When `--num-retries N` is set, the query is executed N times for timing, then
EXPLAIN ANALYZE is run once more to collect the plan. The displayed value is the
single EXPLAIN ANALYZE execution time from that final run, not an average of
multiple EXPLAIN ANALYZE runs.

Wall-clock timings from the timed iterations are saved in the JSON (`times1`,
`times2`) for reference but are not used in the report when a plan is available.
