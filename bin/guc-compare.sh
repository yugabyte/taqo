#!/usr/bin/env bash
# guc-compare.sh — Run queries with two GUC configurations and produce an HTML report.
#
# Usage:
#   bin/guc-compare.sh -m <model> -d <database> \
#       -g '{"enable_seqscan":["on","off"],"work_mem":["64MB","256MB"]}' \
#       [-L "Before label"] [-R "After label"] \
#       [-D] [-S drop,create,import,analyze] [-T ddl_timeout_s] \
#       [-x ddl_prefix] [-X data_path] \
#       [-H host] [-p port] [-u user] [-P password] \
#       [-r num_retries] [-t timeout_ms] [-n num_queries] \
#       [-o output_base] [-v] [-y]
#
# Options:
#   -m  model name (sql/<model>/queries/) or path              [required]
#   -d  database name                                          [required]
#   -g  GUC map JSON: {"guc": ["before", "after"], ...}       [required]
#   -L  label for the "before" GUC set   (default: "Before")
#   -R  label for the "after"  GUC set   (default: "After")
#   -D  run DDL before querying (drop/create/import/analyze)
#   -S  DDL steps to run, comma-separated (default: drop,create,import,analyze)
#   -T  DDL statement timeout in seconds (default: 7200)
#   -x  DDL file prefix, e.g. "postgres" uses postgres.create.sql if present
#   -X  path substituted for $DATA_PATH in DDL files (default: .)
#   -H  host                             (default: 127.0.0.1)
#   -p  port                             (default: 5433)
#   -u  username                         (default: yugabyte)
#   -P  password                         (default: yugabyte)
#   -r  retries per query per GUC set    (default: 3)
#   -t  query statement timeout in ms, 0=off (default: 180000)
#   -n  number of queries to run, -1=all (default: -1)
#   -o  output base path                 (default: report/guc_compare)
#   -v  verbose / debug logging
#   -y  skip confirmation prompt

set -euo pipefail

# ---- defaults ----
MODEL=""
DATABASE=""
GUCS="{}"
LABEL1="Before"
LABEL2="After"
RUN_DDL=""
DDL_STEPS="drop,create,import,analyze"
DDL_TIMEOUT_S=7200
DDL_PREFIX=""
DATA_PATH="."
HOST="127.0.0.1"
PORT=5433
USERNAME="yugabyte"
PASSWORD="yugabyte"
NUM_RETRIES=3
TIMEOUT_MS=180000
NUM_QUERIES=-1
OUTPUT="report/guc_compare"
VERBOSE=""
YES=""

usage() {
    grep '^#' "$0" | grep -v '^#!/' | sed 's/^# \{0,1\}//'
    exit 1
}

while getopts ":m:d:g:L:R:DS:T:x:X:H:p:u:P:r:t:n:o:vy" opt; do
    case $opt in
        m) MODEL="$OPTARG" ;;
        d) DATABASE="$OPTARG" ;;
        g) GUCS="$OPTARG" ;;
        L) LABEL1="$OPTARG" ;;
        R) LABEL2="$OPTARG" ;;
        D) RUN_DDL="1" ;;
        S) DDL_STEPS="$OPTARG" ;;
        T) DDL_TIMEOUT_S="$OPTARG" ;;
        x) DDL_PREFIX="$OPTARG" ;;
        X) DATA_PATH="$OPTARG" ;;
        H) HOST="$OPTARG" ;;
        p) PORT="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        P) PASSWORD="$OPTARG" ;;
        r) NUM_RETRIES="$OPTARG" ;;
        t) TIMEOUT_MS="$OPTARG" ;;
        n) NUM_QUERIES="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        v) VERBOSE="1" ;;
        y) YES="--yes" ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
        :)  echo "Option -$OPTARG requires an argument" >&2; usage ;;
    esac
done

if [[ -z "$MODEL" || -z "$DATABASE" || "$GUCS" == "{}" ]]; then
    echo "ERROR: -m (model), -d (database), and -g (gucs JSON) are required." >&2
    usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

echo "================================================================"
echo " GUC Comparison"
echo "================================================================"
echo " Model    : $MODEL"
echo " Database : $DATABASE"
echo " GUCs     : $GUCS"
echo " Label 1  : $LABEL1  (before values)"
echo " Label 2  : $LABEL2  (after values)"
if [[ -n "${RUN_DDL:-}" ]]; then
echo " DDL      : $DDL_STEPS (timeout ${DDL_TIMEOUT_S}s)"
fi
echo " Retries  : $NUM_RETRIES per GUC set"
echo " Output   : ${OUTPUT}.html"
echo "================================================================"

python3 src/guc_compare.py \
    --model        "$MODEL" \
    --database     "$DATABASE" \
    --gucs         "$GUCS" \
    --label1       "$LABEL1" \
    --label2       "$LABEL2" \
    --ddl-steps    "$DDL_STEPS" \
    --ddl-timeout-s "$DDL_TIMEOUT_S" \
    --ddl-prefix   "$DDL_PREFIX" \
    --data-path    "$DATA_PATH" \
    --host         "$HOST" \
    --port         "$PORT" \
    --username     "$USERNAME" \
    --password     "$PASSWORD" \
    --num-retries  "$NUM_RETRIES" \
    --timeout-ms   "$TIMEOUT_MS" \
    --num-queries  "$NUM_QUERIES" \
    --output       "$OUTPUT" \
    ${RUN_DDL:+--ddl} \
    ${VERBOSE:+--verbose} \
    ${YES:+--yes}

echo ""
echo "Done! Report: $(realpath "${OUTPUT}.html" 2>/dev/null || echo "${OUTPUT}.html")"
