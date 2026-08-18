-- Merge scan under partitioning.
--
-- pt holds 200000 rows range partitioned by c1 into four equal partitions,
-- each with the same 8-bucket primary key pre-split one tablet per bucket.
-- Ordering by c1 across the whole table therefore needs a merge inside each
-- partition and an Append or MergeAppend across them, so the streams the
-- executor actually runs are 8 times the number of partitions the planner
-- fails to prune.  That multiplication is invisible to a cost model that
-- charges a flat premium per scan node.
--
-- Time range partitioning over a bucketized key is a natural combination,
-- since both exist for the same reason: the partition key spreads old data
-- off the write path and the bucket spreads the write path itself.  It is
-- also the one place in this model where pruning can remove streams for
-- free, so the pruned queries below are the cheap case a corrected model
-- should still recognize as cheap.
--
-- Partition boundaries are c1 in [1, 50001), [50001, 100001), [100001,
-- 150001) and [150001, 200001).


-- ---------------------------------------------------------------------
-- No pruning: every partition contributes 8 streams, so 32 streams answer
-- a query whose LIMIT wants 10 rows.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM pt ORDER BY c1 DESC LIMIT 10;
SELECT c1, c2 FROM pt ORDER BY c1 OFFSET 199990 LIMIT 10;
SELECT * FROM pt ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Pruned to one partition, which is the same query over a quarter of the
-- data and an eighth of the streams.  Compare each against the unpruned row
-- above it.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt WHERE c1 < 50001 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt WHERE c1 < 50001 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM pt WHERE c1 >= 150001 ORDER BY c1 DESC LIMIT 10;
SELECT c1, c2 FROM pt WHERE c1 BETWEEN 100001 AND 150000 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Pruned to two partitions, the intermediate point.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt WHERE c1 < 100001 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt WHERE c1 < 100001 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM pt WHERE c1 BETWEEN 50001 AND 150000 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- A boundary the planner cannot use for pruning because it is on another
-- column, so all four partitions run and the filter removes rows after the
-- fact.  This is the same work as the unpruned block with a smaller result.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt WHERE c4 = 50 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM pt WHERE c6 IN (1,2) ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Ordering by the partition key and something else, so an incremental sort
-- or a full sort sits above the Append.
-- ---------------------------------------------------------------------
SELECT c1, c2, c5 FROM pt ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2, c5 FROM pt WHERE c1 < 50001 ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2 FROM pt ORDER BY c2 LIMIT 100;


-- ---------------------------------------------------------------------
-- Aggregates, where no LIMIT reaches any partition's scan.
-- ---------------------------------------------------------------------
SELECT count(*) FROM pt;
SELECT count(*) FROM pt WHERE c1 < 50001;
SELECT count(*) FROM pt WHERE c4 = 50;
SELECT min(c1), max(c1) FROM pt;
SELECT c4, count(*) FROM pt GROUP BY c4 ORDER BY c4;
SELECT c1, count(*) FROM pt GROUP BY c1 ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Directly against one partition, bypassing the Append entirely.  This is
-- the per-partition cost the plans above are built from.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt_p1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt_p1 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM pt_p1;


-- ---------------------------------------------------------------------
-- Joined to the small table, so partition pruning and join order interact.
-- dj covers c1 = 1..20000, which lies entirely inside the first partition,
-- but only the join predicate says so.
-- ---------------------------------------------------------------------
SELECT p.c1, d.c4 FROM pt p JOIN dj d ON d.c1 = p.c1 ORDER BY p.c1 LIMIT 100;
SELECT p.c1, d.c4 FROM pt p JOIN dj d ON d.c1 = p.c1 WHERE p.c1 < 50001 ORDER BY p.c1 LIMIT 100;
SELECT count(*) FROM pt p JOIN dj d ON d.c1 = p.c1;


-- ---------------------------------------------------------------------
-- The empty-result twin under partitioning, where four partitions each
-- drain all eight of their streams to return nothing.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM pt WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM pt WHERE c7 = 50 AND c8 = 50 ORDER BY c1 LIMIT 10;
