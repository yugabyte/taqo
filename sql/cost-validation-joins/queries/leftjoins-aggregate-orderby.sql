-- 100000 x 1000 on 1:1
select t1.c2, count(t2.c2) from t100000 t1 left join t1000 t2 on t1.c2 = t2.c2 group by t1.c2 order by t1.c2;
-- 100000 x 1000 on 5:1
select t1.c3, count(t2.c2) from t100000 t1 left join t1000 t2 on t1.c3 = t2.c2 group by t1.c3 order by t1.c3;
-- 100000 x 1000 on 1:5
select t1.c2, count(t2.c3) from t100000 t1 left join t1000 t2 on t1.c2 = t2.c3 group by t1.c2 order by t1.c2;
-- 100000 x 1000 on 10:1
select t1.c4, count(t2.c2) from t100000 t1 left join t1000 t2 on t1.c4 = t2.c2 group by t1.c4 order by t1.c4;
-- 100000 x 1000 on 1:10
select t1.c2, count(t2.c4) from t100000 t1 left join t1000 t2 on t1.c2 = t2.c4 group by t1.c2 order by t1.c2;
-- 100000 x 1000 on 10:5
select t1.c4, count(t2.c3) from t100000 t1 left join t1000 t2 on t1.c4 = t2.c3 group by t1.c4 order by t1.c4;
-- 100000 x 1000 on 5:10
select t1.c3, count(t2.c4) from t100000 t1 left join t1000 t2 on t1.c3 = t2.c4 group by t1.c3 order by t1.c3;


-- 100000 x 10000 on 1:1
select t1.c2, count(t2.c2) from t100000 t1 left join t10000 t2 on t1.c2 = t2.c2 group by t1.c2 order by t1.c2;
-- 100000 x 10000 on 5:1
select t1.c3, count(t2.c2) from t100000 t1 left join t10000 t2 on t1.c3 = t2.c2 group by t1.c3 order by t1.c3;
-- 100000 x 10000 on 1:5
select t1.c2, count(t2.c3) from t100000 t1 left join t10000 t2 on t1.c2 = t2.c3 group by t1.c2 order by t1.c2;
-- 100000 x 10000 on 10:1
select t1.c4, count(t2.c2) from t100000 t1 left join t10000 t2 on t1.c4 = t2.c2 group by t1.c4 order by t1.c4;
-- 100000 x 10000 on 1:10
select t1.c2, count(t2.c4) from t100000 t1 left join t10000 t2 on t1.c2 = t2.c4 group by t1.c2 order by t1.c2;
-- 100000 x 10000 on 10:5
select t1.c4, count(t2.c3) from t100000 t1 left join t10000 t2 on t1.c4 = t2.c3 group by t1.c4 order by t1.c4;
-- 100000 x 10000 on 5:10
select t1.c3, count(t2.c4) from t100000 t1 left join t10000 t2 on t1.c3 = t2.c4 group by t1.c3 order by t1.c3;
