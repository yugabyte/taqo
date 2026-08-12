-- Join shapes where merge scan cost errors change the join plan rather than
-- the scan itself: an underpriced merge scan can flip the join order and
-- take the outer side of a batched nested loop onto the large table, entice
-- a Merge Join through its "free" ordering, or displace a semi-join plan.
-- Regression testing has found its largest merge scan slowdowns in these
-- shapes rather than in bare scans, so they are targeted deliberately.
--
-- Match rates are deterministic.  Every table's c1 is the raw
-- generate_series index, so cross-table equality joins on c1 match 1:1:
-- t100000 holds 10000 rows (despite its name) with c1 = 1..10000, so its
-- joins to table_bucketized.c1 = 1..1000000 match on the first 10k values.
-- The permuted columns (c2, c5) only match within one table load, so
-- non-key-column joins are self-joins.  Queries whose predicate matches
-- nothing on purpose (the planner estimates rows but the result is empty,
-- so early-termination bets never pay off) say so in a comment.

-- Shape A: aggregate over a join where the large bucketized table can flip
-- to the outer side of a batched nested loop.  The b.c2 >= 0 predicate is a
-- no-op that makes the large table's primary key merge-scannable.
SELECT b.c2, count(*) AS cnt, avg(t.c1) AS avg_c1
FROM table_bucketized b
JOIN t100000 t ON t.c1 = b.c1
WHERE b.c2 >= 0 AND t.c4 BETWEEN 100 AND 200
GROUP BY b.c2
ORDER BY b.c2
LIMIT 100;

-- Shape A control: same query without the no-op predicate on the large
-- table.
SELECT b.c2, count(*) AS cnt, avg(t.c1) AS avg_c1
FROM table_bucketized b
JOIN t100000 t ON t.c1 = b.c1
WHERE t.c4 BETWEEN 100 AND 200
GROUP BY b.c2
ORDER BY b.c2
LIMIT 100;

-- Shape A empty twin: v is always 1024 chars, so this matches nothing while
-- the planner estimates a nonzero row count.
SELECT b.c2, count(*) AS cnt, avg(t.c1) AS avg_c1
FROM table_bucketized b
JOIN t100000 t ON t.c1 = b.c1
WHERE length(b.v) BETWEEN 10 AND 20 AND t.c4 BETWEEN 100 AND 200
GROUP BY b.c2
ORDER BY b.c2
LIMIT 100;

-- Shape B: the merge scan's output order on the primary key prefix matches
-- the join clause and the ORDER BY, which entices a Merge Join over the
-- batched nested loop.  1:1 join on c1, about 5000 rows pass the c3 filter.
SELECT a.c1, a.c2, b.c3
FROM table_bucketized a
JOIN table_simple b ON b.c1 = a.c1
WHERE a.c3 <= 1000
ORDER BY a.c1
LIMIT 100;

SELECT a.c1, a.c2, b.c3
FROM table_bucketized a
JOIN table_simple b ON b.c1 = a.c1
WHERE a.c3 <= 1000
ORDER BY a.c1;

-- Shape B empty twin.
SELECT a.c1, a.c2, b.c3
FROM table_bucketized a
JOIN table_simple b ON b.c1 = a.c1
WHERE length(a.v) BETWEEN 10 AND 20
ORDER BY a.c1
LIMIT 100;

-- Shape C: user-written full-domain IN on the bucket column of the join's
-- larger side, so the planner can swap which side drives the join.
SELECT b.c1, b.c2, t.c3
FROM table_bucketized b
JOIN t100000 t ON t.c1 = b.c1
WHERE b.bucketid IN (0, 1, 2) AND t.c6 <= 50
ORDER BY b.c1, b.c2
LIMIT 100;

-- Shape D: semi-join, where the merge scan can displace the subquery-driven
-- plan.
SELECT b.c1, b.c2, b.c3
FROM table_bucketized b
WHERE EXISTS (
    SELECT 1 FROM t100000 t
    WHERE t.c1 = b.c1 AND t.c4 BETWEEN 100 AND 120
)
ORDER BY b.c1, b.c2
LIMIT 500;

SELECT b.c1, b.c2, b.c3
FROM table_bucketized b
WHERE b.c1 <= 100000 AND NOT EXISTS (
    SELECT 1 FROM t100000 t
    WHERE t.c1 = b.c1 AND t.c4 BETWEEN 100 AND 120
)
ORDER BY b.c1, b.c2
LIMIT 500;

-- Shape E: IN subquery with a descending ORDER BY.  About 10000
-- deterministic matches on c1.
SELECT c1, c2, c3
FROM table_bucketized
WHERE c1 IN (
    SELECT c1 FROM table_simple WHERE c3 <= 2000
)
ORDER BY c1 DESC, c2 DESC
LIMIT 1000;

-- Shape F: self-join on a non-order column (c5 is unique within the
-- table), so the merge scan's order helps the ORDER BY but not the join.
-- 1:1, about 20000 rows pass the filter.
SELECT a.c1, a.c2, a.c5, b.c1 AS peer_c1
FROM table_bucketized a
JOIN table_bucketized b ON b.c5 = a.c5
WHERE a.c4 <= 2000
ORDER BY a.c1, a.c2
LIMIT 200;

-- Shape G: three-way join mixing both patterns.
SELECT b.c1, b.c2, t.c3, s.c4
FROM table_bucketized b
JOIN t100000 t ON t.c1 = b.c1
JOIN table_simple s ON s.c1 = b.c1
WHERE t.c4 BETWEEN 100 AND 150
ORDER BY b.c1
LIMIT 100;
