-- 100000 x 100 on 1:1
select t100000.c2, t100.c2 from t100000 left join t100 on t100000.c2 = t100.c2;
-- 100000 x 100 on 5:1
select t100000.c3, t100.c2 from t100000 left join t100 on t100000.c3 = t100.c2;
-- 100000 x 100 on 1:5
select t100000.c2, t100.c3 from t100000 left join t100 on t100000.c2 = t100.c3;
-- 100000 x 100 on 10:1
select t100000.c4, t100.c2 from t100000 left join t100 on t100000.c4 = t100.c2;
-- 100000 x 100 on 1:10
select t100000.c2, t100.c4 from t100000 left join t100 on t100000.c2 = t100.c4;
-- 100000 x 100 on 10:5
select t100000.c4, t100.c3 from t100000 left join t100 on t100000.c4 = t100.c3;
-- 100000 x 100 on 5:10
select t100000.c3, t100.c4 from t100000 left join t100 on t100000.c3 = t100.c4;


-- 100000 x 1000 on 1:1
select t100000.c2, t1000.c2 from t100000 left join t1000 on t100000.c2 = t1000.c2;
-- 100000 x 1000 on 5:1
select t100000.c3, t1000.c2 from t100000 left join t1000 on t100000.c3 = t1000.c2;
-- 100000 x 1000 on 1:5
select t100000.c2, t1000.c3 from t100000 left join t1000 on t100000.c2 = t1000.c3;
-- 100000 x 1000 on 10:1
select t100000.c4, t1000.c2 from t100000 left join t1000 on t100000.c4 = t1000.c2;
-- 100000 x 1000 on 1:10
select t100000.c2, t1000.c4 from t100000 left join t1000 on t100000.c2 = t1000.c4;
-- 100000 x 1000 on 10:5
select t100000.c4, t1000.c3 from t100000 left join t1000 on t100000.c4 = t1000.c3;
-- 100000 x 1000 on 5:10
select t100000.c3, t1000.c4 from t100000 left join t1000 on t100000.c3 = t1000.c4;


-- 100000 x 10000 on 1:1
select t100000.c2, t10000.c2 from t100000 left join t10000 on t100000.c2 = t10000.c2;
-- 100000 x 10000 on 5:1
select t100000.c3, t10000.c2 from t100000 left join t10000 on t100000.c3 = t10000.c2;
-- 100000 x 10000 on 1:5
select t100000.c2, t10000.c3 from t100000 left join t10000 on t100000.c2 = t10000.c3;
-- 100000 x 10000 on 10:1
select t100000.c4, t10000.c2 from t100000 left join t10000 on t100000.c4 = t10000.c2;
-- 100000 x 10000 on 1:10
select t100000.c2, t10000.c4 from t100000 left join t10000 on t100000.c2 = t10000.c4;
-- 100000 x 10000 on 100:1
select t100000.c6, t10000.c2 from t100000 left join t10000 on t100000.c6 = t10000.c2;
-- 100000 x 10000 on 1:100
select t100000.c2, t10000.c6 from t100000 left join t10000 on t100000.c2 = t10000.c6;
-- 100000 x 10000 on 10:5
select t100000.c4, t10000.c3 from t100000 left join t10000 on t100000.c4 = t10000.c3;
-- 100000 x 10000 on 5:10
select t100000.c3, t10000.c4 from t100000 left join t10000 on t100000.c3 = t10000.c4;
