-- Merge scan: the LIMIT bet, swept across estimate error.
--
-- An ordered scan under a LIMIT is priced assuming it stops as soon as it has
-- enough rows, so its cost is the full scan cost scaled by limit / estimated
-- rows.  A merge scan wins that pricing easily, because it is the only plan
-- that produces order without materializing anything, and its rival has to
-- sort.  The bet is only as good as the estimate underneath it, and when the
-- estimate is wrong the merge plan does not degrade gracefully: it drains
-- every stream at a full fetch page each while the sort plan does the work it
-- was always going to do.
--
-- The largest regression the previous model finds is exactly this, at 1349x:
-- v LIKE 'zz%' ORDER BY c1, c2 LIMIT 10, where a 3-stream merge with the LIKE
-- as a storage filter was costed at 124 against 2851 for a selective index
-- scan plus a sort, and then scanned all 1000000 rows to return nothing.
--
-- It would be easy to read that as a bug about empty results, and it is not.
-- In that run the regression rate is flat across output sizes: 29 % of the
-- queries returning no rows regressed, 31 % of those returning one row, 30 %
-- returning 11 to 100, and 29 % returning 101 to 10000.  Only above 10000
-- rows does it fall away, to 6 %.  Returning nothing does not cause the wrong
-- plan, it removes the early exit that would have hidden it, so the same
-- error shows up as 1349x instead of 1.4x.  This file therefore sweeps the
-- estimate error rather than camping on the corner, and the empty cases are
-- the endpoint of that sweep.
--
-- The instrument is c7 and c8.  c8 equals c7 in every row but the first,
-- where it is c7 + 1, and there are no extended statistics, so the estimator
-- predicts about 50 rows for all three of these while the truth is very
-- different:
--
--   c7 = 2  AND c8 = 2    4999 rows    estimate about 100x too low
--   c7 = 2  AND c8 = 3       1 row     estimate about 50x too high
--   c7 = 50 AND c8 = 51      0 rows    estimate infinitely too high
--
-- Three tables answer the same queries.  sel has plain indexes on c3, c7 and
-- v, so a genuinely selective access path exists and the question is whether
-- the CBO picks it.  mb16 has only its bucketized primary key, so the merge
-- path is the only path and the question is how much the bad bet costs.
-- mplain has no streams at all and is the floor.


-- ---------------------------------------------------------------------
-- The ladder with a selective rival available.  All three estimate about
-- 50 rows, so any cost difference between them is the model reacting to
-- something other than the estimate, and any plan difference from the
-- honest c7 = 2 row below is the estimate error changing the choice.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM sel WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE c7 = 2 AND c8 = 3 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE c7 = 2 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The same ladder with no rival, where the merge path is the only ordered
-- path and the cost of the bad bet is paid in full.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mb16 WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c7 = 2 AND c8 = 3 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c7 = 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 WHERE c7 = 2 AND c8 = 3 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- And with no streams, which is what the two blocks above are paying extra
-- for.  The same three estimate errors cost a plain ordered scan very
-- little, because there is nothing to multiply by the stream count.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM mplain WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c7 = 2 AND c8 = 3 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c7 = 2 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Honest estimates, the control for the whole file.  c3 = 500 selects 500
-- rows and is estimated at 496, c4 = 50 selects 5000, and a range over c3
-- selects 25000.  If the merge path is mispriced here too, the estimate
-- error was never the cause.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM sel WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c3 = 500 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c4 = 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE c3 BETWEEN 1 AND 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE c3 BETWEEN 1 AND 50 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE c3 BETWEEN 1 AND 50 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- The reported shape: an opaque string predicate with a real index range
-- behind it.  v is 64 characters starting with '-' in every row, so
-- v LIKE 'zz%' matches nothing while the planner derives a prefix range,
-- and v LIKE '--%' matches everything.  sel_vc1 is the selective rival that
-- the merge plan has to beat, and mb16 is the same query with no rival.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM sel WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE v LIKE '--%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE v LIKE '--%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb64 WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE v LIKE '--%' ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mw16 WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;
SELECT c1, c2, v FROM mw16 WHERE v LIKE 'zz%' ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- Opaque with no index behind it at all, so the estimate is a bare default
-- and the merge plan's only rival is a sequential scan and a sort.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM sel WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM sel WHERE length(v) = 64 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mb16 WHERE length(v) = 64 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1 LIMIT 10;
SELECT c1, c2 FROM mplain WHERE length(v) = 64 ORDER BY c1 LIMIT 10;


-- ---------------------------------------------------------------------
-- How the LIMIT size changes the bet.  The discount is limit / estimated
-- rows, so a LIMIT above the estimate removes it entirely and the plans
-- should converge.  The estimate is about 50, so 10 bets, 100 does not.
-- ---------------------------------------------------------------------
SELECT c1, c2 FROM sel WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM sel WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM sel WHERE c7 = 50 AND c8 = 51 ORDER BY c1;
SELECT c1, c2 FROM mb16 WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 1;
SELECT c1, c2 FROM mb16 WHERE c7 = 50 AND c8 = 51 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb16 WHERE c7 = 50 AND c8 = 51 ORDER BY c1;
SELECT c1, c2 FROM mb16 WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 100;
SELECT c1, c2 FROM mb16 WHERE c7 = 2 AND c8 = 2 ORDER BY c1 LIMIT 5000;


-- ---------------------------------------------------------------------
-- No LIMIT, so there was never a bet.  Any difference here is the cost of
-- the streams and the sort, which is what the bet was being made against.
-- ---------------------------------------------------------------------
SELECT count(*) FROM sel WHERE c7 = 2 AND c8 = 2;
SELECT count(*) FROM sel WHERE c7 = 50 AND c8 = 51;
SELECT count(*) FROM mb16 WHERE c7 = 2 AND c8 = 2;
SELECT count(*) FROM mb16 WHERE c7 = 50 AND c8 = 51;
SELECT count(*) FROM mb16 WHERE v LIKE 'zz%';
SELECT count(*) FROM mplain WHERE v LIKE 'zz%';


-- ---------------------------------------------------------------------
-- The bet inside a join, where a scan that never terminates early keeps a
-- join driving above it.  This is the shape of the 280x regression in the
-- previous model, an aggregate over a join whose filter matches nothing.
-- ---------------------------------------------------------------------
SELECT s.c1, count(*) FROM sel s JOIN dj d ON d.c1 = s.c1 WHERE s.c7 = 50 AND s.c8 = 51 GROUP BY s.c1 ORDER BY s.c1 LIMIT 100;
SELECT s.c1, count(*) FROM sel s JOIN dj d ON d.c1 = s.c1 WHERE s.c7 = 2 AND s.c8 = 2 GROUP BY s.c1 ORDER BY s.c1 LIMIT 100;
SELECT m.c1, count(*) FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 50 AND m.c8 = 51 GROUP BY m.c1 ORDER BY m.c1 LIMIT 100;
SELECT m.c1, count(*) FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.c7 = 2 AND m.c8 = 2 GROUP BY m.c1 ORDER BY m.c1 LIMIT 100;
SELECT p.c1, count(*) FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE p.c7 = 50 AND p.c8 = 51 GROUP BY p.c1 ORDER BY p.c1 LIMIT 100;
SELECT p.c1, count(*) FROM mplain p JOIN dj d ON d.c1 = p.c1 WHERE p.c7 = 2 AND p.c8 = 2 GROUP BY p.c1 ORDER BY p.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.v LIKE 'zz%' ORDER BY m.c1 LIMIT 100;
SELECT m.c1, d.c4 FROM mb16 m JOIN dj d ON d.c1 = m.c1 WHERE m.v LIKE '--%' ORDER BY m.c1 LIMIT 100;
