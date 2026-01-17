/*+ IndexScan(t100 t100_bucketized_3) */
SELECT
    c2,
    c3,
    c4,
    row_number() OVER (PARTITION BY c2 ORDER BY c3 NULLS LAST) AS rn,
    avg(c4) OVER (PARTITION BY c2) AS avg_c4,
    sum(c5) OVER (ORDER BY c2 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum
FROM t100
WHERE c2 BETWEEN 10 AND 90
  AND c3 IS NOT NULL;

/*+ IndexScan(t100 t100_bucketized_3) */
SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY c3 NULLS LAST) AS rn,
    avg(c4) OVER (PARTITION BY c2) AS avg_c4,
    max(c6) OVER (PARTITION BY c2) AS max_c6,
    sum(c5) OVER (ORDER BY c2 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum
FROM t100
WHERE c2 > 20 order by c2,c3;

/*+ IndexScan(t100 t100_bucketized_2) */
SELECT c2,
    c3,
    dense_rank() OVER (PARTITION BY c2 ORDER BY c2,c3) AS dr,
    avg(c4) OVER (PARTITION BY c2) AS avg_c4
FROM t100 order by c2,c3;

SELECT
    c2,
    c4,
    row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn,
    dense_rank() OVER (PARTITION BY c2 ORDER BY coalesce(c4,0)) AS dr
FROM t1000 order by c2,c4;

SELECT
    c2,
    c3,
    dense_rank() OVER (PARTITION BY c2 ORDER BY coalesce(c4,0)) AS dr,
    avg(c4) OVER (PARTITION BY c2) AS avg_c4,
    max(c6) OVER (PARTITION BY c2) AS max_c6
FROM t100 order by c2,c3;


SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn,
    count(*) OVER (PARTITION BY c3) AS freq
FROM t1000
WHERE c2 BETWEEN 100 AND 900;


SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn,
    count(*) OVER (PARTITION BY c3) AS freq
FROM t1000 WHERE c2 BETWEEN 100 AND 900 order by c2,c3;

/*+ IndexScan(t1000 t1000_bucketized_2) */
SELECT
    c2,
    c4,
    row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn,
    dense_rank() OVER (PARTITION BY c2 ORDER BY coalesce(c4,0)) AS dr
FROM t1000 order by c2,c4;



/*+ IndexScan(t1000 t1000_bucketized_1) */
SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn,
    dense_rank() OVER (PARTITION BY c3 ORDER BY coalesce(c2,0)) AS dr
FROM t1000
WHERE c2 BETWEEN 100 AND 900;


/*+ IndexScan(t10000 t10000_bucketized_1) */
SELECT
    c2,
    c3,
    rank() OVER (PARTITION BY c2 ORDER BY c3) AS rnk,
    count(*) OVER (PARTITION BY c2) AS cnt
FROM t10000 order by c2,c3;


/*+ IndexScan(t10000 t10000_bucketized_4) */
SELECT
    c2,
    length(v) AS vlen,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn
FROM t10000 order by c2,v;


/*+ IndexScan(t10000 t10000_bucketized_partition_1) */
SELECT
    c2,
    length(v) AS vlen,
    rank() OVER (PARTITION BY c3 ORDER BY c2) AS rnk_
FROM t10000 where v like '--%' order by c2,v;


/*+ IndexScan(t10000 t10000_bucketized_partition_2 t10000_bucketized_partition_3 t10000_bucketized_partition_4 t10000_bucketized_partition_def) */
SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn,
    avg(c6) OVER (PARTITION BY c4) AS avg_c6
FROM t10000 order by c2,c3;


/*+ IndexScan(t10000 t10000_bucketized_partition_4 t10000_bucketized_partition_def) */
SELECT
    c2,
    length(v) AS vlen,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn
FROM t10000
WHERE c2 BETWEEN 30 AND 100
  AND v IS NOT NULL order by c1,c2;


/*+ IndexScan(t100000 t100000_bucketized_1) */
SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn,
    dense_rank() OVER (PARTITION BY c2 ORDER BY c3) AS dr
FROM t100000 order by c2,c3;


/*+ IndexScan(t100000 t100000_bucketized_2) */
SELECT
    c2,
    c4,
    avg(c5) OVER (ORDER BY c2 ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) AS mov_avg
FROM t100000 where c2>c4 order by c2,c4;


/*+ IndexScan(t100000w t100000w_bucketized_5) */
SELECT
    c2,
    length(v) AS vlen,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn
FROM t100000w
WHERE c2 BETWEEN 100 AND 900
  AND v IS NOT NULL order by c2,v;


/*+ IndexScan(t100000w t100000w_bucketized_1) */
SELECT
    c2,
    c3,
    row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn
FROM t100000w  order by c2,c3;



/*+ IndexScan(t100000w t100000w_bucketized_3) */
SELECT
    c1,
    c2,
    length(v) AS vlen
FROM t100000w where v like '--%' order by c1,c2;



/*+ IndexScan(t100000w t100000w_bucketized_4) */
SELECT
    bucketid,
    v,
    sum(c5) OVER (PARTITION BY c3) AS sum_c5,
    length(v) * length(v) / 2 AS vlen
FROM t100000w
WHERE (yb_hash_code(bucketid, v) % 3) in (0,1,2)  order by bucketid,v;


/*+ IndexScan(t1000000m t1000000m_bucketized_1) */
SELECT
    c2,
    c3,
    count(*) OVER (PARTITION BY c3) AS cnt,
    avg(c5) OVER (PARTITION BY c2) AS avg_c5
FROM t1000000m
WHERE c2 BETWEEN 1000005 AND 1005000;


/*+ IndexScan(t1000000m t1000000m_bucketized_2) */
SELECT
    c2,
    c4,
    count(*) OVER (PARTITION BY c2) AS cnt,
    avg(c5) OVER (PARTITION BY c2) AS avg_c5
FROM t1000000m
WHERE c2 BETWEEN 0 AND 1005000 order by c2,c4;

/*+ IndexScan(t1000000m t1000000m_bucketized_5) */
SELECT
    c2,
    c5,
    sum(c6) OVER (ORDER BY c5 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum
FROM t1000000m
WHERE c5 BETWEEN 1000 AND 90000 order by c2,c5;


/*+ IndexScan(t1000000m t1000000m_bucketized_4) */
SELECT
    bucketid,
    c6,
    avg(bucketid) OVER (PARTITION BY c2) AS avg_cb,
    dense_rank() OVER (PARTITION BY c3 ORDER BY coalesce(c2,0)) AS dr,
    dense_rank() OVER (PARTITION BY bucketid ORDER BY coalesce(bucketid,0)) AS drb,
    sum(c6) OVER (ORDER BY c5 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum
FROM t1000000m
WHERE c6 BETWEEN 1000 AND 90000 order by bucketid,c6;


SELECT
    w.c1,
    w.c2,
    m.c1,
    m.c2
FROM (
    SELECT c1, c2
    FROM t100000w
    WHERE bucketid IN (0,1,2) order by c1,c2
    LIMIT 3000
) w
JOIN t1000000m m
    ON m.c2 = w.c2
WHERE ((yb_hash_code(w.c1, w.c2) % 3)) = 2
  AND (m.c2 > 10 OR m.c3 < 10000) order by w.c1,w.c2
LIMIT 900;

WITH filtered AS (
    SELECT *
    FROM t1000000m
    WHERE c2 BETWEEN 5000 AND 80000
)

SELECT
    bucketid,
    c2,
    c3,
    avg(c3) OVER (PARTITION BY c2) AS avg_c3_per_c2,
    dense_rank() OVER (PARTITION BY bucketid ORDER BY c3) AS dr_bucket,
    sum(c6) OVER (ORDER BY c5 ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS sliding_sum
FROM filtered;


SELECT
    c2,
    c3,
    avg(c3) OVER (PARTITION BY c2) AS avg_c3,
    row_number() OVER (PARTITION BY c2 ORDER BY c3 DESC) AS rn_desc,
    sum(c3) OVER (ORDER BY c4 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum_c3
FROM t10000_partition_2
WHERE c2 BETWEEN 25 AND 50 order by c2,c3;


/*+ IndexScan(t100000w t100000w_bucketized_5) */
select
    c2,
    c3,
    dense_rank() over (partition by coalesce(v,'x') order by c4 desc) as dr_v,
    ntile(5) over (partition by bucketid order by c5) as quintile_bucket,
    sum(c6 + 1) over (order by c5 rows between unbounded preceding and current row) as run_sum
from t100000w
where bucketid in (0,1) and v like '--%';


/*+ IndexScan(t100000w t100000w_bucketized_5) */
WITH t AS (
    SELECT
        c2,
        c3,
        c5,
        c6,c4,
        bucketid,
        ntile(3) OVER (ORDER BY c2, c3) AS ntile_bucket
    FROM t100000w
    WHERE v LIKE '--%'
)
SELECT
    t.c2,
    t.c3,
    t.ntile_bucket,
    sum(t.c6) OVER (PARTITION BY t.ntile_bucket ORDER BY t.c5 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum_bucket,
    dense_rank() OVER (PARTITION BY t.ntile_bucket ORDER BY t.c4 DESC) AS dr_bucket
FROM t
WHERE bucketid IN (0,1);


select c1, c2,
       row_number() over(order by c1, c2) as rn
from t100
where bucketid in (0,1,2)
order by c1, c2;

select c1, c2,
       ntile(4) over(order by c1) as nt
from t100
where bucketid in (0,1,2)
order by c1, c2;

select c1, c2,
       sum(c2) over(order by c1 rows between unbounded preceding and current row) as running_sum
from t100
where bucketid in (0,1,2)
order by c1, c2;

select c1, c2,
       count(*) over() as total_rows
from t100
where bucketid in (0,1,2)
order by c1, c2;


select c2, c3,
       avg(c3) over(partition by c2) as avg_c3
from t1000
where c2>c3
order by c2, c3;

select c2, c4,
       max(c4) over(partition by c2) as max_c4
from t1000
where c2>c4
order by c2, c4;

select c2, c3,
       row_number() over(partition by c2 order by c3) as rn
from t1000
order by c2, c3;


select c2, c3,
       dense_rank() over(order by c3 desc) as dr
from t1000
where (yb_hash_code(c2, c3) % 3) in (0,1,2)
order by c2, c3;

select c1, c2, c3,
       count(*) over(partition by c1) as cnt
from t10000
where c1>c2 and c2>c3
order by c1, c2;

select c1, c2,
       avg(c2) over(order by c1) as running_avg
from t10000
where c1>c2
order by c1, c2;

select c1, c2,
       ntile(10) over(order by c2) as bucket
from t10000
where bucketid in (0,1,2)
order by c1, c2;

select c2, c4,
       max(c4) over(order by c2) as m
from t100000
where (yb_hash_code(c2, c4) % 3) in (0,1,2)
order by c2, c4;

select c2, c3,
       row_number() over(partition by c2 order by c3 desc) as rn
from t100000
where c2<c3
order by c2, c3;

select c1, c2, v,
       count(*) over(partition by c1) as cnt
from t100000w
where v='---' and c1=10
order by c1, c2;

select c2, v,
       dense_rank() over(order by length(v)) as dr
from t100000w
where (yb_hash_code(c2, v) % 3) in (0,1,2)
order by c2, v;

select c1, c2, c3,
       sum(c3) over(order by c1) as running_sum
from t1000000m
where bucketid in (0,1,2)
order by c1, c2;

select c2, c3,
       row_number() over(partition by c2 order by c3) as rn
from t1000000m
where (yb_hash_code(c2, c3) % 3) in (0,1,2)
order by c2, c3;

select c1, c2, c5,
       ntile(5) over(order by c5) as grp
from t1000000m
where bucketid in (0,1,2)
order by c1, c2;
