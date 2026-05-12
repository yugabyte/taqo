SELECT c1, count(*) AS cnt, sum(c2) AS sum_c2
FROM t100
WHERE bucketid IN (0,1,2)
GROUP BY c1
ORDER BY c1;

SELECT c2, min(c1) AS min_c1, max(c1) AS max_c1, avg(c3) AS avg_c3, count(*) AS cnt
FROM t100
WHERE c2 BETWEEN 10 AND 90
GROUP BY c2
ORDER BY c2;


SELECT c2, count(*) AS cnt
FROM t1000
GROUP BY c2
HAVING count(*) > 1
ORDER BY c2;

SELECT c3, avg(c4) AS avg_c4, count(*) AS cnt
FROM t1000
WHERE c2 >= 0 AND c3 >= 1
GROUP BY c3
HAVING avg(c4) > 100
ORDER BY c3;

SELECT length(v) AS vlen, count(*) AS cnt, avg(c2) AS avg_c2
FROM t10000
WHERE v IS NOT NULL
GROUP BY length(v)
ORDER BY vlen;

SELECT substr(v, 1, 3) AS v_prefix, count(*) AS cnt, min(c1) AS min_c1, max(c1) AS max_c1
FROM t10000
WHERE v IS NOT NULL AND length(v) > 3
GROUP BY substr(v, 1, 3)
ORDER BY v_prefix;


SELECT c1, c2, count(*) AS cnt, avg(c3) AS avg_c3
FROM t100000
WHERE c1 > c2
GROUP BY c1, c2
ORDER BY c1, c2 limit 100;

SELECT c2, c3, c4, count(*) AS cnt
FROM t100000
WHERE c2 BETWEEN 100 AND 1000
GROUP BY c2, c3, c4
HAVING count(*) >= 1
ORDER BY c2, c3, c4 limit 50;


SELECT c1, c2, count(*) AS cnt, sum(c3) AS sum_c3
FROM t100
WHERE c3 IS NOT NULL
GROUP BY GROUPING SETS ((c1, c2), (c1), (c2), ())
ORDER BY c1, c2 limit 50;

SELECT c2, c3, count(*) AS cnt, avg(c4) AS avg_c4
FROM t1000
WHERE c2 > c3
GROUP BY ROLLUP (c2, c3)
ORDER BY c2, c3 limit 50;

SELECT bucketid, sign(c1 - c2) AS direction, count(*) AS cnt, sum(c3) AS sum_c3
FROM t10000
WHERE c1 IS NOT NULL AND c2 IS NOT NULL
GROUP BY CUBE (bucketid, sign(c1 - c2))
ORDER BY bucketid, direction limit 50;

SELECT t1.c2, count(*) AS cnt, sum(t2.c4) AS sum_c4, avg(t2.c3) AS avg_c3
FROM t100 t1
JOIN t1000 t2 ON t1.c2 = t2.c2
WHERE t1.c2 BETWEEN 10 AND 200
GROUP BY t1.c2
ORDER BY t1.c2 limit 50;

SELECT t1.c2, t1.c3, count(*) AS cnt, max(t2.c4) AS max_c4
FROM t1000 t1
JOIN t100000 t2 ON t1.c2 = t2.c2
WHERE t1.c2 > 0
GROUP BY t1.c2, t1.c3
HAVING count(*) > 1
ORDER BY t1.c2, t1.c3 limit 50;

SELECT m.c2, count(*) AS cnt, avg(w.c1) AS avg_c1, sum(m.c6) AS sum_c6
FROM t1000000m m
JOIN t100000w w ON w.c2 = m.c2
WHERE m.c2 >= 0 AND w.c2 >= 0
GROUP BY m.c2
ORDER BY m.c2
LIMIT 1000;

SELECT t1.c2, count(*) AS cnt, sum(t3.c5) AS sum_c5
FROM t100 t1
JOIN t1000 t2 ON t1.c2 = t2.c2
JOIN t100000 t3 ON t2.c2 = t3.c2
WHERE t1.c2 BETWEEN 5 AND 500
GROUP BY t1.c2
ORDER BY t1.c2 limit 50;

SELECT c2, count(DISTINCT c3) AS distinct_c3, count(*) AS total_cnt
FROM t10000
WHERE c2 BETWEEN 10 AND 100
GROUP BY c2
ORDER BY c2 limit 90;

SELECT c2, count(DISTINCT c3) AS dist_c3, count(DISTINCT c4) AS dist_c4, sum(c5) AS sum_c5
FROM t100000
WHERE c2 BETWEEN 100 AND 5000
GROUP BY c2
ORDER BY c2;

SELECT c2, count(DISTINCT c3) AS dist_c3, avg(c4) AS avg_c4
FROM t1000000m
WHERE c2 BETWEEN 1000 AND 50000
GROUP BY c2
HAVING count(DISTINCT c3) > 1
ORDER BY c2;


WITH filtered AS (
    SELECT c1, c2, c3, c4, c5
    FROM t100000
    WHERE c1 > c2 AND c3 IS NOT NULL
)
SELECT c1, count(*) AS cnt, avg(c3) AS avg_c3, sum(c4) AS sum_c4
FROM filtered
GROUP BY c1
ORDER BY c1;

WITH base AS (
    SELECT *
    FROM t1000000m
    WHERE c2 BETWEEN 5000 AND 80000
)
SELECT bucketid, c2, count(*) AS cnt, avg(c3) AS avg_c3
FROM base
GROUP BY bucketid, c2
HAVING count(*) >= 1
ORDER BY bucketid, c2;

SELECT sub.c2, count(*) AS cnt, sum(sub.c4) AS sum_c4
FROM (
    SELECT c2, c3, c4
    FROM t100000w
    WHERE v LIKE '--%' AND c2 > 100
) sub
GROUP BY sub.c2
ORDER BY sub.c2;


SELECT c2,
       count(*) AS total,
       count(*) FILTER (WHERE c3 > 50) AS cnt_c3_gt50,
       sum(c4) FILTER (WHERE c5 IS NOT NULL) AS sum_c4_when_c5,
       avg(c1) FILTER (WHERE c1 > c2) AS avg_c1_when_gt_c2
FROM t100
GROUP BY c2
ORDER BY c2 limit 100;

SELECT c2,
       count(*) AS total,
       count(*) FILTER (WHERE c4 > 100) AS cnt_high_c4,
       avg(c3) FILTER (WHERE c3 > 0) AS avg_positive_c3
FROM t1000
GROUP BY c2
HAVING count(*) FILTER (WHERE c4 > 100) >= 1
ORDER BY c2;

SELECT c2,
       sum(c3) FILTER (WHERE c3 > 0) AS sum_pos_c3,
       sum(c3) FILTER (WHERE c3 <= 0) AS sum_neg_c3,
       avg(c4) FILTER (WHERE c5 > 1000) AS avg_c4_high_c5,
       max(c6) FILTER (WHERE c6 BETWEEN 100 AND 50000) AS max_c6_range
FROM t1000000m
WHERE c2 BETWEEN 1000 AND 100000
GROUP BY c2
ORDER BY c2 limit 50;


SELECT c2, count(*) AS cnt, avg(c3) AS avg_c3, sum(c4) AS sum_c4
FROM t10000
WHERE c2 BETWEEN 10 AND 90
GROUP BY c2
ORDER BY c2 limit 80;

SELECT c1, count(*) AS cnt, max(c2) AS max_c2, min(c2) AS min_c2
FROM t10000
WHERE c1 > c2
GROUP BY c1
HAVING count(*) > 1
ORDER BY c1;

SELECT substr(v, 1, 4) AS v_prefix, count(*) AS cnt, avg(c1) AS avg_c1
FROM t10000
WHERE v IS NOT NULL AND c2 BETWEEN 25 AND 75
GROUP BY substr(v, 1, 4)
ORDER BY v_prefix;

SELECT c2, c3, count(*) AS cnt, sum(c4) AS sum_c4
FROM t10000_partition_2
WHERE c2 BETWEEN 25 AND 50
GROUP BY c2, c3
ORDER BY c2, c3;


SELECT c2, c3, count(*) AS cnt, avg(c4) AS avg_c4
FROM table_simple
WHERE c2 > 10
GROUP BY c2, c3
ORDER BY c2, c3;


SELECT c4, c5, count(*) AS cnt, sum(c6) AS sum_c6
FROM table_simple
WHERE c4 IS NOT NULL AND c5 IS NOT NULL
GROUP BY c4, c5
HAVING sum(c6) > 10
ORDER BY c4, c5;

SELECT c2, c3, count(*) AS cnt, avg(c4) AS avg_c4
FROM table_bucketized
WHERE c2 > 10
GROUP BY c2, c3
ORDER BY c2, c3;


SELECT c4, c5, count(*) AS cnt, sum(c6) AS sum_c6
FROM table_bucketized
WHERE c4 IS NOT NULL AND c5 IS NOT NULL
GROUP BY c4, c5
HAVING sum(c6) > 10
ORDER BY c4, c5;


SELECT c2, c4, count(*) AS cnt, avg(c5) AS avg_c5
FROM table_simple
WHERE c2 BETWEEN 10 AND 500
GROUP BY c2, c4
ORDER BY c2, c4;

SELECT c2, c4, count(*) AS cnt, avg(c5) AS avg_c5
FROM table_bucketized
WHERE c2 BETWEEN 10 AND 500
GROUP BY c2, c4
ORDER BY c2, c4;


SELECT c2, count(*) AS cnt
FROM t100000
WHERE c2 > 0
GROUP BY c2
ORDER BY cnt DESC, c2
LIMIT 100;

SELECT c2, sum(c3) AS sum_c3, avg(c4) AS avg_c4
FROM t1000000m
WHERE c1 > c2
GROUP BY c2
ORDER BY sum_c3 DESC
LIMIT 200;


SELECT m.c2, count(*) AS cnt, avg(m.c3) AS avg_c3, sum(w.c1) AS sum_w_c1
FROM t1000000m m
JOIN t100000w w
  ON w.c1 = m.c1
 AND abs(w.c2 - m.c2) = 0
WHERE sign(m.c1 - m.c2) >= 0
  AND least(m.c1, m.c2) >= 0
GROUP BY m.c2
ORDER BY m.c2;

SELECT c1, count(*) AS cnt, avg(c3) AS avg_c3
FROM t100000 t
WHERE EXISTS (
    SELECT 1 FROM t100 t2
    WHERE t2.c1 = t.c1 AND t2.c2 = t.c2
)
GROUP BY c1
ORDER BY c1;

WITH drivers AS (
    SELECT c1, c4, bucketid
    FROM t100000w
    WHERE c1 > c4
    ORDER BY bucketid, c1, c4
)
SELECT d.c1, count(*) AS cnt, avg(m.c6) AS avg_c6
FROM drivers d,
LATERAL (
    SELECT c1, c2, c6
    FROM t1000000m
    WHERE c1 = d.c1
      AND c6 BETWEEN 10 AND 90000
    ORDER BY c1, c2
    LIMIT 15
) m
GROUP BY d.c1
ORDER BY d.c1;


SELECT
    CASE
        WHEN c1 > c2 THEN 'c1_greater'
        WHEN c1 = c2 THEN 'equal'
        ELSE 'c2_greater'
    END AS comparison,
    count(*) AS cnt,
    avg(c3) AS avg_c3
FROM t100
GROUP BY
    CASE
        WHEN c1 > c2 THEN 'c1_greater'
        WHEN c1 = c2 THEN 'equal'
        ELSE 'c2_greater'
    END
ORDER BY comparison;

SELECT
    CASE
        WHEN c2 < 100000 THEN 'low'
        WHEN c2 BETWEEN 100000 AND 500000 THEN 'mid'
        ELSE 'high'
    END AS c2_range,
    count(*) AS cnt,
    avg(c3) AS avg_c3,
    sum(c4) AS sum_c4
FROM t1000000m
GROUP BY
    CASE
        WHEN c2 < 100000 THEN 'low'
        WHEN c2 BETWEEN 100000 AND 500000 THEN 'mid'
        ELSE 'high'
    END
ORDER BY c2_range;

SELECT
    CASE
        WHEN length(v) < 100 THEN 'short'
        WHEN length(v) BETWEEN 100 AND 1000 THEN 'medium'
        ELSE 'long'
    END AS v_category,
    count(*) AS cnt,
    avg(c2) AS avg_c2
FROM t100000w
WHERE v IS NOT NULL
GROUP BY
    CASE
        WHEN length(v) < 100 THEN 'short'
        WHEN length(v) BETWEEN 100 AND 1000 THEN 'medium'
        ELSE 'long'
    END
ORDER BY v_category;


SELECT c2,
       count(*) AS cnt,
       sum(CASE WHEN c3 > c4 THEN 1 ELSE 0 END) AS c3_gt_c4_count,
       sum(CASE WHEN c3 <= c4 THEN 1 ELSE 0 END) AS c3_le_c4_count
FROM t100000
WHERE c2 BETWEEN 100 AND 5000
GROUP BY c2
ORDER BY c2;

SELECT c2,
       count(*) AS cnt,
       min(c3) AS min_c3, max(c3) AS max_c3,
       avg(c4) AS avg_c4,
       sum(c5) AS sum_c5,
       min(c6) AS min_c6, max(c6) AS max_c6
FROM t1000000m
WHERE c2 BETWEEN 10000 AND 100000
GROUP BY c2
ORDER BY c2 limit 50;

SELECT c2, count(*) AS cnt, avg(c4) AS avg_c4,
       variance(c4) AS var_c4, stddev(c4) AS std_c4
FROM t100
WHERE c2 > 0
GROUP BY c2
ORDER BY c2;

SELECT c2,
       count(*) AS cnt,
       coalesce(sum(c3), 0) AS safe_sum_c3,
       coalesce(avg(c4), 0) AS safe_avg_c4
FROM t10000
GROUP BY c2
ORDER BY c2;


SELECT DISTINCT ON (w.c2)
    w.c2,
    w.c3,
    w.c4,
    m.c6
FROM t100000w w
JOIN t1000000m m
  ON m.c2 = w.c2
WHERE w.c3 BETWEEN 100 AND 50000
  AND m.c6 > 0
ORDER BY w.c2, w.c4 DESC, m.c6 DESC;


WITH RECURSIVE chains AS (
    SELECT
        c1,
        c2,
        c3,
        1 AS depth
    FROM t100
    WHERE c2 BETWEEN 1 AND 20

    UNION ALL

    SELECT
        t.c1,
        t.c2,
        t.c3,
        c.depth + 1
    FROM chains c
    JOIN t1000 t
      ON t.c2 = c.c2
     AND t.c3 BETWEEN c.c3 - 5
                  AND c.c3 + 5
    WHERE c.depth < 6
)
SELECT
    c2,
    count(*) AS cnt,
    avg(c3) AS avg_c3,
    max(depth) AS max_depth
FROM chains
GROUP BY c2
ORDER BY cnt DESC, c2
LIMIT 100;




SELECT
    m.c2, w.c3, t.c4, s.c5,
    rank() OVER (
        PARTITION BY m.c2
        ORDER BY w.c3 DESC, t.c4 DESC
    ) AS rnk,

    row_number() OVER (
        PARTITION BY m.c2
        ORDER BY s.c5 DESC
    ) AS rn

FROM t1000000m m
JOIN t100000w w ON m.c2 = w.c2
JOIN t100000 t
  ON t.c2 = m.c2
 AND t.c3 BETWEEN m.c3 - 50
              AND m.c3 + 50
JOIN t1000000m s
  ON s.c2 = m.c2
 AND s.c3 BETWEEN m.c3 - 20
              AND m.c3 + 20
WHERE
(
    m.c2 > m.c3
    AND w.c4 IS NOT NULL
)
OR
(
    m.c2 = ANY (
        ARRAY[
            10010,
            10020,
            10030,
            10040,
            10050,
            10060,
            10070,
            10080,
            10090,
            10100,
            10110,
            10120,
            10130,
            10140,
            10150,
            10160
        ]
    )

    AND m.c2 >= 10000
    AND m.c2 <= 500000
    AND abs(m.c2) >= 10000
)
AND t.c4 IS NOT NULL AND s.c5 IS NOT NULL
ORDER BY
    m.c2, w.c3, t.c4 DESC, s.c5 DESC
LIMIT 50000;




SELECT m.c2, w.c3, t.c4 FROM t1000000m m JOIN t100000w w ON m.c2 = w.c2 JOIN t100000 t ON t.c2 = m.c2 AND t.c3 = w.c3
WHERE ((m.c2 > m.c3 AND w.c4 IS NOT NULL AND t.c4 IS NOT NULL) OR (m.c2 = ANY (ARRAY[10010,10020,10030,10040,10050,10060,10070,10080]) AND m.c2 >= 10000 AND m.c2 <= 500000))
ORDER BY m.c2, w.c3, t.c4;