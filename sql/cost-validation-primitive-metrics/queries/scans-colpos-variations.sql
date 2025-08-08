select c0 from t1000000c10;
select c1 from t1000000c10;
select c2 from t1000000c10;
select c3 from t1000000c10;
select c4 from t1000000c10;
select c5 from t1000000c10;
select c6 from t1000000c10;
select c7 from t1000000c10;
select c8 from t1000000c10;
select c9 from t1000000c10;

-- ORDER BY required to get IndexScan
select c0 from t1000000c10 order by c0;
select c1 from t1000000c10 order by c1;
select c5 from t1000000c10 order by c5;


select c0 from t1000000c10 where c0 = 1000000 / 2;
select c1 from t1000000c10 where c1 = 1000000 / 2;
select c2 from t1000000c10 where c2 = 1000000 / 2;
select c3 from t1000000c10 where c3 = 1000000 / 2;
select c4 from t1000000c10 where c4 = 1000000 / 2;
select c5 from t1000000c10 where c5 = 1000000 / 2;
select c6 from t1000000c10 where c6 = 1000000 / 2;
select c7 from t1000000c10 where c7 = 1000000 / 2;
select c8 from t1000000c10 where c8 = 1000000 / 2;
select c9 from t1000000c10 where c9 = 1000000 / 2;
