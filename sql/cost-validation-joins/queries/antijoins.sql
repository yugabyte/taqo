-- 100000 x 100 on 1:1
select c2 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c2 = t2.c2);
select c5 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c2 = t2.c5);
-- 100000 x 100 on 5:1
select c3 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c3 = t2.c2);
-- 100000 x 100 on 1:5
select c2 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c2 = t2.c3);
-- 100000 x 100 on 10:1
select c4 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c4 = t2.c2);
-- 100000 x 100 on 1:10
select c2 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c2 = t2.c4);
-- 100000 x 100 on 10:5
select c4 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c4 = t2.c3);
-- 100000 x 100 on 5:10
select c3 from t100000 t1 where not exists (select 0 from t100 t2 where t1.c3 = t2.c4);


-- 100000 x 1000 on 1:1
select c2 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c2 = t2.c2);
select c5 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c2 = t2.c5);
-- 100000 x 1000 on 5:1
select c3 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c3 = t2.c2);
-- 100000 x 1000 on 1:5
select c2 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c2 = t2.c3);
-- 100000 x 1000 on 10:1
select c4 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c4 = t2.c2);
-- 100000 x 1000 on 1:10
select c2 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c2 = t2.c4);
-- 100000 x 1000 on 10:5
select c4 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c4 = t2.c3);
-- 100000 x 1000 on 5:10
select c3 from t100000 t1 where not exists (select 0 from t1000 t2 where t1.c3 = t2.c4);


-- 100000 x 10000 on 1:1
select c2 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c2);
select c5 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5);
-- 100000 x 10000 on 5:1
select c3 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c3 = t2.c2);
-- 100000 x 10000 on 1:5
select c2 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c3);
-- 100000 x 10000 on 10:1
select c4 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c4 = t2.c2);
-- 100000 x 10000 on 1:10
select c2 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c4);
-- 100000 x 10000 on 100:1
select c6 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c6 = t2.c2);
-- 100000 x 10000 on 1:100
select c2 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c6);
-- 100000 x 10000 on 10:5
select c4 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c4 = t2.c3);
-- 100000 x 10000 on 5:10
select c3 from t100000 t1 where not exists (select 0 from t10000 t2 where t1.c3 = t2.c4);


-- 10000 x 10000 on 1:1
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c2);
select c5 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c5);
-- 10000 x 10000 on 5:1
select c3 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c3 = t2.c2);
-- 10000 x 10000 on 1:5
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c3);
-- 10000 x 10000 on 10:1
select c4 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c4 = t2.c2);
-- 10000 x 10000 on 1:10
select c2 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c2 = t2.c4);
-- 10000 x 10000 on 10:5
select c4 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c4 = t2.c3);
-- 10000 x 10000 on 5:10
select c3 from t10000 t1 where not exists (select 0 from t10000 t2 where t1.c3 = t2.c4);
