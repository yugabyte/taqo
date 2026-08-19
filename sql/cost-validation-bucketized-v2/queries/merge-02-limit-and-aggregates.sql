-- Merge scan: how LIMIT is priced, and what happens when no LIMIT reaches
-- the scan at all.
--
-- An ordered scan under a LIMIT is priced assuming it stops early.  For a
-- merge scan that assumption is doubly optimistic: the LIMIT is stamped on
-- the template read op before it is cloned, so the first fetch round asks
-- every stream for min(LIMIT, yb_fetch_row_limit) rows, and a stream that has
-- to page again resets its limit to the full fetch page rather than to what
-- the query still needs.  Cost should therefore be flat inside a fetch page
-- and step across it, and it should scale with the stream count in both
-- regimes.
--
-- The second half of the file removes the LIMIT from the scan's reach.  An
-- aggregate consumes every input row, so any early-termination discount the
-- model applied is unearned, and how badly that shows depends on how
-- aggressive the discount is.  These queries are the constraint on how far
-- the LIMIT discount in a corrected model is allowed to go.


-- ---------------------------------------------------------------------
-- LIMIT sweep across the default 1024-row fetch page on the 16-bucket
-- table.  Costs and times should be flat from 1 to 1024 and step at 1025.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 512;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1023;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1024;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1025;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 2048;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 2049;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10000;


-- ---------------------------------------------------------------------
-- The same sweep at 64 streams, where each step of the boundary costs 64
-- times as much fetch work as it does on mplain.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1023;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1025;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 2049;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 10000;


-- ---------------------------------------------------------------------
-- The same sweep with no streams, as the reference for the two above.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 1023;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 1025;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 2049;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 10000;


-- ---------------------------------------------------------------------
-- OFFSET pushes the boundary without changing the result size.  The scan
-- must produce offset + limit rows, so the cost should track the sum.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 1000 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 10000 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 100000 LIMIT 10;
SELECT c1, c2 FROM mb64 ORDER BY c1 OFFSET 100000 LIMIT 10;
SELECT c1, c2 FROM mplain ORDER BY c1 OFFSET 100000 LIMIT 10;


-- ---------------------------------------------------------------------
-- A LIMIT under a subquery boundary still reaches the scan.  Its twin
-- below, with the aggregate on the outside, does not stop the scan early
-- but does return one row, so the two isolate the discount from the volume
-- of rows returned.
-- ---------------------------------------------------------------------
SELECT count(*) FROM (SELECT c1 FROM mb16 ORDER BY c1 LIMIT 1000) s;
SELECT count(*) FROM (SELECT c1 FROM mb64 ORDER BY c1 LIMIT 1000) s;
SELECT count(*) FROM (SELECT c1 FROM mplain ORDER BY c1 LIMIT 1000) s;


-- ---------------------------------------------------------------------
-- Aggregates over the whole table.  No LIMIT reaches the scan, so ordering
-- buys nothing and any merge path here is pure overhead.
-- ---------------------------------------------------------------------
SELECT count(*) FROM mb16;
SELECT count(*) FROM mb64;
SELECT count(*) FROM mplain;
SELECT avg(c4) FROM mb16;
SELECT avg(c4) FROM mb64;
SELECT avg(c4) FROM mplain;
SELECT count(*) FROM mb16 WHERE c4 = 50;
SELECT count(*) FROM mb64 WHERE c4 = 50;
SELECT count(*) FROM mplain WHERE c4 = 50;


-- ---------------------------------------------------------------------
-- min and max on the second key column.  On mplain this is one seek to
-- either end of the index.  On the bucketized tables the extreme is
-- whichever bucket happens to hold it, so the answer requires touching all
-- of them, and whether the planner charges for that is the question.
-- ---------------------------------------------------------------------
SELECT min(c1) FROM mb16;
SELECT max(c1) FROM mb16;
SELECT min(c1) FROM mb64;
SELECT max(c1) FROM mb64;
SELECT min(c1) FROM mplain;
SELECT max(c1) FROM mplain;
SELECT min(c1), max(c1) FROM mb16;
SELECT min(c1), max(c1) FROM mplain;


-- ---------------------------------------------------------------------
-- Grouping consumes every row regardless of the LIMIT above it, but the
-- ordered input can still save the sort, so these are the cases where the
-- merge path earns something without earning early termination.
-- ---------------------------------------------------------------------
SELECT c1, count(*) FROM mb16 GROUP BY c1 ORDER BY c1 LIMIT 100;
SELECT c1, count(*) FROM mb64 GROUP BY c1 ORDER BY c1 LIMIT 100;
SELECT c1, count(*) FROM mplain GROUP BY c1 ORDER BY c1 LIMIT 100;
SELECT c4, count(*) FROM mb16 GROUP BY c4 ORDER BY c4 LIMIT 10;
SELECT c4, count(*) FROM mb64 GROUP BY c4 ORDER BY c4 LIMIT 10;
SELECT c4, count(*) FROM mplain GROUP BY c4 ORDER BY c4 LIMIT 10;
