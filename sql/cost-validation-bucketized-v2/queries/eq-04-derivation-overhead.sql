-- yb_enable_derived_equalities: derivations that cost more than they save.
--
-- Two overheads, both from yugabyte/yugabyte-db#31164, and both invisible to
-- the CBO because no path without the derived conditions is generated.  The
-- planner cannot choose not to derive, so a comparison has to come from two
-- runs with the GUC set differently.
--
-- The first overhead is redundant binds.  de16_c4c1 is (c4, c4 % 20, c4 + 1,
-- c4 * 2, c1), so an equality on c4 already seeks as far as that index can
-- go, and the three expression keys after it are functions of c4 alone.  Each
-- gets a derived equality anyway.  Verified on this schema, WHERE c4 = 50
-- produces
--
--   Index Cond: ((c4 = 50) AND (((c4 % 20)) = (50 % 20))
--                AND (((c4 + 1)) = (50 + 1)) AND (((c4 * 2)) = (50 * 2)))
--
-- against Index Cond: (c4 = 50) with the GUC off.  Three extra conditions on
-- the wire per bind, none of which removes a row, and none of them folded to
-- a constant either (#31354), so all three are runtime keys.
--
-- The second overhead is streams that cannot exist.  On dex_c3c1 an equality
-- on c3 derives the bucket exactly, which should leave one stream, but the
-- derived SAOP over all eight buckets is planned as well, so the plan says
-- Merge Streams: 8 while bind-time pruning leaves one read op.  The planner
-- is costing eight streams for work the executor never does, which is the
-- mirror image of the usual complaint that it undercharges for streams.
--
-- The index in the first half is as synthetic as the one in the issue, and
-- says so.  The point is not that anyone writes that index, it is that the
-- derivation fires on every expression key it can regardless of whether the
-- key was already pinned.


-- ---------------------------------------------------------------------
-- Redundant binds.  Every query here derives three conditions that narrow
-- nothing, and the row counts vary so the per-bind cost can be separated
-- from the per-row cost.
-- ---------------------------------------------------------------------
SELECT c1, c4 FROM de16 WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 = 50 ORDER BY c1 LIMIT 1000;
SELECT c1, c4 FROM de16 WHERE c4 = 50 ORDER BY c1;
SELECT c1, c4 FROM de16 WHERE c4 = 50;
SELECT count(*) FROM de16 WHERE c4 = 50;
SELECT c1, c4 FROM de16 WHERE c4 = 50 AND c1 > 250000 ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 = 100 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The same index reached without an equality, so nothing is derived.  A
-- range or an IN list on c4 gives no constant to substitute, which makes
-- these the within-table control for the block above.
-- ---------------------------------------------------------------------
SELECT c1, c4 FROM de16 WHERE c4 BETWEEN 50 AND 50 ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 IN (50) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 IN (50, 51) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM de16 WHERE c4 BETWEEN 50 AND 55 ORDER BY c1 LIMIT 10;
SELECT count(*) FROM de16 WHERE c4 BETWEEN 50 AND 50;


-- ---------------------------------------------------------------------
-- The same shape on a table with no expression keys at all, holding the
-- same rows.  sa_c4c1 is (c4, c1) and nothing can be derived on it, so the
-- pair with the first block is the cost of the redundant binds.
-- ---------------------------------------------------------------------
SELECT c1, c4 FROM sa WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM sa WHERE c4 = 50 ORDER BY c1 LIMIT 1000;
SELECT c1, c4 FROM sa WHERE c4 = 50 ORDER BY c1;
SELECT count(*) FROM sa WHERE c4 = 50;
SELECT c1, c4 FROM sa WHERE c4 = 50 AND c1 > 250000 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Redundant binds inside a join, where they are re-evaluated per probe
-- rather than once, so a per-bind cost is multiplied by the outer rows.
-- ---------------------------------------------------------------------
SELECT d.c4, m.c1 FROM dj d JOIN de16 m ON m.c4 = d.c4 WHERE d.c3 = 500;
SELECT d.c4, m.c1 FROM dj d JOIN sa m ON m.c4 = d.c4 WHERE d.c3 = 500;
SELECT count(*) FROM dj d JOIN de16 m ON m.c4 = d.c4 WHERE d.c3 BETWEEN 1 AND 10;
SELECT count(*) FROM dj d JOIN sa m ON m.c4 = d.c4 WHERE d.c3 BETWEEN 1 AND 10;


-- ---------------------------------------------------------------------
-- Streams planned that cannot exist.  The equality on c3 pins one bucket,
-- yet the derived SAOP over all eight is planned alongside it, so the cost
-- covers eight streams and the executor prunes seven at bind time.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 LIMIT 100;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1;
SELECT c1, c3 FROM dex WHERE c3 = 500 AND c1 > 150000 ORDER BY c1 LIMIT 10;
SELECT count(*) FROM dex WHERE c3 = 500;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 DESC LIMIT 10;


-- ---------------------------------------------------------------------
-- The same lookup where every bucket really does have to be visited,
-- because no equality pins one.  This is what eight streams should cost,
-- and the block above should not be paying it.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM dex WHERE c3 IN (500, 501) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM dex ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM dex ORDER BY c1 LIMIT 100;
SELECT c1, c3 FROM sa WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 = 500 ORDER BY c1;


-- ---------------------------------------------------------------------
-- Wide projections, so any per-bind overhead is measured against a larger
-- per-row cost and the two can be told apart.
-- ---------------------------------------------------------------------
SELECT * FROM de16 WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT * FROM sa WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT * FROM de16 WHERE c4 = 50 ORDER BY c1 LIMIT 1000;
SELECT * FROM sa WHERE c4 = 50 ORDER BY c1 LIMIT 1000;
