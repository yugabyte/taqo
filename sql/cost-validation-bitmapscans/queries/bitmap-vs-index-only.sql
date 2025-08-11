-- with or conditions that could be pushed down as an index condition
select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4);
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4);
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);

select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10);
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10);
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10);

-- LIMITS
select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;

select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;

select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;

select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;

-- AGGREGATES
select avg(c3) from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select avg(c3) from t1000000m where c5 <= 1000 and (c4 = 4 or c3 = 4);
select avg(c3) from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4);
select avg(c3) from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);

select avg(c3) from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10);
select avg(c3) from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select avg(c3) from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10);
select avg(c3) from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10);
