-- yb_enable_derived_equalities: joins.
--
-- This is where the derivation is worth the most and where it is most
-- dangerous.  On the inner side of a nested loop the outer row supplies the
-- entity id, and the planner substitutes it into the generation expression to
-- produce a bucket condition per probe, so the inner scan is one seek rather
-- than a visit to every bucket.  Without it a bucketized table is close to
-- unusable as an inner side, which means the derivation is not an
-- optimization here so much as the thing that makes the schema work.
--
-- The danger is on the other side of the same coin.  A path that only exists
-- because of a derived condition is a path the planner did not have before,
-- and it can win the join order on an estimate rather than on merit, which is
-- the mechanism saop-03 covers for derived SAOPs.  The derived condition is
-- also a runtime key rather than a constant (yugabyte/yugabyte-db#31354), so
-- it is re-evaluated on every rescan, which a per-probe cost should account
-- for and today does not.
--
-- dj holds 20000 rows with c1 = 1..20000 and c2 a permutation of the same
-- range, so every join here matches 20000 rows exactly once.  mplain and sa
-- appear as the sides where no derivation is possible.
--
-- Aliases are used throughout, as the framework requires for join queries.


-- ---------------------------------------------------------------------
-- The bucketized table as inner, probed on the column its bucket is
-- generated from.  Each probe can be a single seek only if the bucket is
-- derived from the outer row's value.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2 WHERE d.c4 = 1;
SELECT d.c2, m.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2 WHERE d.c4 IN (1,2,3,4);
SELECT d.c2, m.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2;
SELECT count(*) FROM dj d JOIN de16 m ON m.c2 = d.c2;
SELECT d.c2, m.c1, m.c3 FROM dj d JOIN de16 m ON m.c2 = d.c2 WHERE d.c4 = 1 ORDER BY d.c2 LIMIT 100;
SELECT d.c2, m.c1 FROM dj d JOIN mplain m ON m.c2 = d.c2 WHERE d.c4 = 1;
SELECT count(*) FROM dj d JOIN mplain m ON m.c2 = d.c2;


-- ---------------------------------------------------------------------
-- Both generation columns supplied by the join, so the two-column bucket
-- can be derived, against only one of them supplied, where it cannot.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1 FROM dj d JOIN de2c m ON m.c2 = d.c2 AND m.c6 = d.c6 WHERE d.c4 = 1;
SELECT d.c2, m.c1 FROM dj d JOIN de2c m ON m.c2 = d.c2 WHERE d.c4 = 1;
SELECT count(*) FROM dj d JOIN de2c m ON m.c2 = d.c2 AND m.c6 = d.c6;
SELECT count(*) FROM dj d JOIN de2c m ON m.c2 = d.c2;
SELECT d.c2, m.c1, m.c3 FROM dj d JOIN de2c m ON m.c2 = d.c2 AND m.c6 = d.c6 ORDER BY d.c2 LIMIT 100;


-- ---------------------------------------------------------------------
-- The expression index as inner, probed on the entity column.  Here the
-- derivation pins the bucket and the index still supplies c1 order inside
-- it, so the inner side is both seekable and ordered.
-- ---------------------------------------------------------------------
SELECT d.c3, x.c1 FROM dj d JOIN dex x ON x.c3 = d.c3 WHERE d.c4 = 1;
SELECT d.c3, x.c1 FROM dj d JOIN dex x ON x.c3 = d.c3 WHERE d.c4 = 1 ORDER BY d.c3, x.c1 LIMIT 100;
SELECT count(*) FROM dj d JOIN dex x ON x.c3 = d.c3;
SELECT d.c3, count(*) FROM dj d JOIN dex x ON x.c3 = d.c3 GROUP BY d.c3 ORDER BY d.c3 LIMIT 100;
SELECT d.c3, x.c1 FROM dj d JOIN sa x ON x.c3 = d.c3 WHERE d.c4 = 1;


-- ---------------------------------------------------------------------
-- The bucketized side as outer, so the derivation has nothing to do and
-- the plans should match the ones with the GUC off.  These bracket the
-- blocks above.
-- ---------------------------------------------------------------------
SELECT m.c2, d.c1 FROM de16 m JOIN dj d ON d.c2 = m.c2 WHERE m.c4 = 1;
SELECT m.c2, d.c1 FROM de16 m JOIN dj d ON d.c2 = m.c2 ORDER BY m.c2 LIMIT 100;
SELECT m.c2, d.c1 FROM de2c m JOIN dj d ON d.c2 = m.c2 AND d.c6 = m.c6 WHERE m.c4 = 1;


-- ---------------------------------------------------------------------
-- Semi and anti joins, which reach the inner side through a different path
-- in the planner and derive separately.
-- ---------------------------------------------------------------------
SELECT d.c2 FROM dj d WHERE EXISTS (SELECT 1 FROM de16 m WHERE m.c2 = d.c2 AND m.c4 = 1);
SELECT d.c2 FROM dj d WHERE NOT EXISTS (SELECT 1 FROM de16 m WHERE m.c2 = d.c2 AND m.c4 = 1);
SELECT d.c2 FROM dj d WHERE EXISTS (SELECT 1 FROM de2c m WHERE m.c2 = d.c2 AND m.c6 = d.c6);
SELECT d.c3 FROM dj d WHERE EXISTS (SELECT 1 FROM dex x WHERE x.c3 = d.c3 AND x.c4 = 1);
SELECT d.c2 FROM dj d WHERE EXISTS (SELECT 1 FROM mplain m WHERE m.c2 = d.c2 AND m.c4 = 1);
SELECT count(*) FROM dj d WHERE d.c2 IN (SELECT m.c2 FROM de16 m WHERE m.c4 = 1);


-- ---------------------------------------------------------------------
-- Outer joins, where the inner side is probed for every outer row whether
-- it matches or not, so a per-probe cost error is paid in full.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1 FROM dj d LEFT JOIN de16 m ON m.c2 = d.c2 AND m.c4 = 1;
SELECT d.c2, m.c1 FROM dj d LEFT JOIN de2c m ON m.c2 = d.c2 AND m.c6 = d.c6;
SELECT d.c3, x.c1 FROM dj d LEFT JOIN dex x ON x.c3 = d.c3 AND x.c4 = 1;
SELECT count(*) FROM dj d LEFT JOIN de16 m ON m.c2 = d.c2;


-- ---------------------------------------------------------------------
-- Aggregation above the join, so no LIMIT reaches either side and the
-- comparison is on total work rather than on early termination.
-- ---------------------------------------------------------------------
SELECT d.c4, count(*), avg(m.c3) FROM dj d JOIN de16 m ON m.c2 = d.c2 GROUP BY d.c4 ORDER BY d.c4;
SELECT d.c4, count(*), avg(m.c3) FROM dj d JOIN mplain m ON m.c2 = d.c2 GROUP BY d.c4 ORDER BY d.c4;
SELECT d.c4, count(*) FROM dj d JOIN dex x ON x.c3 = d.c3 GROUP BY d.c4 ORDER BY d.c4;


-- ---------------------------------------------------------------------
-- Three tables, so the derivation has more than one join order to change.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1, x.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2 JOIN dex x ON x.c3 = d.c3 WHERE d.c4 = 1;
SELECT count(*) FROM dj d JOIN de16 m ON m.c2 = d.c2 JOIN de2c e ON e.c2 = d.c2 AND e.c6 = d.c6;
SELECT d.c2, m.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2 JOIN mplain p ON p.c1 = d.c1 WHERE d.c4 = 1 ORDER BY d.c2 LIMIT 100;
