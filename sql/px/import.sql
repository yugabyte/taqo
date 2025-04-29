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
