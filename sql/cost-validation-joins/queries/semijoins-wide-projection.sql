-- wide projection
-- 100000 x 10000 on 1:1
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c2 = t2.c2);
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c2 = t2.c5);
-- 100000 x 10000 on 5:1
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c3 = t2.c2);
-- 100000 x 10000 on 1:5
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c2 = t2.c3);
-- 100000 x 10000 on 10:1
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c4 = t2.c2);
-- 100000 x 10000 on 1:10
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c2 = t2.c4);
-- 100000 x 10000 on 100:1
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c6 = t2.c2);
-- 100000 x 10000 on 1:100
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c2 = t2.c6);
-- 100000 x 10000 on 10:5
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c4 = t2.c3);
-- 100000 x 10000 on 5:10
select * from t100000w t1 where exists (select 0 from t10000 t2 where t1.c3 = t2.c4);
