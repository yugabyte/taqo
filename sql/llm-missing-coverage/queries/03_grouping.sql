SELECT c_grp % 3 AS g3, c_bool, count(*), sum(c_num)
FROM lmc_main
GROUP BY ROLLUP (c_grp % 3, c_bool)
ORDER BY 1, 2;

SELECT c_grp % 2 AS g2, c_bool, count(*)
FROM lmc_main
GROUP BY CUBE (c_grp % 2, c_bool)
ORDER BY 1 NULLS FIRST, 2 NULLS FIRST;

SELECT c_grp % 4 AS g4, c_bool, c_date > date '2024-06-01' AS late, count(*)
FROM lmc_main
GROUP BY GROUPING SETS ((c_grp % 4, c_bool), (c_date > date '2024-06-01'), ())
ORDER BY 1, 2, 3;

SELECT count(*), sum(c_int)
FROM lmc_small
GROUP BY ();

SELECT c_grp % 3 AS g3, c_bool,
       GROUPING(c_grp % 3, c_bool) AS gmask,
       GROUPING(c_bool) AS gb,
       count(*)
FROM lmc_main
GROUP BY ROLLUP (c_grp % 3, c_bool)
ORDER BY gmask, 1, 2;

SELECT c_grp % 2 AS a, c_bool, count(*)
FROM lmc_main
GROUP BY DISTINCT ROLLUP (c_grp % 2, c_bool), ROLLUP (c_grp % 2)
ORDER BY 1, 2;

SELECT c_grp % 2 AS a, c_grp % 3 AS b, count(*)
FROM lmc_main
GROUP BY ALL c_grp % 2, CUBE (c_grp % 3)
ORDER BY 1, 2;

SELECT c_grp % 5 AS g, count(*) FILTER (WHERE c_bool) AS bool_cnt, avg(c_float)
FROM lmc_main
GROUP BY GROUPING SETS (c_grp % 5, ROLLUP (c_bool), CUBE (c_grp % 2))
ORDER BY 1, 2, 3
LIMIT 40;

SELECT c_grp, count(ALL c_nullable), count(DISTINCT c_nullable % 7)
FROM lmc_main
GROUP BY c_grp
HAVING count(*) > 10
ORDER BY c_grp
LIMIT 20;

SELECT c_grp, string_agg(c_text, ',' ORDER BY c_int DESC) AS texts
FROM lmc_small
WHERE c_int < 300
GROUP BY c_grp
ORDER BY c_grp
LIMIT 10;

SELECT c_grp % 10 AS g,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY c_float) AS med,
       mode() WITHIN GROUP (ORDER BY c_grp) AS md,
       rank(50) WITHIN GROUP (ORDER BY c_grp) AS rk
FROM lmc_main
GROUP BY c_grp % 10
ORDER BY 1;
