-- The alternative-index suite: a plain ordered index on the very column the
-- merge scan exists to order by.
--
-- This file is deliberately small and deliberately separate, because the
-- configuration it tests is one the feature is not for.  A bucketized index
-- exists because the plain range index on the same leading columns would
-- concentrate every insert on one shard.  A deployment that has taken that
-- trouble does not also keep the hot index, so a query that could merge over
-- buckets and could equally read a plain (c1 asc) index is not a realistic
-- arbitration, and an honest per-stream cost model handles it as a byproduct
-- of getting the streams right.  It is worth covering because it does occur,
-- in schemas that have not finished migrating and in benchmark models, and
-- because it is the one shape where the wrong answer is unambiguous: the
-- plain ordered index needs no streams, no merge and no sort.
--
-- The tables are copies with one index added, which is the only difference:
--
--   sa and riv     500000 identical rows, indexes on (c6, c1), (c4, c1) and
--                  (c3, c1), and riv additionally has riv_c1 on (c1 asc)
--   mb16 and rivb  500000 identical rows, bucketized primary key
--                  (c0, c1, c2), and rivb additionally has rivb_c1
--
-- So every query below runs twice, once where the rival exists and once
-- where it does not.  Where the plans differ, the difference is the rival
-- index being chosen or not, and nothing else.  In the previous model this
-- coexistence is everywhere, and it is behind regressions such as the
-- table_split anti-join that moved from a plain (c2 asc) index to a
-- 64-bucket index and lost its presorted key in the process.


-- ---------------------------------------------------------------------
-- Derived bucket SAOP against a plain ordered index for the same order.
-- rivb should never prefer the merge here: rivb_c1 delivers c1 order with
-- one seek and no streams.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM rivb ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM rivb ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM mb16 ORDER BY c1 LIMIT 1000;
SELECT c1, c2 FROM rivb ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM mb16 ORDER BY c1 OFFSET 499990 LIMIT 10;
SELECT c1, c2 FROM rivb ORDER BY c1 DESC LIMIT 100;
SELECT c1, c2 FROM mb16 ORDER BY c1 DESC LIMIT 100;


-- ---------------------------------------------------------------------
-- The same with a filter, where the plain index has to read and discard
-- while the merge could in principle push the filter down per stream.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM rivb WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb16 WHERE c4 = 50 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM rivb WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM rivb WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- User-written IN lists against a plain ordered index.  This is the shape
-- described as the one merge scan should not be judged on: WHERE c6 IN
-- (...) ORDER BY c1 works without any merge if (c1 asc) exists, and avoids
-- the sort node too, so the merge has to beat a plan with no weaknesses.
-- ---------------------------------------------------------------------
SELECT c1, c6 FROM riv WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM riv WHERE c6 IN (1,2,3,4) ORDER BY c1 LIMIT 10;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2,3,4) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM riv WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM riv WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM riv WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 1000;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64) ORDER BY c1 LIMIT 1000;


-- ---------------------------------------------------------------------
-- Selectivity, which is what should decide it.  Two c6 values are a fifth
-- of the table, so reading them through the plain (c1 asc) index means
-- discarding four rows in five, and the merge stops being obviously wrong.
-- Sixteen c3 values are 1.6 % and it clearly is.
-- ---------------------------------------------------------------------
SELECT c1, c6 FROM riv WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10000;
SELECT c1, c6 FROM sa WHERE c6 IN (1,2) ORDER BY c1 LIMIT 10000;
SELECT c1, c3 FROM riv WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 OFFSET 7990 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) ORDER BY c1 OFFSET 7990 LIMIT 10;
SELECT c1, c3 FROM riv WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM sa WHERE c3 = 500 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Ordering consumers other than ORDER BY, where a lost presorted key turns
-- an incremental sort into a full one.  That is the mechanism behind the
-- anti-join regression this suite exists to hold.
-- ---------------------------------------------------------------------
SELECT c1, c2, c5 FROM riv WHERE c6 IN (1,2) ORDER BY c1, c5 LIMIT 100;
SELECT c1, c2, c5 FROM sa WHERE c6 IN (1,2) ORDER BY c1, c5 LIMIT 100;
SELECT c1, count(*) FROM rivb GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT c1, count(*) FROM mb16 GROUP BY c1 ORDER BY c1 LIMIT 1000;
SELECT DISTINCT ON (c1) c1, c4 FROM rivb ORDER BY c1 LIMIT 100;
SELECT DISTINCT ON (c1) c1, c4 FROM mb16 ORDER BY c1 LIMIT 100;
SELECT r.c1, r.c2 FROM riv r WHERE NOT EXISTS (SELECT 1 FROM dj d WHERE d.c1 = r.c1 AND d.c2 = r.c2) AND r.c2 <= 150000 ORDER BY r.c1 LIMIT 50;
SELECT s.c1, s.c2 FROM sa s WHERE NOT EXISTS (SELECT 1 FROM dj d WHERE d.c1 = s.c1 AND d.c2 = s.c2) AND s.c2 <= 150000 ORDER BY s.c1 LIMIT 50;


-- ---------------------------------------------------------------------
-- No ordering at all, so the rival index has nothing to offer either and
-- both tables should reach the same plan.  This is the negative control
-- for the file.
-- ---------------------------------------------------------------------
SELECT count(*) FROM riv WHERE c6 IN (1,2);
SELECT count(*) FROM sa WHERE c6 IN (1,2);
SELECT count(*) FROM rivb WHERE c4 = 50;
SELECT count(*) FROM mb16 WHERE c4 = 50;
