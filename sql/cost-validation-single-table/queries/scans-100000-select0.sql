-- No search condition
select 0 from t100000;

-- Search condition on PK
-- 1 dv (1 row)
select 0 from t100000 where c1 = 100000 / 3 + 1;
-- 10 rows
select 0 from t100000 where c1 between 100000 / 3 + 1 and 100000 / 3 + 10;
-- sel=0.0
select 0 from t100000 where c1 >= 100000 * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c1 >= 100000 * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c1 >= 100000 * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c1 >= 100000 * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c1 >= 100000 * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c1 >= 100000 * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1;


-- Search condition on secondary index key, possible index-only
-- 1 dv (1 row)
select 0 from t100000 where c2 = 100000 / 3 + 1;
-- 10 rows
select 0 from t100000 where c2 between 100000 / 3 + 1 and 100000 / 3 + 10;
-- sel=0.0
select 0 from t100000 where c2 >= 100000 * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c2 >= 100000 * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c2 >= 100000 * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c2 >= 100000 * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c2 >= 100000 * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c2 >= 100000 * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1;


-- Search condition on secondary index key (value freq=5 with nulls)
-- 1 dv (5 rows)
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1;
-- 10 rows
select 0 from t100000 where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 2;
-- sel=0.0
select 0 from t100000 where c3 >= (100000 / 5) * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c3 >= (100000 / 5) * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c3 >= (100000 / 5) * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c3 >= (100000 / 5) * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c3 >= (100000 / 5) * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c3 >= (100000 / 5) * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c3 >= (100000 / 5) * 0 / 1 + 1;


-- Search condition on secondary index key (value freq=5 with nulls)
-- 1 dv (10 rows)
select 0 from t100000 where c4 = (100000 / 10) / 3 + 1;
-- sel=0.0
select 0 from t100000 where c4 >= (100000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c4 >= (100000 / 10) * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c4 >= (100000 / 10) * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c4 >= (100000 / 10) * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c4 >= (100000 / 10) * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c4 >= (100000 / 10) * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1;

-------------------
-- Remote filter --
-------------------
-- PK + remote index filter
-- 1 dv (10 rows)
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 = (100000 / 10) / 3 + 1;
-- sel=0.0
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c1 >= 100000 * 0 / 1 + 1 and c4 >= (100000 / 10) * 0 / 1 + 1;


-- Index-only + remote index filter
-- 1 dv (10 rows)
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) = 100000 / 3 + 1;
-- sel=0.0
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c2 >= 100000 * 0 / 1 + 1 and (c2*2 - c2) >= 100000 * 0 / 1 + 1;


-- Secondary index + remote index filter
-- 1 dv (10 rows)
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) = (100000 / 10) / 3 + 1;
-- sel=0.0
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c4 >= (100000 / 10) * 0 / 1 + 1 and (c4*2 - c4) >= (100000 / 10) * 0 / 1 + 1;


-- Secondary index + remote table filter
-- 1 dv (10 rows)
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 = (100000 / 10) / 3 + 1;
-- sel=0.0
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 1 / 1 + 1;
-- sel=0.01563
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 63 / 64 + 1;
-- sel=0.125
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 7 / 8 + 1;
-- sel=0.25
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 3 / 4 + 1;
-- sel=0.5
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 1 / 2 + 1;
-- sel=0.75
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 1 / 4 + 1;
-- sel=1.0
select 0 from t100000 where c3 = (100000 / 5) / 3 + 1 and c4 >= (100000 / 10) * 0 / 1 + 1;
