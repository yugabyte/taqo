-----------------------------------
-- uncorrelated, in WHERE clause --
-----------------------------------

select * from t1 where id = (select r2 from t2 where id < 1);

select * from t1 where id = (select id from t2 where r1 = 2 and r2 = 4) and id <= 100;

select * from t1 where r1 >= (select avg(r1) from t2 where r2 <= 1);

----------------------------------
-- uncorrelated, in SELECT list --
----------------------------------

select t1.*, (select r2 from t2 where id < 1) sq from t1;

select r1, (select id from t2 where r1 = 10 and r2 = 4) from t1;


----------------
-- correlated --
----------------

select * from t1 where id = (select id from t2 where r1 = t1.r1 and r2 = 1);

select * from t1 where id = (select id from t2 where r1 = t1.r1 and r2 = 1 order by 1 limit 1);

select * from t1 where id = (select max(id) from t2 where r1 = t1.r1);

select t1.*, (select r2 from t2 where id = t1.r1) from t1 where t1.id <= 10;
