-- Merge scan inside joins.
--
-- A scan cost error that is small in isolation becomes a plan error when it
-- decides a join.  Three things can go wrong here that cannot go wrong in a
-- bare scan.  A merge scan priced too cheaply can win the inner side of a
-- nested loop, where its per-parameter startup is paid once per outer row
-- rather than once per query.  Its free ordering can entice a merge join that
-- would otherwise have been a hash join.  And because a merge path exists
-- where an ordered path did not, it can flip the join order outright, which
-- is the mechanism in yugabyte/yugabyte-db#32317 and has its own file.
--
-- dj holds 20000 rows with c1 = 1..20000 and c2 a permutation of 1..20000, so
-- joining it to any table in this model on c1 or on c2 matches exactly 20000
-- rows, once each.  Every query runs against mb16 and mplain, the same rows
-- with and without streams, and several also against mb64 where the same
-- ordering costs four times the streams.
--
-- Aliases are used throughout because the framework requires a query to use
-- aliases for all tables or for none.


-- ---------------------------------------------------------------------
-- The bucketized table as the inner side of a nested loop.  Pinning c1 from
-- the outer row is not enough to seek this index, since the bucket comes
-- first, so the inner scan needs the derived bucket SAOP and becomes a
-- 16-stream merge per outer row.  mplain seeks once.
-- ---------------------------------------------------------------------
SELECT d.c1, m.c2 FROM dj d JOIN mb16 m ON m.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c1 LIMIT 100;
SELECT d.c1, m.c2 FROM dj d JOIN mplain m ON m.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c1 LIMIT 100;
SELECT d.c1, m.c2 FROM dj d JOIN mb64 m ON m.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c1 LIMIT 100;
SELECT d.c1, m.c2 FROM dj d JOIN mb16 m ON m.c1 = d.c1 WHERE d.c3 = 1 ORDER BY d.c1;
SELECT d.c1, m.c2 FROM dj d JOIN mplain m ON m.c1 = d.c1 WHERE d.c3 = 1 ORDER BY d.c1;


-- ---------------------------------------------------------------------
-- The same join with no filter on the outer side, so all 20000 outer rows
-- probe.  This is where a per-parameter startup cost that the model does
-- not charge is multiplied by 20000.
-- ---------------------------------------------------------------------
SELECT count(*) FROM dj d JOIN mb16 m ON m.c1 = d.c1;
SELECT count(*) FROM dj d JOIN mplain m ON m.c1 = d.c1;
SELECT count(*) FROM dj d JOIN mb64 m ON m.c1 = d.c1;
SELECT d.c1, m.c4 FROM dj d JOIN mb16 m ON m.c1 = d.c1 ORDER BY d.c1 LIMIT 1000;
SELECT d.c1, m.c4 FROM dj d JOIN mplain m ON m.c1 = d.c1 ORDER BY d.c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Joining on the bucket's own source column.  c2 is what the bucket is
-- generated from, so an equality on it can pin a single bucket if the
-- planner derives the equality, and the two files eq-02 and this one meet
-- here.  On mplain c2 is not indexed at all.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1 FROM dj d JOIN mb16 m ON m.c2 = d.c2 WHERE d.c4 = 1 ORDER BY d.c2 LIMIT 100;
SELECT d.c2, m.c1 FROM dj d JOIN mplain m ON m.c2 = d.c2 WHERE d.c4 = 1 ORDER BY d.c2 LIMIT 100;
SELECT count(*) FROM dj d JOIN mb16 m ON m.c2 = d.c2;
SELECT count(*) FROM dj d JOIN mplain m ON m.c2 = d.c2;


-- ---------------------------------------------------------------------
-- Both inputs ordered on the join key, which is what a merge join wants.
-- The merge scan supplies the ordering on the bucketized side for the price
-- of its streams, and the question is whether that beats a hash join.
-- ---------------------------------------------------------------------
SELECT a.c1, b.c2 FROM mb16 a JOIN mplain b ON b.c1 = a.c1 WHERE a.c4 = 1 ORDER BY a.c1 LIMIT 1000;
SELECT a.c1, b.c2 FROM mb16 a JOIN mb64 b ON b.c1 = a.c1 WHERE a.c4 = 1 ORDER BY a.c1 LIMIT 1000;
SELECT a.c1, b.c2 FROM mplain a JOIN mplain b ON b.c1 = a.c1 + 1 WHERE a.c4 = 1 ORDER BY a.c1 LIMIT 1000;
SELECT count(*) FROM mb16 a JOIN mplain b ON b.c1 = a.c1 WHERE a.c4 = 1;
SELECT count(*) FROM mb16 a JOIN mb64 b ON b.c1 = a.c1 WHERE a.c4 = 1;


-- ---------------------------------------------------------------------
-- The bucketized table on the outer side, ordered, with the small table as
-- the inner.  Here the merge's ordering carries through the join, so a
-- LIMIT above can terminate the whole plan early if the estimate holds.
-- ---------------------------------------------------------------------
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mplain m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb64 m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 10000;
SELECT m.c1, d.c4 FROM mplain m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 10000;


-- ---------------------------------------------------------------------
-- Semi and anti joins, where the LIMIT above cannot be pushed through the
-- subquery and the ordering still has to be produced.
-- ---------------------------------------------------------------------
SELECT m.c1, m.c2 FROM mb16 m WHERE EXISTS (SELECT 1 FROM dj d WHERE d.c1 = m.c1) ORDER BY m.c1 LIMIT 100;
SELECT m.c1, m.c2 FROM mplain m WHERE EXISTS (SELECT 1 FROM dj d WHERE d.c1 = m.c1) ORDER BY m.c1 LIMIT 100;
SELECT m.c1, m.c2 FROM mb64 m WHERE EXISTS (SELECT 1 FROM dj d WHERE d.c1 = m.c1) ORDER BY m.c1 LIMIT 100;
SELECT m.c1, m.c2 FROM mb16 m WHERE NOT EXISTS (SELECT 1 FROM dj d WHERE d.c1 = m.c1) ORDER BY m.c1 LIMIT 100;
SELECT m.c1, m.c2 FROM mplain m WHERE NOT EXISTS (SELECT 1 FROM dj d WHERE d.c1 = m.c1) ORDER BY m.c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Aggregation above the join, so no LIMIT reaches either scan.
-- ---------------------------------------------------------------------
SELECT d.c4, count(*), avg(m.c3) FROM dj d JOIN mb16 m ON m.c1 = d.c1 GROUP BY d.c4 ORDER BY d.c4;
SELECT d.c4, count(*), avg(m.c3) FROM dj d JOIN mplain m ON m.c1 = d.c1 GROUP BY d.c4 ORDER BY d.c4;
SELECT m.c1, count(*) FROM dj d JOIN mb16 m ON m.c1 = d.c1 GROUP BY m.c1 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, count(*) FROM dj d JOIN mplain m ON m.c1 = d.c1 GROUP BY m.c1 ORDER BY m.c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Three-way joins, where a wrong scan cost has two join orders to spoil.
-- ---------------------------------------------------------------------
SELECT d.c1, a.c2, b.c3 FROM dj d JOIN mb16 a ON a.c1 = d.c1 JOIN mplain b ON b.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c1 LIMIT 100;
SELECT d.c1, a.c2, b.c3 FROM dj d JOIN mb16 a ON a.c1 = d.c1 JOIN mb64 b ON b.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c1 LIMIT 100;
SELECT count(*) FROM dj d JOIN mb16 a ON a.c1 = d.c1 JOIN mplain b ON b.c1 = d.c1;


-- ---------------------------------------------------------------------
-- The join twin of the empty-result shape: the filter matches nothing, so
-- the join produces nothing and every early-termination discount above it
-- is unearned.  Its matching twin follows each one.
-- ---------------------------------------------------------------------
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 50 AND m.c8 = 51 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 50 AND m.c8 = 50 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mplain m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 50 AND m.c8 = 51 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mplain m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 50 AND m.c8 = 50 ORDER BY m.c1 LIMIT 100;
