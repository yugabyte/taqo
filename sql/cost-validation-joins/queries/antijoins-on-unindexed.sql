-- on unindexed column, varying subquery result set size
-- 1 dv (1 row)
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 = 10000 / 3 + 1);
-- 10 rows
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 between 10000 / 3 + 1 and 10000 / 3 + 10);
-- sel=0.0
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 1 / 1 + 1);
-- sel=0.01563
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 63 / 64 + 1);
-- sel=0.125
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 7 / 8 + 1);
-- sel=0.25
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 3 / 4 + 1);
-- sel=0.5
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 1 / 2 + 1);
-- sel=0.75
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 1 / 4 + 1);
-- sel=1.0
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5 and t2.c2 >= 10000 * 0 / 1 + 1);
