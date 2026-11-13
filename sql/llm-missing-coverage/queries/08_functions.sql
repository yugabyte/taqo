SELECT c_int, concat_ws('-', VARIADIC ARRAY [c_text, c_grp::text, 'x']) AS cw,
       concat(VARIADIC ARRAY ['a', 'b', c_text]) AS cc,
       num_nonnulls(VARIADIC ARRAY [c_nullable, c_grp]) AS nn
FROM lmc_main
WHERE c_int < 10
ORDER BY 1;

SELECT make_interval(days => 3, hours := 4) AS i1,
       make_timestamp(year => 2024, month => 2, mday => 29, hour => 1, min => 2, sec := 3.5) AS t1,
       jsonb_build_object(VARIADIC ARRAY ['a', '1', 'b', '2']) AS jb;

SELECT count(ALL c_nullable), sum(ALL c_grp)
FROM lmc_main;

SELECT c_int,
       CAST(c_grp::numeric AS int) AS cast_int,
       CAST(c_text AS varchar(20)) AS cast_vc,
       TREAT(c_int AS bigint) AS treated,
       COLLATION FOR (c_text) AS coll,
       COLLATION FOR (c_text COLLATE "C") AS coll_c
FROM lmc_small
WHERE c_int < 5
ORDER BY 1;

SELECT NORMALIZE(c_text) AS n1,
       NORMALIZE(c_text, NFC) AS n2,
       NORMALIZE(c_text, NFD) AS n3,
       NORMALIZE(c_text, NFKC) AS n4,
       NORMALIZE(c_text, NFKD) AS n5,
       c_text IS NORMALIZED AS isn,
       c_text IS NFC NORMALIZED AS isn_nfc,
       c_text IS NOT NORMALIZED AS notn,
       c_text IS NOT NFKD NORMALIZED AS notn_nfkd
FROM lmc_small
WHERE c_int < 4
ORDER BY c_int;

SELECT OVERLAY(c_text PLACING 'XX' FROM 2 FOR 3) AS o1,
       OVERLAY(c_text PLACING 'YY' FROM 3) AS o2,
       OVERLAY(c_text, 'ZZ', 1, 2) AS o3,
       POSITION('_' IN c_text) AS pos,
       POSITION(c_grp::text IN c_text) AS pos2
FROM lmc_small
WHERE c_int < 5
ORDER BY c_int;

SELECT SUBSTRING(c_text FROM 2 FOR 3) AS s1,
       SUBSTRING(c_text FOR 3 FROM 2) AS s2,
       SUBSTRING(c_text FROM 5) AS s3,
       SUBSTRING(c_text FOR 4) AS s4,
       SUBSTRING(c_text SIMILAR 'val#"_[0-9]#"%' ESCAPE '#') AS s5,
       SUBSTRING(c_text, 1, 2) AS s6
FROM lmc_small
WHERE c_int BETWEEN 10 AND 14
ORDER BY c_int;

SELECT TRIM(BOTH 'v' FROM c_text) AS t1,
       TRIM(LEADING 'va' FROM c_text) AS t2,
       TRIM(TRAILING '0' FROM c_text) AS t3,
       TRIM(' ' || c_text || ' ') AS t4,
       TRIM(FROM ' x ') AS t5,
       TRIM(BOTH FROM c_text, 'v0') AS t6
FROM lmc_small
WHERE c_int IN (10, 100, 200)
ORDER BY c_int;

SELECT GREATEST(c_int, c_grp, 50) AS g,
       LEAST(c_int, c_grp) AS l,
       COALESCE(c_nullable, -1) AS co,
       NULLIF(c_grp, 0) AS nu
FROM lmc_main
WHERE c_int < 12
ORDER BY c_int;

SELECT EXTRACT(YEAR FROM c_ts) AS y,
       EXTRACT(MONTH FROM c_ts) AS mo,
       EXTRACT(DAY FROM c_ts) AS d,
       EXTRACT(HOUR FROM c_ts) AS h,
       EXTRACT(MINUTE FROM c_ts) AS mi,
       EXTRACT(SECOND FROM c_ts) AS s,
       EXTRACT('dow' FROM c_ts) AS dow,
       EXTRACT(epoch FROM c_ts - timestamp '2024-01-01') AS ep
FROM lmc_main
WHERE c_int IN (1, 1000, 5000)
ORDER BY c_int;

SELECT c_int,
       CASE c_grp % 4 WHEN 0 THEN 'zero' WHEN 1 THEN 'one' ELSE 'many' END AS simple_case,
       CASE WHEN c_bool THEN c_int END AS no_else
FROM lmc_main
WHERE c_int < 9
ORDER BY 1;

SELECT c_int,
       c_ts AT TIME ZONE 'UTC' AS at_utc,
       (c_ts AT TIME ZONE 'UTC') AT TIME ZONE 'America/Los_Angeles' AS at_la
FROM lmc_main
WHERE c_int < 4
ORDER BY 1;

SELECT c_grp % 3 AS g,
       array_agg(c_int ORDER BY c_int DESC) FILTER (WHERE c_int < 20) AS arr,
       json_agg(c_text ORDER BY c_text) FILTER (WHERE c_int < 9) AS js,
       bool_and(c_bool) AS ba,
       every(c_int > 0) AS ev
FROM lmc_main
WHERE c_int < 30
GROUP BY c_grp % 3
ORDER BY 1;
