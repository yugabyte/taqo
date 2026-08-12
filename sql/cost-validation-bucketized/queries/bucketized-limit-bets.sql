-- Ordered scans under LIMIT are priced assuming early termination.  When the
-- row estimate overshoots reality, the ordered merge scan plan keeps its
-- LIMIT discount but must drain the table, while a rival full-scan plan
-- does the same work without the per-stream detour.  Expression predicates
-- that match nothing while the planner estimates otherwise are the worst
-- case, since the bet never pays off.
--
-- Each bet query comes as a twin pair: an empty variant where the planner
-- estimates rows but nothing matches (the bet never pays off), and a
-- matching variant with the same shape where the bet is honest.  A finding
-- on the empty variant alone means the magnitude is the worst case of an
-- estimation bet, while a finding on both means the plan choice itself is
-- wrong.  Semicolons must not appear inside comments in this model's query
-- files, since queries are split on them before comments are stripped.
--
-- Data facts these rely on: v is exactly 1024 chars (t100000w: 8192) and is
-- left-padded with '-', so length(v) BETWEEN 10 AND 20 and v LIKE 'zz%'
-- match nothing while length(v) = 1024 and v LIKE '--%' match everything.
-- c4 takes each value in 1..100001 about 10 times, so c4 = 500 matches
-- about 10 rows and c4 <= 20000 about a fifth of the table.

-- Twin pair 1: length(v) on the 1024-char table.
SELECT c1, v FROM table_bucketized WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1, c2 LIMIT 10;
SELECT c1, v FROM table_bucketized WHERE length(v) = 1024 ORDER BY c1, c2 LIMIT 10;

-- Twin pair 2: same on the wide-row table, where per-stream fetches are the
-- most expensive.
SELECT c1, v FROM t100000w WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1, c2 LIMIT 10;
SELECT c1, v FROM t100000w WHERE length(v) = 8192 ORDER BY c1, c2 LIMIT 10;

-- Twin pair 3: LIKE prefix, where the planner derives a small nonzero
-- selectivity from the prefix range.
SELECT c1, c2 FROM table_bucketized WHERE v LIKE 'zz%' ORDER BY c1, c2 LIMIT 10;
SELECT c1, c2 FROM table_bucketized WHERE v LIKE '--%' ORDER BY c1, c2 LIMIT 10;

-- Twin pair 4: a point predicate with fewer matches than the LIMIT, so the
-- ordered scan can never terminate early even though rows do match.
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 = 500 AND c3 = 500 ORDER BY c1, c2 LIMIT 10;
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 = 500 ORDER BY c1, c2 LIMIT 20;

-- LIMIT boundary sweep on an honest fifth-of-the-table filter: the first
-- fetch round returns min(LIMIT, fetch page) rows per stream, so cost and
-- time should be flat within a page and step across it.
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 <= 20000 ORDER BY c1, c2 LIMIT 1;
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 <= 20000 ORDER BY c1, c2 LIMIT 1000;
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 <= 20000 ORDER BY c1, c2 LIMIT 1100;
SELECT c1, c2, c4 FROM table_bucketized WHERE c4 <= 20000 ORDER BY c1, c2;

-- Aggregates consume every input row, so no LIMIT reaches the scan and any
-- early-termination discount is unearned.
SELECT count(*) FROM table_bucketized WHERE c4 <= 20000;
SELECT max(c2) FROM table_bucketized;
SELECT c1, min(c2) FROM table_bucketized WHERE c4 <= 20000 GROUP BY c1 ORDER BY c1 LIMIT 100;
