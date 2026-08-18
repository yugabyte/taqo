-- yb_enable_derived_saops: choosing between the path with the derived SAOP
-- and the path without it.
--
-- A derived SAOP is not a query condition.  When an index key is a bucket
-- expression, or a column generated from one, the planner fabricates
-- "bucket IN (0 .. B-1)", which every row satisfies, purely so the index can
-- be seeked and merged.  The condition adds no selectivity and removes no
-- rows.  What it adds is a path: an index that could not be used at all
-- without a predicate on its leading key becomes usable, ordered, and
-- competitive.
--
-- Derived SAOPs only attach to merge scan index paths, so this GUC cannot
-- regress a plan that has no merge in it.  The planner keeps the path without
-- the derivation alongside the one with it and takes the cheaper, which makes
-- every query here a cost comparison and nothing else.  A wrong answer is a
-- cost model error, and some of the errors this file finds will not be
-- specific to merge scan at all: an index scan with a 100 % passing condition
-- competing against a sequential scan is the general symptom in
-- yugabyte/yugabyte-db#32317.
--
-- Each block pairs a query where the derivation clearly earns its cost with
-- one where it clearly does not, and puts the ambiguous shapes between them.
-- mplain twins run the same query where no derivation is possible, so the
-- pair brackets what the derived path is worth.


-- ---------------------------------------------------------------------
-- The derivation earns it: ordered, small LIMIT, no other ordered path.
-- Without the derived SAOP these have to sort the whole table.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mw16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The derivation cannot earn anything: nothing above the scan wants an
-- order, so the only thing a merge path can do is cost more.  A derived
-- SAOP appearing in any of these is the yugabyte/yugabyte-db#32317 symptom,
-- an index scan preferred on the strength of a condition that passes every
-- row.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE c4 = 50;
SELECT c1, c2 FROM mplain WHERE c4 = 50;
SELECT c1, c2 FROM mb16 WHERE sign(c1 - c2) = 1;
SELECT c1, c2 FROM mplain WHERE sign(c1 - c2) = 1;
SELECT c1, c2, v FROM mw16 WHERE sign(c1 - c2) = 1;
SELECT count(*) FROM mb16 WHERE sign(c1 - c2) = 1;
SELECT count(*) FROM mplain WHERE sign(c1 - c2) = 1;
SELECT c1, c2 FROM mb16 WHERE c5 > 250000;
SELECT c1, c2 FROM mplain WHERE c5 > 250000;


-- ---------------------------------------------------------------------
-- Ordered, but the filter is one the storage layer has to evaluate on every
-- row, so neither path terminates early and the merge's streams are pure
-- overhead on top of a full read.  This is the single-table form of the
-- #32317 join shape.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2, v FROM mw16 WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mn16 WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mplain WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Ordered with no LIMIT, so the merge saves a sort and nothing else.  The
-- sort it saves is over 500000 rows, which is a real saving, and the
-- question is only whether it is worth 16 or 64 streams.
-- ---------------------------------------------------------------------
SELECT c1 FROM mb16 ORDER BY c1;
SELECT c1 FROM mb64 ORDER BY c1;
SELECT c1 FROM mplain ORDER BY c1;
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mb64 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mplain ORDER BY c1 OFFSET 499990 LIMIT 10;


-- ---------------------------------------------------------------------
-- The projection decides whether the merge path is covering.  Selecting
-- only key columns keeps it an index only scan, and adding c4 forces a heap
-- fetch per row on top of the streams.
-- ---------------------------------------------------------------------
SELECT c1 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2, c4 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT * FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT c1 FROM mplain ORDER BY c1 LIMIT 1000;
SELECT c1, c2, c4 FROM mplain ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Ordering consumed by something other than ORDER BY.  The derivation is
-- what makes the ordered input available, so these are the same arbitration
-- with a different buyer.
-- ---------------------------------------------------------------------
SELECT c1, count(*) FROM mb16 GROUP BY c1 ORDER BY c1 LIMIT 100;
SELECT c1, count(*) FROM mplain GROUP BY c1 ORDER BY c1 LIMIT 100;
SELECT DISTINCT ON (c1) c1, c4 FROM mb16 ORDER BY c1 LIMIT 100;
SELECT DISTINCT ON (c1) c1, c4 FROM mplain ORDER BY c1 LIMIT 100;
SELECT c4, count(*) FROM mb16 GROUP BY c4 ORDER BY c4;
SELECT c4, count(*) FROM mplain GROUP BY c4 ORDER BY c4;


-- ---------------------------------------------------------------------
-- Ordering by a column the bucketized key does not lead with, so the
-- derived SAOP cannot deliver it and no merge should appear.  These are the
-- negative control for the whole file.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c4 LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c5 LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c5 LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c2 LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c2 LIMIT 100;


-- ---------------------------------------------------------------------
-- The derivation on an expression index rather than a generated column.
-- dex_c1c2's leading key is the bucket expression itself, which reaches the
-- derivation through a different code path, and dex has a plain primary key
-- on c2 as the alternative.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM dex ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM dex ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM dex ORDER BY c1 OFFSET 299990 LIMIT 10;
SELECT c1, c2 FROM dex WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM dex WHERE sign(c1 - c2) = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM dex WHERE sign(c1 - c2) = 1;
SELECT count(*) FROM dex;
