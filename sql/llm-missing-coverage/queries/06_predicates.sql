SELECT c_int, c_text
FROM lmc_small
WHERE c_text LIKE 'val!_1%' ESCAPE '!'
ORDER BY c_int
LIMIT 10;

SELECT count(*)
FROM lmc_small
WHERE c_text NOT LIKE 'val#_9%' ESCAPE '#';

SELECT c_int
FROM lmc_small
WHERE c_text ILIKE 'VAL_2_'
ORDER BY 1;

SELECT c_int
FROM lmc_small
WHERE c_text ILIKE 'VAL$_3_' ESCAPE '$'
ORDER BY 1;

SELECT count(*)
FROM lmc_small
WHERE c_text NOT ILIKE 'VAL_1%';

SELECT count(*)
FROM lmc_small
WHERE c_text NOT ILIKE 'VAL^_1%' ESCAPE '^';

SELECT c_int
FROM lmc_small
WHERE c_text SIMILAR TO 'val\_(1|2)[0-9]'
ORDER BY 1;

SELECT c_int
FROM lmc_small
WHERE c_text SIMILAR TO 'val#_(3|4)0' ESCAPE '#'
ORDER BY 1;

SELECT count(*)
FROM lmc_small
WHERE c_text NOT SIMILAR TO 'val\_[0-9]{3}';

SELECT count(*)
FROM lmc_small
WHERE c_text NOT SIMILAR TO 'val!_[1-5]%' ESCAPE '!';

SELECT count(*) FILTER (WHERE c_nullable ISNULL) AS nulls,
       count(*) FILTER (WHERE c_nullable NOTNULL) AS not_nulls
FROM lmc_main;

SELECT count(*) FILTER (WHERE c_bool IS TRUE) AS t,
       count(*) FILTER (WHERE c_bool IS NOT TRUE) AS nt,
       count(*) FILTER (WHERE (c_nullable > 500) IS FALSE) AS f,
       count(*) FILTER (WHERE (c_nullable > 500) IS NOT FALSE) AS nf,
       count(*) FILTER (WHERE (c_nullable > 500) IS UNKNOWN) AS u,
       count(*) FILTER (WHERE (c_nullable > 500) IS NOT UNKNOWN) AS nu
FROM lmc_main;

SELECT count(*)
FROM lmc_main a
         JOIN lmc_small b ON a.c_int = b.c_int
WHERE a.c_nullable IS DISTINCT FROM b.c_grp;

SELECT a.c_int
FROM lmc_main a
         JOIN lmc_small b ON a.c_nullable IS NOT DISTINCT FROM b.c_int
WHERE a.c_int < 3000
ORDER BY 1
LIMIT 20;

SELECT count(*)
FROM lmc_main
WHERE c_int NOT BETWEEN 100 AND 9000;

SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN SYMMETRIC 500 AND 100;

SELECT count(*)
FROM lmc_main
WHERE c_int NOT BETWEEN SYMMETRIC 9000 AND 200;

SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN ASYMMETRIC 10 AND 20;

SELECT a.c_int, b.c_int
FROM lmc_main a
         JOIN lmc_main b ON (a.c_ts, a.c_ts + interval '3 hours') OVERLAPS (b.c_ts, b.c_ts + interval '1 hour')
WHERE a.c_int = 50
  AND b.c_int BETWEEN 40 AND 60
ORDER BY 2;

SELECT count(*)
FROM lmc_main
WHERE (c_date, interval '10 days') OVERLAPS (date '2024-03-01', date '2024-03-05');

SELECT c_int
FROM lmc_small
WHERE (c_int, c_grp) > (950, 0)
ORDER BY 1
LIMIT 10;

SELECT c_int
FROM lmc_small
WHERE ROW (c_int, c_grp) = ROW (42, 42);

SELECT c_int
FROM lmc_small
WHERE (c_int, c_grp) IN ((1, 1), (2, 2), (3, 30))
ORDER BY 1;

SELECT c_int
FROM lmc_small
WHERE ROW (c_int % 10, c_grp) IN (SELECT c_grp, c_int FROM lmc_tree WHERE c_int < 10)
ORDER BY 1;

SELECT c_int
FROM lmc_small
WHERE c_text LIKE ANY (ARRAY ['val_11', 'val_2_'])
ORDER BY 1;

SELECT count(*)
FROM lmc_small
WHERE c_text NOT LIKE ALL (ARRAY ['val_1%', 'val_2%']);

SELECT c_int
FROM lmc_small
WHERE c_text ILIKE SOME (ARRAY ['VAL_77', 'VAL_88'])
ORDER BY 1;

SELECT count(*)
FROM lmc_small
WHERE c_text NOT ILIKE ANY (SELECT 'VAL_%');

SELECT c_int
FROM lmc_small
WHERE c_int OPERATOR(pg_catalog.=) ANY (ARRAY [5, 6, 7])
ORDER BY 1;

SELECT c_int
FROM lmc_small
WHERE c_int > ALL (SELECT c_grp FROM lmc_small WHERE c_int < 50)
  AND c_int < SOME (SELECT c_int FROM lmc_tree WHERE c_int < 105)
  AND c_int <> ALL (ARRAY [101, 102])
ORDER BY 1;

SELECT count(*)
FROM lmc_main
WHERE c_float = ANY (SELECT c_int * 0.25 FROM lmc_small WHERE c_int % 10 = 0);

SELECT count(*)
FROM lmc_main m
WHERE NOT EXISTS (SELECT 1 FROM lmc_small s WHERE s.c_int = m.c_int)
  AND m.c_int NOT IN (SELECT c_int FROM lmc_tree WHERE c_int > 5000);

SELECT c_int
FROM lmc_small
WHERE c_text COLLATE "C" < 'val_101'
ORDER BY c_text COLLATE "C"
LIMIT 10;

SELECT count(*)
FROM lmc_main
WHERE NOT c_bool
  AND NOT (c_grp > 50);
