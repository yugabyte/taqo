-- Merge scan: the shapes that consume an ordering.
--
-- A merge scan is only ever worth its overhead because something above it
-- wants sorted rows.  ORDER BY is the obvious consumer, but it is not the
-- only one, and the others price the ordering differently: an incremental
-- sort needs only a prefix, a merge join needs both inputs ordered, a group
-- aggregate can take sorted input instead of building a hash table, and
-- DISTINCT ON needs the ordering it is defined by.  Each of those is a
-- separate decision the cost model makes with the same 2 % merge premium
-- underneath it.
--
-- Every query runs on mb16 and on mplain, the same rows with and without
-- streams, so the pair shows what the ordering is worth when it costs
-- 16 streams against when it costs nothing.  Several also run on mb64, where
-- the same ordering costs four times as many streams for the same benefit.


-- ---------------------------------------------------------------------
-- Ordering the index supplies in full, against ordering that needs a sort
-- on top.  c2 follows c1 in the bucketized key, so (c1, c2) is free once
-- the merge is running, while c5 is not in the index at all.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c1, c2 LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c1, c2 LIMIT 100;
SELECT c1, c2, c5 FROM mb16 ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2, c5 FROM mplain ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2, c5 FROM mb64 ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2, c5 FROM mb16 ORDER BY c1, c5 LIMIT 10000;
SELECT c1, c2, c5 FROM mplain ORDER BY c1, c5 LIMIT 10000;


-- ---------------------------------------------------------------------
-- Mixed direction, which no single index scan can supply, so the merge can
-- at best feed an incremental sort.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c1 ASC, c2 DESC LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c1 ASC, c2 DESC LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c1 DESC, c2 DESC LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c1 DESC, c2 DESC LIMIT 100;
SELECT c1, c2 FROM mb64 ORDER BY c1 DESC, c2 DESC LIMIT 100;


-- ---------------------------------------------------------------------
-- DISTINCT ON, which is defined by its ordering and cannot be answered by a
-- hash aggregate.  c1 is unique here, so every input row is also an output
-- row and the ordering is the whole cost.
-- ---------------------------------------------------------------------
SELECT DISTINCT ON (c1) c1, c2, c4 FROM mb16 ORDER BY c1, c2 LIMIT 100;
SELECT DISTINCT ON (c1) c1, c2, c4 FROM mplain ORDER BY c1, c2 LIMIT 100;
SELECT DISTINCT ON (c4) c4, c1, c2 FROM mb16 ORDER BY c4, c1;
SELECT DISTINCT ON (c4) c4, c1, c2 FROM mplain ORDER BY c4, c1;


-- ---------------------------------------------------------------------
-- Grouping on the ordered column.  A group aggregate over sorted input
-- competes with a hash aggregate over an unordered scan, and the merge
-- premium is what tips it.  Grouping on c4 instead needs a sort either way,
-- which is the control.
-- ---------------------------------------------------------------------
SELECT c1, count(*) FROM mb16 GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c1, count(*) FROM mplain GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c1, count(*) FROM mb64 GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c1, sum(c4) FROM mb16 WHERE c4 > 90 GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c1, sum(c4) FROM mplain WHERE c4 > 90 GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c4, count(*) FROM mb16 GROUP BY c4 ORDER BY c4;
SELECT c4, count(*) FROM mplain GROUP BY c4 ORDER BY c4;


-- ---------------------------------------------------------------------
-- Window functions, where the frame's ORDER BY is the consumer and there is
-- no LIMIT the scan can use even when one sits above the window.
-- ---------------------------------------------------------------------
SELECT c1, c4, row_number() OVER (ORDER BY c1) FROM mb16 LIMIT 100;
SELECT c1, c4, row_number() OVER (ORDER BY c1) FROM mplain LIMIT 100;
SELECT c1, c4, sum(c4) OVER (ORDER BY c1 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM mb16 LIMIT 100;
SELECT c1, c4, sum(c4) OVER (ORDER BY c1 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM mplain LIMIT 100;
SELECT c4, c1, rank() OVER (PARTITION BY c4 ORDER BY c1) FROM mb16 WHERE c4 IN (1,2,3) LIMIT 100;
SELECT c4, c1, rank() OVER (PARTITION BY c4 ORDER BY c1) FROM mplain WHERE c4 IN (1,2,3) LIMIT 100;


-- ---------------------------------------------------------------------
-- SELECT DISTINCT, which can take either a sorted input or a hash.
-- ---------------------------------------------------------------------
SELECT DISTINCT c1 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT DISTINCT c1 FROM mplain ORDER BY c1 LIMIT 1000;
SELECT DISTINCT c4 FROM mb16 ORDER BY c4;
SELECT DISTINCT c4 FROM mplain ORDER BY c4;


-- ---------------------------------------------------------------------
-- Set operations, where the ordering above the union has to be produced
-- after the branches are combined.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE c4 = 1 UNION ALL SELECT c1, c2 FROM mb16 WHERE c4 = 2 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mplain WHERE c4 = 1 UNION ALL SELECT c1, c2 FROM mplain WHERE c4 = 2 ORDER BY c1 LIMIT 100;
SELECT c1 FROM mb16 WHERE c4 = 1 UNION SELECT c1 FROM mb16 WHERE c4 = 2 ORDER BY c1 LIMIT 100;
SELECT c1 FROM mplain WHERE c4 = 1 UNION SELECT c1 FROM mplain WHERE c4 = 2 ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Ordering wanted only inside a subquery, where the LIMIT above cannot be
-- pushed to the scan.
-- ---------------------------------------------------------------------
SELECT max(c1) FROM (SELECT c1 FROM mb16 ORDER BY c1 LIMIT 10000) s;
SELECT max(c1) FROM (SELECT c1 FROM mplain ORDER BY c1 LIMIT 10000) s;
SELECT count(*) FROM (SELECT DISTINCT ON (c4) c4, c1 FROM mb16 ORDER BY c4, c1) s;
SELECT count(*) FROM (SELECT DISTINCT ON (c4) c4, c1 FROM mplain ORDER BY c4, c1) s;
