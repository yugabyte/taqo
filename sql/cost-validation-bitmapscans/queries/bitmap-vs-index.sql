select * from t1000 where c2 <= 10 and c6 <= 1;
select * from t1000 where c2 <= 100 and c6 <= 1;
select * from t1000 where c2 <= 500 and c6 <= 5;

select * from t10000 where c2 <= 10 and c6 <= 1;
select * from t10000 where c2 <= 100 and c6 <= 1;
select * from t10000 where c2 <= 1000 and c6 <= 10;
select * from t10000 where c2 <= 5000 and c6 <= 50;

select * from t100000 where c2 <= 10 and c6 <= 1;
select * from t100000 where c2 <= 100 and c6 <= 1;
select * from t100000 where c2 <= 1000 and c6 <= 10;
select * from t100000 where c2 <= 10000 and c6 <= 100;

select * from t1000000m where c6 < 1 and c5 < 5;
select * from t1000000m where c6 < 1 and c5 < 10;

select * from t1000000m where c6 < 10 and c5 < 50;
select * from t1000000m where c6 < 10 and c5 < 100;

select * from t1000000m where c6 < 100 and c5 < 500;
select * from t1000000m where c6 < 100 and c5 < 1000;

select * from t1000000m where c6 < 1000 and c5 < 5000;
select * from t1000000m where c6 < 1000 and c5 < 10000;

-- with or conditions that could be pushed down as an index condition
select * from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select * from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4);
select * from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4);
select * from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);

select * from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10);
select * from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select * from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10);
select * from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10);

-- LIMITS
select * from t1000 where c2 <= 10 and c6 <= 1 order by c2 limit 1024;
select * from t1000 where c2 <= 100 and c6 <= 1 order by c2 limit 1024;
select * from t1000 where c2 <= 500 and c6 <= 5 order by c2 limit 1024;

select * from t10000 where c2 <= 10 and c6 <= 1 order by c2 limit 1024;
select * from t10000 where c2 <= 100 and c6 <= 1 order by c2 limit 1024;
select * from t10000 where c2 <= 1000 and c6 <= 10 order by c2 limit 1024;
select * from t10000 where c2 <= 5000 and c6 <= 50 order by c2 limit 1024;

select * from t100000 where c2 <= 10 and c6 <= 1 order by c2 limit 1024;
select * from t100000 where c2 <= 100 and c6 <= 1 order by c2 limit 1024;
select * from t100000 where c2 <= 1000 and c6 <= 10 order by c2 limit 1024;
select * from t100000 where c2 <= 10000 and c6 <= 100 order by c2 limit 1024;
select * from t100000 where c2 <= 50000 and c6 <= 500 order by c2 limit 1024;

-- effectively disable index only scans by forcing the fetch of an additional column, c1.
-- since (c3, c4, c5) are not distinct, to ensure stability of results we use (c1 - c1),
-- which is always 0. However, PG will not be able to optimize this away (even in future releases)
-- because c1 could be null, which means (c1 - c1) could evaluate to null.
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;

select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;

select c3, c4, c5, c1 - c1 from t1000000m where c6 < 1 and c5 < 10 order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c6 < 10 and c5 < 100 order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c6 < 100 and c5 < 1000 order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c6 < 1000 and c5 < 10000 order by c5, c4, c3 limit 1024;

-- AGGREGATES
select avg(c4) from t1000 where c2 <= 10 and c6 <= 1;
select avg(c4) from t1000 where c2 <= 100 and c6 <= 1;
select avg(c4) from t1000 where c2 <= 500 and c6 <= 5;

select avg(c4) from t10000 where c2 <= 10 and c6 <= 1;
select avg(c4) from t10000 where c2 <= 100 and c6 <= 1;
select avg(c4) from t10000 where c2 <= 1000 and c6 <= 10;
select avg(c4) from t10000 where c2 <= 5000 and c6 <= 50;

select avg(c4) from t100000 where c2 <= 10 and c6 <= 1;
select avg(c4) from t100000 where c2 <= 100 and c6 <= 1;
select avg(c4) from t100000 where c2 <= 1000 and c6 <= 10;
select avg(c4) from t100000 where c2 <= 10000 and c6 <= 100;
select avg(c4) from t100000 where c2 <= 50000 and c6 <= 500;

select avg(c4) from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select avg(c4) from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4);
select avg(c4) from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4);
select avg(c4) from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);

select avg(c4) from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10);
select avg(c4) from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select avg(c4) from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10);
select avg(c4) from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10);

select avg(c4) from t1000000m where c6 < 1 and c5 < 10;
select avg(c4) from t1000000m where c6 < 10 and c5 < 100;
select avg(c4) from t1000000m where c6 < 100 and c5 < 1000;
select avg(c4) from t1000000m where c6 < 1000 and c5 < 10000;
