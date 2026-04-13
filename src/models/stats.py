"""
Statistics dump and load for TAQO models.

Ported from cbo_stat_dump/cbo_stat_load tools. Allows hardcoding
pg_class and pg_statistic data into a model's statistics.json so that
query optimizer stats are deterministic across environments.
"""

import json
import logging

from utils import evaluate_sql

logger = logging.getLogger("taqo")

# Column type mappings for pg_statistic INSERT generation.
# Order MUST match pg_statistic column order exactly (positional INSERT).
_COLUMN_TYPES_BEFORE_STACOLL = {
    "stainherit": "boolean",
    "stanullfrac": "real",
    "stawidth": "integer",
    "stadistinct": "real",
    "stakind1": "smallint", "stakind2": "smallint",
    "stakind3": "smallint", "stakind4": "smallint", "stakind5": "smallint",
    "staop1": "oid", "staop2": "oid",
    "staop3": "oid", "staop4": "oid", "staop5": "oid",
}

_STACOLL_COLUMNS = {
    "stacoll1": "oid", "stacoll2": "oid",
    "stacoll3": "oid", "stacoll4": "oid", "stacoll5": "oid",
}

_COLUMN_TYPES_AFTER_STACOLL = {
    "stanumbers1": "real[]", "stanumbers2": "real[]",
    "stanumbers3": "real[]", "stanumbers4": "real[]", "stanumbers5": "real[]",
}


def _has_stacoll(cur):
    """Check if pg_statistic has stacoll columns (PG >= 15)."""
    evaluate_sql(cur, """
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'pg_catalog'
          AND table_name = 'pg_statistic'
          AND column_name = 'stacoll1'
    """)
    return cur.fetchone() is not None


def _is_yugabyte(cur):
    """Check if the database is YugabyteDB."""
    try:
        evaluate_sql(cur, "SELECT VERSION()")
        version_str = cur.fetchone()[0]
        return "yugabyte" in version_str.lower()
    except Exception:
        return False


def _format_stavalues_element(val, column_type):
    """Format a single stavalues array element for SQL."""
    if val is None:
        return "NULL"

    if isinstance(val[0], str):
        escaped = [
            '"%s"' % e.replace('\\', '\\\\').replace('"', '\\"').replace("'", "''")
            for e in val
        ]
        sql_array = ', '.join(escaped)
    elif isinstance(val[0], dict):
        escaped = [
            '"%s"' % str(e).replace('"', '\\\\\\\\"').replace("'", '\\"')
                .replace('True', 'true').replace('False', 'false')
            for e in val
        ]
        sql_array = ', '.join(escaped)
    else:
        sql_array = ', '.join(str(e) for e in val)

    return f"array_in('{{{sql_array}}}', '{column_type}'::regtype, -1)::anyarray"


def _build_pg_statistic_insert(stat_json, has_stacoll):
    """Build DELETE+INSERT SQL for one pg_statistic row."""
    # Build in correct pg_statistic column order:
    # starelid, staattnum, stainherit..staop5, [stacoll1-5 if PG>=15], stanumbers1-5, stavalues1-5
    column_types = dict(_COLUMN_TYPES_BEFORE_STACOLL)
    if has_stacoll:
        column_types.update(_STACOLL_COLUMNS)
    column_types.update(_COLUMN_TYPES_AFTER_STACOLL)

    # Determine stavalues type from the column's actual type
    typnspname = stat_json.get('typnspname', 'pg_catalog')
    stavalues_type = f"{typnspname}.{stat_json['typname']}"
    for i in range(1, 6):
        column_types[f"stavalues{i}"] = stavalues_type

    column_values = ""
    for col_name, col_type in column_types.items():
        val = stat_json[col_name]

        if col_name.startswith('stavalues'):
            sql_val = _format_stavalues_element(val, col_type)
        elif isinstance(val, list):
            # real[] arrays (stanumbers)
            inner = str(val)[1:-1]
            sql_val = f"'{{{inner}}}'::{col_type}"
        elif val is None:
            sql_val = f"NULL::{col_type}"
        else:
            sql_val = f"{val}::{col_type}"

        column_values += ", " + sql_val

    starelid = f"'{stat_json['nspname']}.{stat_json['relname']}'::regclass"
    staattnum = (
        f"(SELECT a.attnum FROM pg_attribute a "
        f"WHERE a.attrelid = {starelid} AND a.attname = '{stat_json['attname']}')"
    )

    return (
        f"DELETE FROM pg_statistic WHERE starelid = {starelid} AND staattnum = {staattnum};\n"
        f"INSERT INTO pg_statistic VALUES ({starelid}, {staattnum}{column_values});\n"
    )


def _has_pg_statistic_ext(cur):
    """Check if pg_statistic_ext table exists and has entries for user tables."""
    try:
        evaluate_sql(cur, """
            SELECT 1 FROM pg_statistic_ext s
            JOIN pg_namespace n ON s.stxnamespace = n.oid
            WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
            LIMIT 1
        """)
        return cur.fetchone() is not None
    except Exception:
        return False


def _dump_extended_statistics(cur, schema):
    """Dump pg_statistic_ext and pg_statistic_ext_data."""
    # pg_statistic_ext metadata
    evaluate_sql(cur, f"""
        SELECT row_to_json(t) FROM
            (SELECT c.relname, s.stxname, n.nspname, s.stxowner, s.stxstattarget,
                    string_agg(a.attname, ',') as stxkeys, s.stxkind, s.stxexprs
             FROM pg_class c
                 JOIN pg_statistic_ext s ON c.oid = s.stxrelid
                 JOIN pg_attribute a ON c.oid = a.attrelid AND a.attnum = ANY(s.stxkeys)
                 JOIN pg_namespace n ON c.relnamespace = n.oid
             WHERE n.nspname = '{schema}'
             GROUP BY c.relname, s.stxname, n.nspname, s.stxowner, s.stxstattarget, s.stxkind, s.stxexprs) t
    """)
    pg_statistic_ext = [row[0] for row in cur.fetchall()]

    # pg_statistic_ext_data (actual stats data)
    evaluate_sql(cur, f"""
        SELECT row_to_json(t) FROM
            (SELECT s.stxname, d.stxdinherit,
                    d.stxdndistinct::bytea, d.stxddependencies::bytea, d.stxdmcv::bytea,
                    d.stxdexpr
             FROM pg_statistic_ext s
                 JOIN pg_statistic_ext_data d ON s.oid = d.stxoid
                 JOIN pg_namespace n ON s.stxnamespace = n.oid
             WHERE n.nspname = '{schema}') t
    """)
    pg_statistic_ext_data = [row[0] for row in cur.fetchall()]

    return pg_statistic_ext, pg_statistic_ext_data


def _build_pg_statistic_ext_data_insert(row_json):
    """Build DELETE+INSERT SQL for one pg_statistic_ext_data row."""
    stxname = row_json['stxname']
    stxoid_subquery = f"(SELECT oid FROM pg_statistic_ext WHERE stxname='{stxname}')"

    stxdndistinct = (f"'{row_json['stxdndistinct']}'::bytea"
                     if row_json['stxdndistinct'] is not None else 'NULL')
    stxddependencies = (f"'{row_json['stxddependencies']}'::bytea"
                        if row_json['stxddependencies'] is not None else 'NULL')
    stxdmcv = (f"'{row_json['stxdmcv']}'::bytea"
               if row_json['stxdmcv'] is not None else 'NULL')

    stxdexpr = row_json.get('stxdexpr')
    if stxdexpr is not None:
        value_str = "ARRAY["
        for statistic in stxdexpr:
            value_str += '('
            for key, value in statistic.items():
                if value is None:
                    value_str += 'NULL, '
                elif isinstance(value, list):
                    if key.startswith('stanumbers'):
                        value_str += f"ARRAY[{','.join(map(str, value))}]::real[], "
                    elif key.startswith('stavalues'):
                        value_str += f"array_in('{{{','.join(map(str, value))}}}', 'pg_catalog.int4'::regtype, -1)::anyarray, "
                else:
                    value_str += f"'{value}', "
            value_str = value_str[:-2] + '), '
        value_str = value_str[:-2] + ']::pg_statistic[]'
        stxdexpr_sql = value_str
    else:
        stxdexpr_sql = 'NULL'

    return (
        f"DELETE FROM pg_statistic_ext_data WHERE stxoid = {stxoid_subquery};\n"
        f"INSERT INTO pg_statistic_ext_data VALUES ("
        f"{stxoid_subquery}, {row_json['stxdinherit']}, "
        f"{stxdndistinct}, {stxddependencies}, {stxdmcv}, {stxdexpr_sql});\n"
    )


def dump_statistics(cur, output_path, schema='public'):
    """Dump pg_class, pg_statistic, and extended statistics to a JSON file.

    Args:
        cur: database cursor
        output_path: path to write statistics.json
        schema: schema to dump stats from (default 'public')
    """
    has_stacoll = _has_stacoll(cur)

    # Dump pg_class
    evaluate_sql(cur, f"""
        SELECT row_to_json(t) FROM
            (SELECT c.relname, c.relpages, c.reltuples, c.relallvisible, n.nspname
             FROM pg_class c
             JOIN pg_namespace n ON c.relnamespace = n.oid
             WHERE n.nspname = '{schema}'
               AND c.relkind IN ('r', 'i')) t
    """)
    pg_class_rows = [row[0] for row in cur.fetchall()]

    # Dump pg_statistic
    stacoll_columns = """
        s.stacoll1, s.stacoll2, s.stacoll3, s.stacoll4, s.stacoll5,
    """ if has_stacoll else ""

    evaluate_sql(cur, f"""
        SELECT row_to_json(t) FROM
            (SELECT
                n.nspname, c.relname, a.attname,
                (SELECT nspname FROM pg_namespace WHERE oid = tp.typnamespace) typnspname,
                tp.typname,
                s.stainherit, s.stanullfrac, s.stawidth, s.stadistinct,
                s.stakind1, s.stakind2, s.stakind3, s.stakind4, s.stakind5,
                s.staop1, s.staop2, s.staop3, s.staop4, s.staop5,
                {stacoll_columns}
                s.stanumbers1, s.stanumbers2, s.stanumbers3, s.stanumbers4, s.stanumbers5,
                s.stavalues1, s.stavalues2, s.stavalues3, s.stavalues4, s.stavalues5
             FROM pg_class c
                 JOIN pg_namespace n ON c.relnamespace = n.oid
                 JOIN pg_statistic s ON s.starelid = c.oid
                 JOIN pg_attribute a ON c.oid = a.attrelid AND s.staattnum = a.attnum
                 JOIN pg_type tp ON a.atttypid = tp.oid
             WHERE n.nspname = '{schema}') t
    """)
    pg_statistic_rows = [row[0] for row in cur.fetchall()]

    statistics = {
        "has_stacoll": has_stacoll,
        "pg_class": pg_class_rows,
        "pg_statistic": pg_statistic_rows,
    }

    # Dump extended statistics if any exist
    if _has_pg_statistic_ext(cur):
        pg_stat_ext, pg_stat_ext_data = _dump_extended_statistics(cur, schema)
        statistics["pg_statistic_ext"] = pg_stat_ext
        statistics["pg_statistic_ext_data"] = pg_stat_ext_data
        logger.info(f"Dumped {len(pg_stat_ext_data)} extended statistics entries")

    with open(output_path, 'w') as f:
        json.dump(statistics, f, indent=2)

    logger.info(f"Dumped statistics for {len(pg_class_rows)} relations and "
                f"{len(pg_statistic_rows)} column stats to {output_path}")


def load_statistics(cur, stats_path):
    """Load statistics from a JSON file into the database.

    Executes UPDATE pg_class and DELETE/INSERT pg_statistic
    to set hardcoded optimizer statistics.

    Args:
        cur: database cursor
        stats_path: path to statistics.json file
    """
    with open(stats_path, 'r') as f:
        statistics = json.load(f)

    is_yb = _is_yugabyte(cur)
    has_stacoll = statistics.get("has_stacoll", False)

    if is_yb:
        evaluate_sql(cur, "SET yb_non_ddl_txn_for_sys_tables_allowed = ON")

    # Update pg_class (reltuples, relpages, relallvisible)
    for row in statistics['pg_class']:
        query = (
            f"UPDATE pg_class SET "
            f"reltuples = {row['reltuples']}, "
            f"relpages = {row['relpages']}, "
            f"relallvisible = {row['relallvisible']} "
            f"WHERE relnamespace = '{row['nspname']}'::regnamespace "
            f"AND (relname = '{row['relname']}' OR relname = '{row['relname']}_pkey')"
        )
        evaluate_sql(cur, query)

    logger.info(f"Updated pg_class for {len(statistics['pg_class'])} relations")

    # Update pg_statistic (DELETE + INSERT per column)
    for row in statistics['pg_statistic']:
        query = _build_pg_statistic_insert(row, has_stacoll)
        for stmt in query.strip().split('\n'):
            if stmt.strip():
                evaluate_sql(cur, stmt)

    logger.info(f"Loaded {len(statistics['pg_statistic'])} column statistics")

    # Load extended statistics if present
    if 'pg_statistic_ext_data' in statistics:
        for row in statistics['pg_statistic_ext_data']:
            query = _build_pg_statistic_ext_data_insert(row)
            for stmt in query.strip().split('\n'):
                if stmt.strip():
                    evaluate_sql(cur, stmt)
        logger.info(f"Loaded {len(statistics['pg_statistic_ext_data'])} extended statistics entries")

    if is_yb:
        evaluate_sql(cur, "UPDATE pg_yb_catalog_version SET current_version=current_version+1 WHERE db_oid=1")
        evaluate_sql(cur, "SET yb_non_ddl_txn_for_sys_tables_allowed = OFF")
