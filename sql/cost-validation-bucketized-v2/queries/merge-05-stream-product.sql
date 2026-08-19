-- Merge scan: stream cardinality as a cartesian product.
--
-- ms16's primary key is (c0, c6, c1) with 16 buckets, so a query that orders
-- by c1 needs a stream for every combination of bucket and c6 value it
-- admits.  The planner derives the 16-element SAOP on c0 and multiplies it by
-- whatever the user wrote on c6, giving 16, 32, 48, 64 and 80 streams from IN
-- lists of one to five elements.  The product is what the cap in
-- yb_max_merge_scan_streams actually limits, and crossing it does not reduce
-- the stream count, it removes merge scan from that column entirely, so the
-- plan changes shape and the estimate jumps with it.
--
-- This also stresses the layout assumption behind the presplit rule.  ms16
-- has one tablet per bucket, but a product of 64 streams over 16 tablets puts
-- four streams in every tablet, which is the configuration
-- yugabyte/yugabyte-db#33247 describes.  Multi-column merges cannot be split
-- out of that defect by any layout, which is why the issue lists them
-- separately from user IN lists.
--
-- Data facts: 300000 rows, c6 has ndv 10 with 30000 rows per value, and the
-- buckets are even to within sampling noise.


-- ---------------------------------------------------------------------
-- The product sweep at a small LIMIT.  One c6 value gives 16 streams, five
-- give 80 and merge scan disappears.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c6 = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4,5) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Range twins.  BETWEEN 1 AND k admits the same rows as the IN list but is
-- not a scalar array operation, so there is no product and no merge.  The
-- pair at k = 4 is the cleanest comparison in this file: same rows, same
-- index, 64 streams against a sort.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 4 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 5 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 8 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The product sweep past the fetch page.  Each of the 64 streams is handed
-- 1024 rows, so about 65000 rows are read to return 1000, and the streams
-- share 16 tablets while doing it.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c6 = 1 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4,5) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 4 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- No predicate on c6 at all.  The derived bucket SAOP alone cannot deliver
-- c1 order, because c6 sits between the bucket and c1 in the key, so this
-- has to sort no matter what the stream cap is.  It is the control showing
-- that the merge in every query above depends on the user's IN list.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2, c6 FROM ms16 ORDER BY c6, c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- The user writing the bucket predicate themselves.  This is the shape that
-- makes the row estimate unstable: a full-domain IN on the bucket column
-- goes through clause selectivity, where the disjoint sum lands on the 1.0
-- boundary and the estimate flips between all rows and about 0.64 of them
-- across ANALYZE runs (yugabyte/yugabyte-db#33251).  A partial list is not
-- on the boundary and is the control for it.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c0 IN (0,1,2,3) AND c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c0 IN (0,1,2,3) AND c6 IN (1,2,3,4) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c0 = 0 AND c6 IN (1,2,3,4) ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM ms16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) AND c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT count(*) FROM ms16 WHERE c0 IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);


-- ---------------------------------------------------------------------
-- Fully drained products, where the merge saves the sort but nothing else.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2) ORDER BY c1 OFFSET 59990 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 IN (1,2,3,4) ORDER BY c1 OFFSET 119990 LIMIT 10;
SELECT c1, c2 FROM ms16 WHERE c6 BETWEEN 1 AND 4 ORDER BY c1 OFFSET 119990 LIMIT 10;
SELECT count(*) FROM ms16 WHERE c6 IN (1,2,3,4);
SELECT c6, count(*) FROM ms16 WHERE c6 IN (1,2,3,4) GROUP BY c6 ORDER BY c6;
