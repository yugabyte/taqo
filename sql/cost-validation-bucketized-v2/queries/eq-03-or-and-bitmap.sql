-- yb_enable_derived_equalities: OR conditions and bitmap scans.
--
-- Individual arms of an OR do not form equivalence classes, so the derivation
-- for them runs through a separate path in the planner that reads the arms'
-- Var = Const bindings directly.  That makes an OR the one place where the
-- derivation can fire for one branch and not another, and where each branch
-- gets its own index condition, so it is worth its own file.
--
-- It is also where yugabyte/yugabyte-db#31354 is visible.  The derivation
-- substitutes the constant into the generation expression but never runs the
-- result through const folding, because const folding happens during query
-- preprocessing and the derivation happens later, during path generation.  So
-- the plan carries "c0 = (yb_hash_code(123456) % 16)" rather than "c0 = 2".
-- The executor classifies a non-Const right hand side as a runtime key, and
-- for a bitmap index scan any runtime key sets the might-recheck flag, which
-- puts a Recheck Cond and a Storage Recheck Cond in the plan that a folded
-- constant would not.  Verified on this schema: the OR queries below produce
-- exactly that, with the unfolded expression in both the Bitmap Index Scan's
-- Index Cond and the Bitmap Table Scan's Recheck Cond.
--
-- de16 has the bucketized primary key on (c0, c2, c1) and a plain index on
-- (c3, c1), so a two-armed OR can put one arm on each and the BitmapOr has
-- something real to combine.  de2c and dex give the two-column and
-- expression-index forms of the same thing.


-- ---------------------------------------------------------------------
-- One arm on the derived bucket, one arm on a plain index.  This is the
-- BitmapOr shape, and it is where the unfolded runtime key appears.
-- ---------------------------------------------------------------------
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c3 = 500;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c3 = 1;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 1 OR c2 = 123456;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 1 OR c2 = 2 OR c2 = 3;
SELECT count(*) FROM de16 WHERE c2 = 123456 OR c3 = 500;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c3 = 500 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Arms of unequal weight, so the planner has to decide whether combining
-- them beats scanning for the cheaper one and filtering.
-- ---------------------------------------------------------------------
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c3 BETWEEN 1 AND 50;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c4 = 50;
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c5 = 250000;
SELECT c1, c2, c3 FROM de16 WHERE c3 = 500 OR c3 = 501;
SELECT count(*) FROM de16 WHERE c2 = 123456 OR c4 = 50;


-- ---------------------------------------------------------------------
-- An OR where one arm can be derived and the other cannot, because it uses
-- a range rather than an equality.  Only half of this query benefits.
-- ---------------------------------------------------------------------
SELECT c1, c2, c3 FROM de16 WHERE c2 = 123456 OR c2 BETWEEN 1 AND 100;
SELECT c1, c2, c3 FROM de16 WHERE c2 BETWEEN 1 AND 100 OR c3 = 500;
SELECT c1, c2, c3 FROM de16 WHERE c2 IN (1, 2, 3) OR c3 = 500;


-- ---------------------------------------------------------------------
-- Conjunctions of arms, which give a BitmapAnd rather than a BitmapOr and
-- reach the derivation from the other side.
-- ---------------------------------------------------------------------
SELECT c1, c2, c3 FROM de16 WHERE c3 = 500 AND c4 = 50;
SELECT c1, c2, c3 FROM de16 WHERE (c2 = 123456 OR c3 = 500) AND c4 = 50;
SELECT c1, c2, c3 FROM de16 WHERE (c2 = 123456 OR c3 = 500) AND (c4 = 50 OR c6 = 1);
SELECT count(*) FROM de16 WHERE (c2 = 123456 OR c3 = 500) AND c4 = 50;


-- ---------------------------------------------------------------------
-- The two-column generation expression under an OR.  An arm that pins only
-- c2 cannot derive the bucket, and an arm that pins c2 and c6 can, so the
-- two arms of one query take different paths.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM de2c WHERE (c2 = 12345 AND c6 = 3) OR (c2 = 54321 AND c6 = 5);
SELECT c1, c2 FROM de2c WHERE (c2 = 12345 AND c6 = 3) OR c2 = 54321;
SELECT c1, c2 FROM de2c WHERE c2 = 12345 OR c2 = 54321;
SELECT count(*) FROM de2c WHERE (c2 = 12345 AND c6 = 3) OR (c2 = 54321 AND c6 = 5);


-- ---------------------------------------------------------------------
-- The expression index under an OR, where the derived condition is on the
-- index expression itself rather than on a stored column.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM dex WHERE c3 = 500 OR c3 = 501;
SELECT c1, c3 FROM dex WHERE c3 = 500 OR c4 = 50;
SELECT c1, c3 FROM dex WHERE c3 = 500 OR c2 = 12345;
SELECT count(*) FROM dex WHERE c3 = 500 OR c3 = 501;
SELECT c1, c3 FROM dex WHERE c3 = 500 OR c3 = 501 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The same queries against tables where nothing can be derived, so the
-- bitmap plans are the plain form of each shape.  sa and mplain hold the
-- same rows as de16.
-- ---------------------------------------------------------------------
SELECT c1, c2, c3 FROM sa WHERE c2 = 123456 OR c3 = 500;
SELECT c1, c2, c3 FROM sa WHERE c3 = 500 OR c4 = 50;
SELECT c1, c2, c3 FROM mplain WHERE c1 = 123456 OR c3 = 500;
SELECT count(*) FROM sa WHERE c2 = 123456 OR c3 = 500;


-- ---------------------------------------------------------------------
-- Rescan, where the unfolded expression is re-evaluated for every outer
-- row rather than being a constant fixed in the plan.
-- ---------------------------------------------------------------------
SELECT d.c2, m.c1 FROM dj d JOIN de16 m ON m.c2 = d.c2 WHERE m.c3 = 500 OR m.c4 = 50;
SELECT d.c3, x.c1 FROM dj d JOIN dex x ON x.c3 = d.c3 WHERE x.c4 = 50 OR x.c6 = 1;
SELECT count(*) FROM dj d JOIN de16 m ON m.c2 = d.c2 WHERE m.c3 = 500 OR m.c4 = 50;
