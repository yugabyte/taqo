SELECT
    n.nspname  AS schema_name,
    c.relname  AS index_name,
    yb_index_check(c.oid) AS check_result
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'i'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema');
