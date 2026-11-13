SELECT c_int, c_grp,
       row_number() OVER (PARTITION BY c_grp ORDER BY c_int) AS rn,
       sum(c_int) OVER (PARTITION BY c_grp) AS grp_sum
FROM lmc_main
WHERE c_int < 400
ORDER BY c_grp, c_int
LIMIT 50;

SELECT c_int,
       sum(c_int) OVER w AS run_sum,
       avg(c_float) OVER w AS run_avg
FROM lmc_main
WHERE c_int < 100
WINDOW w AS (ORDER BY c_int ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY c_int;

SELECT c_int, c_grp,
       first_value(c_int) OVER (wg ORDER BY c_int ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fv,
       last_value(c_int) OVER (wg ORDER BY c_int RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS lv
FROM lmc_main
WHERE c_int < 300
WINDOW wg AS (PARTITION BY c_grp % 5)
ORDER BY c_grp % 5, c_int
LIMIT 40;

SELECT c_int,
       count(*) OVER (ORDER BY c_grp RANGE UNBOUNDED PRECEDING) AS c1,
       count(*) OVER (ORDER BY c_grp, c_int ROWS 3 PRECEDING) AS c2,
       count(*) OVER (ORDER BY c_grp GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS c3
FROM lmc_main
WHERE c_int < 250
ORDER BY c_int
LIMIT 40;

SELECT c_int, c_num,
       sum(c_num) OVER (ORDER BY c_int ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING EXCLUDE CURRENT ROW) AS s1,
       sum(c_num) OVER (ORDER BY c_grp GROUPS BETWEEN CURRENT ROW AND 2 FOLLOWING EXCLUDE GROUP) AS s2,
       sum(c_num) OVER (ORDER BY c_grp RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE TIES) AS s3,
       sum(c_num) OVER (ORDER BY c_int ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING EXCLUDE NO OTHERS) AS s4
FROM lmc_main
WHERE c_int < 120
ORDER BY c_int;

SELECT c_int, c_ts,
       count(*) OVER (ORDER BY c_ts RANGE BETWEEN interval '2 hours' PRECEDING AND interval '1 hour' FOLLOWING) AS near_cnt,
       sum(c_int) OVER (ORDER BY c_int RANGE BETWEEN 5 PRECEDING AND 5 FOLLOWING) AS near_sum
FROM lmc_main
WHERE c_int < 200
ORDER BY c_int
LIMIT 40;

SELECT c_grp,
       rank() OVER w1,
       dense_rank() OVER w1,
       percent_rank() OVER w1,
       cume_dist() OVER w1,
       ntile(4) OVER w1,
       lag(c_grp, 2, -1) OVER w1,
       lead(c_grp) OVER w1,
       nth_value(c_grp, 3) OVER (w1 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM lmc_small
WHERE c_int < 60
WINDOW w1 AS (ORDER BY c_grp DESC), w2 AS (w1)
ORDER BY c_grp DESC, 2;

SELECT c_grp % 4 AS g, sum(c_int) AS s,
       rank() OVER (ORDER BY sum(c_int) DESC) AS r,
       sum(sum(c_int)) OVER () AS total
FROM lmc_main
GROUP BY c_grp % 4
ORDER BY r;

SELECT c_int, count(*) FILTER (WHERE c_bool) OVER (PARTITION BY c_grp % 3 ORDER BY c_int) AS bool_running
FROM lmc_main
WHERE c_int < 100
ORDER BY c_int;
