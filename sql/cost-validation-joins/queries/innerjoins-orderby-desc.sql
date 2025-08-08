-- 100000 x 1000 on 1:1
select t100000.c2, t1000.c2 from t100000 join t1000 on t100000.c2 = t1000.c2 order by t100000.c2 desc;
-- 100000 x 1000 on 5:1
select t100000.c3, t1000.c2 from t100000 join t1000 on t100000.c3 = t1000.c2 order by t100000.c3 desc;
-- 100000 x 1000 on 1:5
select t100000.c2, t1000.c3 from t100000 join t1000 on t100000.c2 = t1000.c3 order by t100000.c2 desc;
-- 100000 x 1000 on 10:1
select t100000.c4, t1000.c2 from t100000 join t1000 on t100000.c4 = t1000.c2 order by t100000.c4 desc;
-- 100000 x 1000 on 1:10
select t100000.c2, t1000.c4 from t100000 join t1000 on t100000.c2 = t1000.c4 order by t100000.c2 desc;
-- 100000 x 1000 on 100:1
select t100000.c6, t1000.c2 from t100000 join t1000 on t100000.c6 = t1000.c2 order by t100000.c6 desc;
-- 100000 x 1000 on 1:100
select t100000.c2, t1000.c6 from t100000 join t1000 on t100000.c2 = t1000.c6 order by t100000.c2 desc;
-- 100000 x 1000 on 10:5
select t100000.c4, t1000.c3 from t100000 join t1000 on t100000.c4 = t1000.c3 order by t100000.c4 desc;
-- 100000 x 1000 on 5:10
select t100000.c3, t1000.c4 from t100000 join t1000 on t100000.c3 = t1000.c4 order by t100000.c3 desc;


-- 100000 x 10000 on 1:1
select t100000.c2, t10000.c2 from t100000 join t10000 on t100000.c2 = t10000.c2 order by t100000.c2 desc;
-- 100000 x 10000 on 5:1
select t100000.c3, t10000.c2 from t100000 join t10000 on t100000.c3 = t10000.c2 order by t100000.c3 desc;
-- 100000 x 10000 on 1:5
select t100000.c2, t10000.c3 from t100000 join t10000 on t100000.c2 = t10000.c3 order by t100000.c2 desc;
-- 100000 x 10000 on 10:1
select t100000.c4, t10000.c2 from t100000 join t10000 on t100000.c4 = t10000.c2 order by t100000.c4 desc;
-- 100000 x 10000 on 1:10
select t100000.c2, t10000.c4 from t100000 join t10000 on t100000.c2 = t10000.c4 order by t100000.c2 desc;
-- 100000 x 10000 on 100:1
select t100000.c6, t10000.c2 from t100000 join t10000 on t100000.c6 = t10000.c2 order by t100000.c6 desc;
-- 100000 x 10000 on 1:100
select t100000.c2, t10000.c6 from t100000 join t10000 on t100000.c2 = t10000.c6 order by t100000.c2 desc;
-- 100000 x 10000 on 10:5
select t100000.c4, t10000.c3 from t100000 join t10000 on t100000.c4 = t10000.c3 order by t100000.c4 desc;
-- 100000 x 10000 on 5:10
select t100000.c3, t10000.c4 from t100000 join t10000 on t100000.c3 = t10000.c4 order by t100000.c3 desc;

-- 1000000 x 1000 on 1:1
select t1.c0, t2.c2 from t1000000m t1 join t1000 t2 on t1.c0 = t2.c2 order by t1.c0 desc;
-- 1000000 x 1000 on 10:1
select t1.c5, t2.c2 from t1000000m t1 join t1000 t2 on t1.c5 = t2.c2 order by t1.c5 desc;
-- 1000000 x 1000 on 1:10
select t1.c0, t2.c4 from t1000000m t1 join t1000 t2 on t1.c0 = t2.c4 order by t1.c0 desc;
-- 1000000 x 1000 on 100:1
select t1.c6, t2.c2 from t1000000m t1 join t1000 t2 on t1.c6 = t2.c2 order by t1.c6 desc;
-- 1000000 x 1000 on 1:100
select t1.c0, t2.c6 from t1000000m t1 join t1000 t2 on t1.c0 = t2.c6 order by t1.c0 desc;
