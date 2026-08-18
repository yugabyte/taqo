-- yb_enable_derived_equalities: single-table lookups.
--
-- When an index key is a generated column or an index expression, and the
-- query pins every column that expression reads, the planner can compute the
-- key's value and add it as an index condition.  That is what makes a
-- bucketized index usable for a lookup that never mentions the bucket: the
-- user asks for entity 123456 and the planner supplies bucket
-- yb_hash_code(123456) % 16 on their behalf.  Without it the lookup has to
-- visit every bucket, and the whole point of putting the bucket first in the
-- key is lost.
--
-- Two open defects show up in the plans this file produces.  The derived
-- expression is never const-folded, so the index condition reads
-- "c0 = (yb_hash_code(123456) % 16)" rather than "c0 = 2" and the executor
-- treats it as a runtime key (yugabyte/yugabyte-db#31354).  And no path
-- without the derivation is generated, so where the derivation is not worth
-- its binds the CBO is not offered the alternative (#31164), which is what
-- eq-04 is about.
--
-- Three tables, three forms of the derivation.  de16 generates its bucket
-- from one column, de2c from two, so an equality on one of them is not
-- enough, and dex has no generated column at all and derives on the index
-- expression itself.  Where a bucket cannot be derived a derived SAOP over
-- all the buckets usually can be, so most of the pairs below are one seek
-- against a merge over every bucket rather than against a full scan.
--
-- Data facts: de16 has 500000 rows with c2 unique, de2c has 300000 with c2
-- unique and c6 of ndv 10, dex has 300000 with c3 of ndv 1000, so about 300
-- rows per c3 value.


-- ---------------------------------------------------------------------
-- The flagship: a lookup by the column the bucket is generated from.  All
-- of the bucket has to be derived, or all of it visited.
-- ---------------------------------------------------------------------
SELECT c1, c3, c4 FROM de16 WHERE c2 = 123456;
SELECT c1, c3, c4 FROM de16 WHERE c2 = 1;
SELECT c1, c3, c4 FROM de16 WHERE c2 = 499999;
SELECT c1 FROM de16 WHERE c2 = 123456;
SELECT * FROM de16 WHERE c2 = 123456;
SELECT count(*) FROM de16 WHERE c2 = 123456;


-- ---------------------------------------------------------------------
-- Several values at once.  An IN list is not an equality, so no bucket can
-- be derived from it and the index has to be reached another way.  These
-- are the boundary of what the derivation covers.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM de16 WHERE c2 IN (1, 123456);
SELECT c1, c3 FROM de16 WHERE c2 IN (1, 2, 3, 4, 5, 6, 7, 8);
SELECT c1, c3 FROM de16 WHERE c2 BETWEEN 1 AND 8;
SELECT c1, c3 FROM de16 WHERE c2 BETWEEN 1 AND 5000;
SELECT count(*) FROM de16 WHERE c2 BETWEEN 1 AND 5000;


-- ---------------------------------------------------------------------
-- The equality plus a range on the next key column, so the derived bucket
-- and the user's conditions form a full key prefix.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM de16 WHERE c2 = 123456 AND c1 > 0;
SELECT c1, c3 FROM de16 WHERE c2 = 123456 AND c1 BETWEEN 1 AND 500000;
SELECT c1, c3 FROM de16 WHERE c2 = 123456 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM de16 WHERE c2 = 123456 AND c4 = 50;
SELECT c1, c3 FROM de16 WHERE c2 = 123456 AND sign(c1 - c2) = 1;


-- ---------------------------------------------------------------------
-- The equality reached through an equivalence class rather than written
-- against a constant.  The planner substitutes whatever the class knows, so
-- these should derive exactly as the direct forms do.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM de16 WHERE c2 = 123456 AND c2 = c2;
SELECT c1, c3 FROM de16 WHERE 123456 = c2;
SELECT c1, c3 FROM de16 WHERE c2 = 123455 + 1;


-- ---------------------------------------------------------------------
-- Two columns feeding one bucket.  An equality on c2 alone cannot compute
-- the key, but an equality on c2 and c6 together can, so the pair shows the
-- derivation's cost when it fires against when it cannot.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM de2c WHERE c2 = 12345;
SELECT c1, c3 FROM de2c WHERE c2 = 12345 AND c6 = 3;
SELECT c1, c3 FROM de2c WHERE c6 = 3 AND c2 = 12345;
SELECT c1, c3 FROM de2c WHERE c2 = 12345 AND c6 IN (1,2,3);
SELECT c1, c3 FROM de2c WHERE c2 = 12345 AND c6 BETWEEN 1 AND 3;
SELECT c1, c3 FROM de2c WHERE c6 = 3;
SELECT count(*) FROM de2c WHERE c2 = 12345;
SELECT count(*) FROM de2c WHERE c2 = 12345 AND c6 = 3;


-- ---------------------------------------------------------------------
-- The same on an index expression with no generated column behind it.
-- dex_c3c1 is (bucket of c3, c3, c1), so an equality on c3 both derives the
-- bucket and supplies the second key, leaving c1 ordered.  This is the
-- "one entity's events in time order" access pattern the index exists for,
-- and it is where the derivation is worth the most.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 LIMIT 100;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1;
SELECT c1, c3 FROM dex WHERE c3 = 500 ORDER BY c1 DESC LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 = 500;
SELECT count(*) FROM dex WHERE c3 = 500;
SELECT c1, c3 FROM dex WHERE c3 = 500 AND c1 > 150000 ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 IN (500, 501) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 IN (500, 501, 502, 503) ORDER BY c1 LIMIT 10;
SELECT c1, c3 FROM dex WHERE c3 BETWEEN 500 AND 503 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Lookups that return nothing.  The derived bucket is computed from a value
-- no row carries, so the seek lands in the right bucket and finds nothing,
-- which is the cheapest possible correct answer and worth checking is what
-- the model predicts.
-- ---------------------------------------------------------------------
SELECT c1, c3 FROM de16 WHERE c2 = 900001;
SELECT c1, c3 FROM de2c WHERE c2 = 900001 AND c6 = 3;
SELECT c1, c3 FROM dex WHERE c3 = 1001 ORDER BY c1 LIMIT 10;
SELECT count(*) FROM de16 WHERE c2 = 900001;
