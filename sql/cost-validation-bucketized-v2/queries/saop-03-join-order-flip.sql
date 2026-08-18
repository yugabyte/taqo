-- yb_enable_derived_saops: the derivation flipping a join order.
--
-- This is the shape in yugabyte/yugabyte-db#32317, reproduced on this model's
-- tables.  The mechanism: a wide bucketized table carries a filter the
-- storage layer must evaluate row by row and nothing an index can seek on, so
-- without the derivation the only way to use its index is as the inner side
-- of a batched nested loop, driven by the small table.  The derived SAOP
-- gives that table an index condition it did not have, which makes an ordered
-- index scan over it possible, which makes it a candidate for the outer side.
-- The planner then reverses the join order and reads the wide table through
-- 16 streams while filtering nearly everything out.
--
-- Verified on this schema: with the derivation the plan is a batched nested
-- loop whose outer is a 16-stream merge scan over mw16 with the storage
-- filter attached, and without it the plan drives from dj and reaches mw16
-- through a derived-equality index condition on the inner side.  The
-- estimates differ by more than the true costs do, which is the point.
--
-- The filters here are deliberately opaque.  sign(c1 - c2) = 1 is true for
-- about half the rows and the planner cannot see that, position() and
-- length() on v likewise, so in every query the planner is choosing a join
-- order on an estimate it has no basis for.  That is exactly the situation a
-- new path being available is most likely to spoil.
--
-- Aliases are used throughout, as the framework requires for join queries.


-- ---------------------------------------------------------------------
-- The reported shape.  Two-column join, opaque filter on the wide side,
-- ORDER BY on the join columns.
-- ---------------------------------------------------------------------
SELECT w.c1, w.c2, w.v, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 WHERE sign(w.c1 - w.c2) = 1 ORDER BY w.c1, w.c2;
SELECT w.c1, w.c2, w.v, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 ORDER BY w.c1, w.c2;
SELECT w.c1, w.c2, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 WHERE sign(w.c1 - w.c2) = 1 ORDER BY w.c1, w.c2;
SELECT n.c1, n.c2, n.v, d.c3 FROM mn16 n JOIN dj d ON d.c1 = n.c1 AND d.c2 = n.c2 WHERE sign(n.c1 - n.c2) = 1 ORDER BY n.c1, n.c2;
SELECT p.c1, p.c2, p.v, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 AND d.c2 = p.c2 WHERE sign(p.c1 - p.c2) = 1 ORDER BY p.c1, p.c2;


-- ---------------------------------------------------------------------
-- The same with a LIMIT, so the flipped plan also carries an early
-- termination discount it cannot honour: the filter passes about half the
-- rows but the ordering is on the outer side, so the LIMIT does stop the
-- scan, and the comparison is about how much was read to get there.
-- ---------------------------------------------------------------------
SELECT w.c1, w.c2, w.v, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 WHERE sign(w.c1 - w.c2) = 1 ORDER BY w.c1, w.c2 LIMIT 100;
SELECT w.c1, w.c2, w.v, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 ORDER BY w.c1, w.c2 LIMIT 100;
SELECT n.c1, n.c2, d.c3 FROM mn16 n JOIN dj d ON d.c1 = n.c1 AND d.c2 = n.c2 WHERE sign(n.c1 - n.c2) = 1 ORDER BY n.c1, n.c2 LIMIT 100;
SELECT p.c1, p.c2, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 AND d.c2 = p.c2 WHERE sign(p.c1 - p.c2) = 1 ORDER BY p.c1, p.c2 LIMIT 100;


-- ---------------------------------------------------------------------
-- Single column join, where the derived path on the bucketized side is
-- ordered on the join key and a merge join becomes possible as well.
-- ---------------------------------------------------------------------
SELECT m.c1, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE sign(m.c1 - m.c2) = 1 ORDER BY m.c1;
SELECT m.c1, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 ORDER BY m.c1;
SELECT m.c1, d.c3 FROM mb64 m JOIN dj d ON d.c1 = m.c1 WHERE sign(m.c1 - m.c2) = 1 ORDER BY m.c1;
SELECT p.c1, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE sign(p.c1 - p.c2) = 1 ORDER BY p.c1;
SELECT m.c1, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE sign(m.c1 - m.c2) = 1 ORDER BY m.c1 LIMIT 100;
SELECT p.c1, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE sign(p.c1 - p.c2) = 1 ORDER BY p.c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- Opaque filters of other kinds, so the finding does not depend on one
-- expression being unusually badly estimated.  v is a constant 64 or 4096
-- characters, so length(v) > 8 passes every row and position('zzz' in v)
-- passes none, and the planner's estimate for both is a default.
-- ---------------------------------------------------------------------
SELECT w.c1, w.c2, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 WHERE length(w.v) > 8 ORDER BY w.c1;
SELECT w.c1, w.c2, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 WHERE position('zzz' in w.v) > 0 ORDER BY w.c1;
SELECT m.c1, m.c2, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE length(m.v) > 8 ORDER BY m.c1;
SELECT m.c1, m.c2, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE position('zzz' in m.v) > 0 ORDER BY m.c1;
SELECT p.c1, p.c2, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE length(p.v) > 8 ORDER BY p.c1;
SELECT p.c1, p.c2, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE position('zzz' in p.v) > 0 ORDER BY p.c1;


-- ---------------------------------------------------------------------
-- No ORDER BY at all, so the derived path has nothing to sell and the join
-- order should be decided on scan costs alone.  A flip here would be the
-- purest form of the #32317 symptom.
-- ---------------------------------------------------------------------
SELECT w.c1, w.c2, d.c3 FROM mw16 w JOIN dj d ON d.c1 = w.c1 AND d.c2 = w.c2 WHERE sign(w.c1 - w.c2) = 1;
SELECT m.c1, d.c3 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE sign(m.c1 - m.c2) = 1;
SELECT p.c1, d.c3 FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE sign(p.c1 - p.c2) = 1;
SELECT count(*) FROM mw16 w JOIN dj d ON d.c1 = w.c1 WHERE sign(w.c1 - w.c2) = 1;
SELECT count(*) FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE sign(m.c1 - m.c2) = 1;
SELECT count(*) FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE sign(p.c1 - p.c2) = 1;


-- ---------------------------------------------------------------------
-- Three tables, so a flipped scan choice has more join orders to spoil and
-- the wide table can end up anywhere in the plan.
-- ---------------------------------------------------------------------
SELECT w.c1, d.c3, m.c4 FROM mw16 w JOIN dj d ON d.c1 = w.c1 JOIN mb16 m ON m.c1 = w.c1 WHERE sign(w.c1 - w.c2) = 1 ORDER BY w.c1;
SELECT w.c1, d.c3, m.c4 FROM mw16 w JOIN dj d ON d.c1 = w.c1 JOIN mplain m ON m.c1 = w.c1 WHERE sign(w.c1 - w.c2) = 1 ORDER BY w.c1;
SELECT count(*) FROM mw16 w JOIN dj d ON d.c1 = w.c1 JOIN mb16 m ON m.c1 = w.c1 WHERE sign(w.c1 - w.c2) = 1;
