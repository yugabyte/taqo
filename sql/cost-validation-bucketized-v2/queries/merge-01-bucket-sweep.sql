-- Merge scan: bucket count sweep.
--
-- mb2, mb4, mb16 and mb64 hold identical rows and differ only in the number
-- of buckets, and mplain holds the same rows with a plain ordered primary key
-- and no streams at all.  Each query shape below is repeated across all five,
-- so within a shape the stream count is the only thing that changes.
--
-- What this is for: today the cost model's only merge-specific behavior is
-- multiplying the plain scan cost by 1.02 (yugabyte/yugabyte-db#29078), so it
-- charges the same for 2 streams as for 64.  The executor does not.  Every
-- stream is handed the full LIMIT and the merge cannot emit a row until all
-- of them have returned their first page, so both the fetch work and the time
-- to first row grow with the bucket count.  A cost model that has learned to
-- see stream count should produce a cost that rises across mb2, mb4, mb16 and
-- mb64 within each shape, and the mplain row is the floor those costs are
-- rising above.
--
-- These tables carry no index besides the bucketized primary key, so the only
-- alternative to merge scan is a sort over a full scan.  That is deliberate:
-- a plain (c1 asc) index would be the hot shard the bucketing exists to
-- avoid, and its presence would make the comparison meaningless.  The rival
-- suite covers the case where such an index exists anyway.


-- ---------------------------------------------------------------------
-- LIMIT 1: the pure startup cost of the merge.  Every stream still fetches
-- a page even though one row is wanted, and nothing is emitted until the
-- last of them answers.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mb4 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 1;


-- ---------------------------------------------------------------------
-- LIMIT 10, still far below the 1024-row fetch page, so the work per stream
-- is unchanged from LIMIT 1 and only the returned row count differs.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb4 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- LIMIT 1000: the first round fetches min(LIMIT, fetch page) rows per
-- stream, so mb64 reads about 64000 rows to return 1000 while mplain reads
-- about 1000.  This is where the per-stream fetch term should show up most
-- clearly in a corrected model.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb4 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- LIMIT 1100, just past the default yb_fetch_row_limit of 1024, so a second
-- fetch round is required.  Compare against the LIMIT 1000 row above: the
-- cost should step here and be flat below.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 LIMIT 1100;
SELECT c1, c2 FROM mb4 ORDER BY c1 LIMIT 1100;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1100;
SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1100;
SELECT c1, c2 FROM mplain ORDER BY c1 LIMIT 1100;


-- ---------------------------------------------------------------------
-- Full drain with a small result: OFFSET forces every row through the
-- ordered path while only ten come back, so the row count returned does not
-- confound the measurement.  No early termination discount is earned here.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mb4 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mb64 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mplain ORDER BY c1 OFFSET 499990 LIMIT 10;


-- ---------------------------------------------------------------------
-- Descending order.  The bucketized keys are all ascending, so this is the
-- backward merge, which pages the same way forward does.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 ORDER BY c1 DESC LIMIT 100;
SELECT c1, c2 FROM mb4 ORDER BY c1 DESC LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c1 DESC LIMIT 100;
SELECT c1, c2 FROM mb64 ORDER BY c1 DESC LIMIT 100;
SELECT c1, c2 FROM mplain ORDER BY c1 DESC LIMIT 100;


-- ---------------------------------------------------------------------
-- Wide projection.  Selecting v takes the query off the covering path and
-- makes each fetched row about 64 bytes larger, which multiplies by the
-- stream count in the first fetch round.
-- ---------------------------------------------------------------------
SELECT * FROM mb2 ORDER BY c1 LIMIT 100;
SELECT * FROM mb4 ORDER BY c1 LIMIT 100;
SELECT * FROM mb16 ORDER BY c1 LIMIT 100;
SELECT * FROM mb64 ORDER BY c1 LIMIT 100;
SELECT * FROM mplain ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- A selective filter that the storage layer evaluates.  Roughly one row in
-- a hundred qualifies, so ten thousand rows must be read to satisfy the
-- LIMIT, and each stream reads its own share of them.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb2 WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb4 WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb16 WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb64 WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mplain WHERE c4 = 50 ORDER BY c1 LIMIT 100;


-- ---------------------------------------------------------------------
-- No LIMIT anywhere.  Only the reference pair runs this shape, since the
-- result is the whole table and the point is the shape of the cost, not a
-- fifth data point.  The first-page gate is paid here too, so a model that
-- charges startup only when a LIMIT is present is charging in the wrong
-- place.
-- ---------------------------------------------------------------------
SELECT c1 FROM mb16 ORDER BY c1;
SELECT c1 FROM mplain ORDER BY c1;
