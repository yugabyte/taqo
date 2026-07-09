set client_min_messages=warning;
-- To avoid temporary file limit error, store shuffled column values in separate
-- temp tables first then join them together.

CREATE TEMPORARY TABLE tmp1 (id int, v int, PRIMARY KEY (id));
CREATE TEMPORARY TABLE tmp2 (id int, v int, PRIMARY KEY (id));
CREATE TEMPORARY TABLE tmp3 (id int, v int, PRIMARY KEY (id));

SELECT setseed(0.777);

SET work_mem = '512MB';

-- k1, k2, k3: Each distinct value repeats 100 times each
INSERT INTO tmp1
  SELECT row_number() OVER (ORDER BY random()) AS id,
         i % (5000000 / 100) + 1 AS v FROM generate_series(1, 5000000) i;

INSERT INTO tmp2
  SELECT row_number() OVER (ORDER BY random()) AS id,
         i % (5000000 / 100) + 1 AS v FROM generate_series(1, 5000000) i;

INSERT INTO tmp3
  SELECT row_number() OVER (ORDER BY random()) AS id,
         i % (5000000 / 100) + 1 AS v FROM generate_series(1, 5000000) i;

ANALYZE tmp1, tmp2, tmp3;

/*+
  Leading(((tmp1 tmp2) tmp3))
  MergeJoin(tmp1 tmp2)
  MergeJoin(tmp1 tmp2 tmp3)
*/
INSERT INTO t5m
  SELECT row_number() OVER (), tmp1.v, tmp2.v, tmp3.v,
      lpad(sha512((tmp1.v#tmp2.v#tmp3.v)::bpchar::bytea)::bpchar, 1536, '-')
  FROM tmp1 JOIN tmp2 USING (id) JOIN tmp3 USING(id);


SELECT setseed(0.777);
-- insert into ord
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(0,249999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(250000,499999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(500000,749999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(750000,999999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(1000000,1249999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(1250000,1499999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(1500000,1749999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(1750000,1999999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(2000000,2249999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(2250000,2499999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(2500000,2749999) g;
INSERT INTO ord SELECT g, g/100, g%1000, timestamptz '2026-07-01' - (g%7776000) * interval '1 second', (array['new','paid','shipped','done','cancelled'])[1+g%5], ((g::bigint*7919)%10000000)::numeric/100, repeat(md5(g::text),6) FROM generate_series(2750000,2999999) g;


-- insert into events
INSERT INTO events SELECT g, g%97, timestamptz '2026-07-01' - (g%2592000) * interval '1 second',
       ((g::bigint*7919)%1000000)::numeric/100, md5(g::text)
FROM generate_series(0,399999) g;
INSERT INTO events SELECT g, g%97, timestamptz '2026-07-01' - (g%2592000) * interval '1 second',
       ((g::bigint*7919)%1000000)::numeric/100, md5(g::text)
FROM generate_series(400000,799999) g;


-- insert into events_h
INSERT INTO events_h SELECT g, g%97, timestamptz '2026-07-01' - (g%2592000) * interval '1 second',
       ((g::bigint*7919)%1000000)::numeric/100, md5(g::text)
FROM generate_series(0,399999) g;
INSERT INTO events_h SELECT g, g%97, timestamptz '2026-07-01' - (g%2592000) * interval '1 second',
       ((g::bigint*7919)%1000000)::numeric/100, md5(g::text)
FROM generate_series(400000,799999) g;