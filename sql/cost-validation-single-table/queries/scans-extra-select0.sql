-- Some specific result row count variations not covered in the scans-xxx.sql
-- 0, 1, 10 row results are covered in each scans-xxx.sql

-- 100 rows
-- from t100000
select 0 from t100000 where c1 between 100000 / 3 + 1 and 100000 / 3 + 100;
select 0 from t100000 where c2 between 100000 / 3 + 1 and 100000 / 3 + 100;
select 0 from t100000 where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 20;
select 0 from t100000 where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 10;
-- from t1000
select 0 from t1000 where c1 between 1000 / 3 + 1 and 1000 / 3 + 100;
select 0 from t1000 where c2 between 1000 / 3 + 1 and 1000 / 3 + 100;
select 0 from t1000 where c3 between (1000 / 5) / 3 + 1 and (1000 / 5) / 3 + 20;
select 0 from t1000 where c4 between (1000 / 10) / 3 + 1 and (1000 / 10) / 3 + 10;
-- from t100000w
select 0 from t100000w where c1 between 100000 / 3 + 1 and 100000 / 3 + 100;
select 0 from t100000w where c2 between 100000 / 3 + 1 and 100000 / 3 + 100;
select 0 from t100000w where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 20;
select 0 from t100000w where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 10;

-- 1000 rows
-- from t100000
select 0 from t100000 where c1 between 100000 / 3 + 1 and 100000 / 3 + 1000;
select 0 from t100000 where c2 between 100000 / 3 + 1 and 100000 / 3 + 1000;
select 0 from t100000 where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 200;
select 0 from t100000 where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 100;
-- from t100000w
select 0 from t100000w where c1 between 100000 / 3 + 1 and 100000 / 3 + 1000;
select 0 from t100000w where c2 between 100000 / 3 + 1 and 100000 / 3 + 1000;
select 0 from t100000w where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 200;
select 0 from t100000w where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 100;

-- 10000 rows
-- from t100000
select 0 from t100000 where c1 between 100000 / 3 + 1 and 100000 / 3 + 10000;
select 0 from t100000 where c2 between 100000 / 3 + 1 and 100000 / 3 + 10000;
select 0 from t100000 where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 2000;
select 0 from t100000 where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 1000;
-- from t100000w
select 0 from t100000w where c1 between 100000 / 3 + 1 and 100000 / 3 + 10000;
select 0 from t100000w where c2 between 100000 / 3 + 1 and 100000 / 3 + 10000;
select 0 from t100000w where c3 between (100000 / 5) / 3 + 1 and (100000 / 5) / 3 + 2000;
select 0 from t100000w where c4 between (100000 / 10) / 3 + 1 and (100000 / 10) / 3 + 1000;
