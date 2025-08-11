-- simple seq scan cases
select * from t100 where c1 <= 1 or c2 <= 1;

select * from t1000 where c1 <= 1 or c2 <= 1;
select * from t1000 where c1 <= 10 or c2 <= 10;
select * from t1000 where c1 <= 100 or c2 <= 100;

select * from t10000 where c1 <= 100 or c2 <= 100;
select * from t10000 where c1 <= 500 or c2 <= 500;
select * from t10000 where c1 <= 600 or c2 <= 600;
select * from t10000 where c1 <= 700 or c2 <= 700;
select * from t10000 where c1 <= 800 or c2 <= 800;
select * from t10000 where c1 <= 900 or c2 <= 900;
select * from t10000 where c1 <= 1000 or c2 <= 1000;
select * from t10000 where c1 <= 1100 or c2 <= 1100;
select * from t10000 where c1 <= 1500 or c2 <= 1500;

select * from t100000 where c1 <= 1000 or c2 <= 1000;
select * from t100000 where c1 <= 5000 or c2 <= 5000;
select * from t100000 where c1 <= 6000 or c2 <= 6000;
select * from t100000 where c1 <= 7000 or c2 <= 7000;
select * from t100000 where c1 <= 8000 or c2 <= 8000;
select * from t100000 where c1 <= 9000 or c2 <= 9000;
select * from t100000 where c1 <= 10000 or c2 <= 10000;
select * from t100000 where c1 <= 11000 or c2 <= 11000;
select * from t100000 where c1 <= 15000 or c2 <= 15000;

-- more complex seq scan cases
select * from t100000 where (c6 <= 10 and c2 <= 1000) or c2 > 99000;
select * from t100000 where (c6 <= 50 and c2 <= 5000) or c2 > 95000;
select * from t100000 where (c6 <= 100 and c2 <= 10000) or c2 > 90000;
select * from t100000 where (c6 <= 150 and c2 <= 15000) or c2 > 85000;

select * from t100000 where (c6 <= 10 and c2 <= 1000) or (c6 > 990 and c2 > 99000);
select * from t100000 where (c6 <= 20 and c2 <= 2000) or (c6 > 980 and c2 > 98000);

select * from t1000000m where (c6 <= 1 and c5 <= 10) or (c6 > (10000 - 1) and c5 > (100000 - 10));
select * from t1000000m where (c6 <= 10 and c5 <= 100) or (c6 > (10000 - 10) and c5 > (100000 - 100));
select * from t1000000m where (c6 <= 100 and c5 <= 1000) or (c6 > (10000 - 100) and c5 > (100000 - 1000));

-- try some different sizes
select * from t1000000m where (c6 <= 1 and c5 <= 100) or (c6 > (10000 - 10) and c5 > (100000 - 100));
select * from t1000000m where (c6 <= 1 and c5 <= 1000) or (c6 > (10000 - 100) and c5 > (100000 - 1000));

select * from t1000000m where (c6 <= 10 and c5 <= 10) or (c6 > (10000 - 1) and c5 > (100000 - 10));
select * from t1000000m where (c6 <= 10 and c5 <= 1000) or (c6 > (10000 - 100) and c5 > (100000 - 1000));

select * from t1000000m where (c6 <= 100 and c5 <= 10) or (c6 > (10000 - 1) and c5 > (100000 - 10));
select * from t1000000m where (c6 <= 100 and c5 <= 100) or (c6 > (10000 - 10) and c5 > (100000 - 100));

-- LIMITS
select * from t10000 where c1 <= 100 or c2 <= 100 order by c1 limit 1024;
select * from t10000 where c1 <= 500 or c2 <= 500 order by c1 limit 1024;
select * from t10000 where c1 <= 1000 or c2 <= 1000 order by c1 limit 1024;
select * from t10000 where c1 <= 1500 or c2 <= 1500 order by c1 limit 1024;

select * from t100000 where c1 <= 1000 or c2 <= 1000 order by c1 limit 1024;
select * from t100000 where c1 <= 5000 or c2 <= 5000 order by c1 limit 1024;
select * from t100000 where c1 <= 10000 or c2 <= 10000 order by c1 limit 1024;
select * from t100000 where c1 <= 15000 or c2 <= 15000 order by c1 limit 1024;

select * from t100000 where c6 <= 10 and c2 <= 1000 order by c1 limit 1024;
select * from t100000 where c6 <= 50 and c2 <= 5000 order by c1 limit 1024;
select * from t100000 where c6 <= 100 and c2 <= 10000 order by c1 limit 1024;
select * from t100000 where c6 <= 150 and c2 <= 15000 order by c1 limit 1024;

select * from t100000 where (c6 <= 10 and c2 <= 1000) or c2 > 99000 order by c1 limit 1024;
select * from t100000 where (c6 <= 50 and c2 <= 5000) or c2 > 95000 order by c1 limit 1024;
select * from t100000 where (c6 <= 100 and c2 <= 10000) or c2 > 90000 order by c1 limit 1024;
select * from t100000 where (c6 <= 150 and c2 <= 15000) or c2 > 85000 order by c1 limit 1024;

select * from t100000 where (c6 <= 10 and c2 <= 1000) or (c6 > 990 and c2 > 99000) order by c1 limit 1024;
select * from t100000 where (c6 <= 20 and c2 <= 2000) or (c6 > 980 and c2 > 98000) order by c1 limit 1024;
select * from t100000 where (c6 <= 60 and c2 <= 6000) or (c6 > 940 and c2 > 94000) order by c1 limit 1024;
select * from t100000 where (c6 <= 100 and c2 <= 10000) or (c6 > 900 and c2 > 90000) order by c1 limit 1024;

select * from t100000 where (c6 <= 10 or c2 <= 1000) and (c6 > 990 or c2 > 99000) order by c1 limit 1024;
select * from t100000 where (c6 <= 20 or c2 <= 2000) and (c6 > 980 or c2 > 98000) order by c1 limit 1024;
select * from t100000 where (c6 <= 60 or c2 <= 6000) and (c6 > 940 or c2 > 94000) order by c1 limit 1024;
select * from t100000 where (c6 <= 100 or c2 <= 10000) and (c6 > 900 or c2 > 90000) order by c1 limit 1024;

-- AGGREGATES
select avg(c5) from t10000 where c1 <= 100 or c2 <= 100;
select avg(c5) from t10000 where c1 <= 500 or c2 <= 500;
select avg(c5) from t10000 where c1 <= 1000 or c2 <= 1000;
select avg(c5) from t10000 where c1 <= 1500 or c2 <= 1500;

select avg(c5) from t100000 where c1 <= 1000 or c2 <= 1000;
select avg(c5) from t100000 where c1 <= 5000 or c2 <= 5000;
select avg(c5) from t100000 where c1 <= 10000 or c2 <= 10000;
select avg(c5) from t100000 where c1 <= 15000 or c2 <= 15000;

select avg(c5) from t100000 where c6 <= 10 and c2 <= 1000;
select avg(c5) from t100000 where c6 <= 50 and c2 <= 5000;
select avg(c5) from t100000 where c6 <= 100 and c2 <= 10000;
select avg(c5) from t100000 where c6 <= 150 and c2 <= 15000;

select avg(c5) from t100000 where (c6 <= 10 and c2 <= 1000) or c2 > 99000;
select avg(c5) from t100000 where (c6 <= 50 and c2 <= 5000) or c2 > 95000;
select avg(c5) from t100000 where (c6 <= 100 and c2 <= 10000) or c2 > 90000;
select avg(c5) from t100000 where (c6 <= 150 and c2 <= 15000) or c2 > 85000;

select avg(c5) from t100000 where (c6 <= 10 and c2 <= 1000) or (c6 > 990 and c2 > 99000);
select avg(c5) from t100000 where (c6 <= 20 and c2 <= 2000) or (c6 > 980 and c2 > 98000);
select avg(c5) from t100000 where (c6 <= 60 and c2 <= 6000) or (c6 > 940 and c2 > 94000);
select avg(c5) from t100000 where (c6 <= 100 and c2 <= 10000) or (c6 > 900 and c2 > 90000);

select avg(c5) from t100000 where (c6 <= 10 or c2 <= 1000) and (c6 > 990 or c2 > 99000);
select avg(c5) from t100000 where (c6 <= 20 or c2 <= 2000) and (c6 > 980 or c2 > 98000);
select avg(c5) from t100000 where (c6 <= 60 or c2 <= 6000) and (c6 > 940 or c2 > 94000);
select avg(c5) from t100000 where (c6 <= 100 or c2 <= 10000) and (c6 > 900 or c2 > 90000);
