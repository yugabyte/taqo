-- yb_enable_derived_saops: the user-written form of the condition the
-- planner derives.
--
-- "bucket IN (0 .. B-1)" is the same predicate whether the planner fabricates
-- it or the user types it, but the two take different routes to a row
-- estimate.  The derived form is not a restriction clause and never goes
-- through clause selectivity, so the scan keeps the full row count.  The
-- written form does go through it, and lands on a floating point boundary:
-- upstream's scalararraysel computes the correct disjoint sum for an equality
-- IN list but accepts it only if it is at most exactly 1.0, and MCV
-- frequencies are stored as float4, so a full-domain IN sums to 1.0 give or
-- take a few 1e-8 depending on how the ANALYZE sample rounded.  Landing above
-- it by 4e-9 silently switches the estimate to the independence formula,
-- about 0.64 of the table at 16 buckets.  That is yugabyte/yugabyte-db#33251,
-- and it means the same query can plan differently after two ANALYZE runs on
-- identical data.
--
-- Every pair below is a written IN list against the identical query with the
-- predicate removed so the planner derives it.  A cost difference inside a
-- pair is an estimation difference, not a plan-mechanics difference, and the
-- partial lists are the control: they are not on the 1.0 boundary and should
-- be estimated consistently.
--
-- These are the only queries in the model that write a full-domain IN on a
-- bucket column.  Everywhere else the derivation is left to the planner,
-- because the written form is both unrealistic and unstable.


-- ---------------------------------------------------------------------
-- Full domain written out against left to the planner, at 16 buckets.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mb16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
SELECT count(*) FROM mb16;


-- ---------------------------------------------------------------------
-- The same at 2 and at 4 buckets, where the disjoint sum has fewer rounded
-- terms and should be less likely to cross 1.0.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 WHERE c0 IN (0,1) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb2 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mb2 WHERE c0 IN (0,1);
SELECT c1, c2 FROM mb4 WHERE c0 IN (0,1,2,3) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb4 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mb4 WHERE c0 IN (0,1,2,3);


-- ---------------------------------------------------------------------
-- And at 64 buckets, the most rounded terms in the model and the most
-- likely to flip.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb64 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mb64 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63);
SELECT count(*) FROM mb64;


-- ---------------------------------------------------------------------
-- Partial lists, the control.  A list short of the full domain is a normal
-- selectivity estimate nowhere near the 1.0 boundary, and it also produces
-- fewer streams than the derivation would, which no derived form can do.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE c0 IN (0,1) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 WHERE c0 IN (0,1,2,3) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 WHERE c0 IN (0,1,2,3,4,5,6,7) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 WHERE c0 = 0 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mb16 WHERE c0 IN (0,1,2,3);
SELECT count(*) FROM mb16 WHERE c0 = 0;


-- ---------------------------------------------------------------------
-- A written list that covers the domain but says so twice.  The elements
-- are not distinct, which is the case the 1.0 guard actually exists to
-- catch, so this one is expected to fall back and is the honest comparison
-- for what the guard is for.
-- ---------------------------------------------------------------------
SELECT count(*) FROM mb4 WHERE c0 IN (0,1,2,3,0,1,2,3);
SELECT c1, c2 FROM mb4 WHERE c0 IN (0,1,2,3,0,1,2,3) ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- The written form combined with a second merge-eligible IN list, so the
-- estimate error and the stream product interact.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) AND c6 IN (1,2) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2) ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM ms16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) AND c6 IN (1,2);
SELECT count(*) FROM ms16 WHERE c6 IN (1,2);


-- ---------------------------------------------------------------------
-- The estimate feeding a join, where a 0.64x scan estimate propagates into
-- the join sizing and the join order.
-- ---------------------------------------------------------------------
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1 LIMIT 100;
SELECT count(*) FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
SELECT count(*) FROM mb16 m JOIN dj d ON d.c1 = m.c1;
