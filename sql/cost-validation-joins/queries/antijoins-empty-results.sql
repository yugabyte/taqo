-- no matching row
-- 100000 x 100 on 1:1
select c2 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c2 = t2.c2);
select c5 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c2 = t2.c5);
-- 100000 x 100 on 5:1
select c3 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c3 = t2.c2);
-- 100000 x 100 on 1:5
select c2 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c2 = t2.c3);
-- 100000 x 100 on 10:1
select c4 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c4 = t2.c2);
-- 100000 x 100 on 1:10
select c2 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c2 = t2.c4);
-- 100000 x 100 on 10:5
select c4 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c4 = t2.c3);
-- 100000 x 100 on 5:10
select c3 from t100000 t1 where t1.c2 >= 101 and not exists (select 0 from t100 t2 where t1.c3 = t2.c4);
