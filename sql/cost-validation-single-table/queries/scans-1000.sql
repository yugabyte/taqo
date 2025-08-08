-- No search condition
select c2, c4, v from t1000;

-- Search condition on PK
-- 1 dv (1 row)
select c2, c4, v from t1000 where c1 = 1000 / 3 + 1;
-- 10 rows
select c2, c4, v from t1000 where c1 between 1000 / 3 + 1 and 1000 / 3 + 10;
-- sel=0.0
select c2, c4, v from t1000 where c1 >= 1000 * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c1 >= 1000 * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c1 >= 1000 * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c1 >= 1000 * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c1 >= 1000 * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c1 >= 1000 * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1;


-- Search condition on secondary index key, possible index-only
-- 1 dv (1 row)
select c2, c4, v from t1000 where c2 = 1000 / 3 + 1;
-- 10 rows
select c2, c4, v from t1000 where c2 between 1000 / 3 + 1 and 1000 / 3 + 10;
-- sel=0.0
select c2, c4, v from t1000 where c2 >= 1000 * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c2 >= 1000 * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c2 >= 1000 * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c2 >= 1000 * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c2 >= 1000 * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c2 >= 1000 * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1;


-- Search condition on secondary index key (value freq=5 with nulls)
-- 1 dv (5 rows)
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1;
-- 10 rows
select c2, c4, v from t1000 where c3 between (1000 / 5) / 3 + 1 and (1000 / 5) / 3 + 2;
-- sel=0.0
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c3 >= (1000 / 5) * 0 / 1 + 1;


-- Search condition on secondary index key (value freq=5 with nulls)
-- 1 dv (10 rows)
select c2, c4, v from t1000 where c4 = (1000 / 10) / 3 + 1;
-- sel=0.0
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1;

-------------------
-- Remote filter --
-------------------
-- PK + remote index filter
-- 1 dv (10 rows)
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 = (1000 / 10) / 3 + 1;
-- sel=0.0
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c1 >= 1000 * 0 / 1 + 1 and c4 >= (1000 / 10) * 0 / 1 + 1;


-- Index-only + remote index filter
-- 1 dv (10 rows)
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) = 1000 / 3 + 1;
-- sel=0.0
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c2 >= 1000 * 0 / 1 + 1 and (c2*2 - c2) >= 1000 * 0 / 1 + 1;


-- Secondary index + remote index filter
-- 1 dv (10 rows)
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) = (1000 / 10) / 3 + 1;
-- sel=0.0
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c4 >= (1000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (1000 / 10) * 0 / 1 + 1;


-- Secondary index + remote table filter
-- 1 dv (10 rows)
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 = (1000 / 10) / 3 + 1;
-- sel=0.0
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 63 / 64 + 1;
-- sel=0.125
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 7 / 8 + 1;
-- sel=0.25
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 3 / 4 + 1;
-- sel=0.5
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 1 / 2 + 1;
-- sel=0.75
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 1 / 4 + 1;
-- sel=1.0
select c2, c4, v from t1000 where c3 = (1000 / 5) / 3 + 1 and c4 >= (1000 / 10) * 0 / 1 + 1;
