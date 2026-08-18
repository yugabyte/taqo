-- Merge scan on user-written IN lists, with no bucketization anywhere.
--
-- Merge scan is not a bucketized-index feature.  Any range index whose
-- leading column carries an IN list engages it, which is most of the existing
-- exposure, and sa has no bucket column and no generated column, so neither
-- derived-clause GUC can touch these plans.  What is left is the merge scan
-- cost model on its own.
--
-- The question each query asks is whether a merge over the IN elements beats
-- a sort over the same index scan, or a sort over a sequential scan.  Note
-- that on this table nothing else can supply c1 order: sa has no (c1 asc)
-- index, because that is the index a real deployment would find hot.  The
-- rival suite covers the case where one exists anyway.
--
-- Data facts.  c3 has ndv 1000 with 500 rows per value, c4 has ndv 100 with
-- 5000, and c6 has ndv 10 with 50000.  So an IN list of k elements selects
-- k/1000, k/100 or k/10 of the table respectively, and the three indexes give
-- the same stream count at three very different selectivities.
--
-- Layout note.  sa's secondary indexes are single tablet, the YB default for
-- a secondary range index.  That makes the 32 and 64 stream queries below the
-- model's exposure to yugabyte/yugabyte-db#33247, where streams sharing a
-- tablet split one response-size budget, so their timings carry that defect
-- as well as the cost model's error.  The stream counts and read-op counts
-- are still meaningful, and the equivalent bucketized queries in merge-01 run
-- one stream per tablet for contrast.


-- ---------------------------------------------------------------------
-- Stream count sweep at high selectivity, 500 rows per element.  The merge
-- has to be worth its startup against a sort of at most 32000 rows.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 10;

-- One element past the 64 stream cap.  Merge scan is not reduced to 64
-- streams, it is switched off for that column entirely, so the plan changes
-- shape rather than degrading, and the estimate jumps with it.
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65) ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Range twins of the sweep.  BETWEEN 1 AND k selects exactly the rows that
-- IN (1..k) selects, but a range is not a scalar array operation, so no
-- merge is possible and the planner must sort.  Each pair isolates the
-- merge from every other difference, including selectivity.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 4 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 16 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 64 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 65 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- A single element needs no merge at all: one seek, already ordered.  This
-- is the floor the sweep above starts from.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 = 1 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 = 1 ORDER BY c1 LIMIT 500;
SELECT c1, c3 FROM sa WHERE c3 = 1 ORDER BY c1;


-- ---------------------------------------------------------------------
-- The sweep again past the fetch page, where each stream is handed 1024
-- rows rather than the LIMIT.  At 64 streams that is 65536 rows read to
-- return 1000.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4) ORDER BY c1 LIMIT 1000;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 LIMIT 1000;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 1000;
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 64 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Same stream counts, a hundred times less selective, on c4.  Whether a
-- merge is right depends on how much of the table the IN list admits, so
-- these are the same plans over very different row counts.
-- ---------------------------------------------------------------------
SELECT c1, c4 FROM sa WHERE c4 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 10;
SELECT c1, c4 FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 1000;
SELECT c1, c4 FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 1000;
SELECT c1, c4 FROM sa WHERE c4 BETWEEN 1 AND 64 ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Very few streams over very many rows, on c6.  Two elements are a fifth of
-- the table, so the merge is cheap to start and expensive to drain, which
-- is the opposite balance from the c3 block.
-- ---------------------------------------------------------------------
SELECT c1, c6 FROM sa WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2,3,4) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10000;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2,3,4,5,6,7,8) ORDER BY c1 LIMIT 10000;
SELECT c1, c6 FROM sa WHERE c6 BETWEEN 1 AND 8 ORDER BY c1 LIMIT 10000;


-- ---------------------------------------------------------------------
-- No ORDER BY, so the merge has nothing to sell.  Any merge path chosen
-- here is paying for an order the query never asked for.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64);
SELECT count(*) FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
SELECT count(*) FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64);
SELECT count(*) FROM sa WHERE c4 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64);


-- ---------------------------------------------------------------------
-- Ordered and fully drained, so the merge saves a sort but earns no early
-- termination.  The OFFSET keeps the result small so the row count returned
-- does not confound the timing.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 OFFSET 7990 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 OFFSET 31990 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 BETWEEN 1 AND 64 ORDER BY c1 OFFSET 31990 LIMIT 10;


-- ---------------------------------------------------------------------
-- An extra ordering key the index cannot supply, so the choice is between
-- an incremental sort over a merge and a full sort over a plain scan.
-- ---------------------------------------------------------------------
SELECT c1, c3, c5 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1, c5 LIMIT 10;
SELECT c1, c3, c5 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1, c5 LIMIT 10;
SELECT c1, c3, c5 FROM sa WHERE c3 BETWEEN 1 AND 64 ORDER BY c1, c5 LIMIT 10;
