-- Merge scan: sensitivity to row width.
--
-- mn16 and mw16 hold the same 50000 rows in the same 16-bucket layout and
-- differ only in the width of v, 64 characters against 4096.  Every query
-- below runs on both, so within a pair the bytes per row are the only
-- variable.  mb16 appears in a few places as the same schema at ten times the
-- rows, which separates width from row count.
--
-- Why width matters more for a merge scan than for a plain ordered scan: the
-- first fetch round asks every stream for min(LIMIT, fetch page) rows at
-- once, so the bytes in flight are stream count times LIMIT times row width
-- rather than LIMIT times row width.  At 16 streams, LIMIT 1000 and 4 KB
-- rows that is 64 MB moved to return 4 MB.  A plain ordered scan on the same
-- data moves the 4 MB and nothing more.  The cost model charges a flat 2 %
-- over the plain scan in both cases.
--
-- Note that selecting v is what makes width bite.  The narrow projections
-- below are the control: they read the same index entries and should show
-- little difference between the two tables.


-- ---------------------------------------------------------------------
-- Narrow projection, the control.  v is never touched, so the two tables
-- should behave alike.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mn16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mw16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mn16 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mw16 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mn16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mw16 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Wide projection at the same limits.  This is the same query grid with v
-- added, so the difference between this block and the one above is exactly
-- the cost of moving the payload through the streams.
-- ---------------------------------------------------------------------
SELECT c1, c2, v FROM mn16 ORDER BY c1 LIMIT 10;
SELECT c1, c2, v FROM mw16 ORDER BY c1 LIMIT 10;
SELECT c1, c2, v FROM mn16 ORDER BY c1 LIMIT 100;
SELECT c1, c2, v FROM mw16 ORDER BY c1 LIMIT 100;
SELECT c1, c2, v FROM mn16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2, v FROM mw16 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- SELECT * at a small limit, the shape an application actually writes.
-- ---------------------------------------------------------------------
SELECT * FROM mn16 ORDER BY c1 LIMIT 10;
SELECT * FROM mw16 ORDER BY c1 LIMIT 10;
SELECT * FROM mn16 ORDER BY c1 DESC LIMIT 10;
SELECT * FROM mw16 ORDER BY c1 DESC LIMIT 10;


-- ---------------------------------------------------------------------
-- Filtered, so more rows must be read per row returned and the wasted
-- bytes multiply accordingly.  About one row in a hundred qualifies.
-- ---------------------------------------------------------------------
SELECT c1, c2, v FROM mn16 WHERE c4 = 50 ORDER BY c1 LIMIT 50;
SELECT c1, c2, v FROM mw16 WHERE c4 = 50 ORDER BY c1 LIMIT 50;
SELECT c1, c2 FROM mn16 WHERE c4 = 50 ORDER BY c1 LIMIT 50;
SELECT c1, c2 FROM mw16 WHERE c4 = 50 ORDER BY c1 LIMIT 50;


-- ---------------------------------------------------------------------
-- Full drain with a small result, so the whole table passes through the
-- ordered path at both widths.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mn16 ORDER BY c1 OFFSET 49990 LIMIT 10;
SELECT c1, c2 FROM mw16 ORDER BY c1 OFFSET 49990 LIMIT 10;
SELECT c1, c2, v FROM mn16 ORDER BY c1 OFFSET 49990 LIMIT 10;
SELECT c1, c2, v FROM mw16 ORDER BY c1 OFFSET 49990 LIMIT 10;


-- ---------------------------------------------------------------------
-- Row count against width.  mb16 is mn16 with ten times the rows and the
-- narrow payload, so comparing the three tells whether the model's response
-- to width and to row count are separately right.
-- ---------------------------------------------------------------------
SELECT c1, c2, v FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT count(*) FROM mn16 WHERE c4 = 50;
SELECT count(*) FROM mw16 WHERE c4 = 50;
SELECT count(*) FROM mb16 WHERE c4 = 50;
