-----------------------
-- correlated EXISTS --
-----------------------

select * from t1 where exists (select * from t2 where r1 = t1.r1 and r2 <= t1.id);

select * from t1 where exists (select * from t2 where r1 = t1.r1 and id <= t1.id);

select * from t1 where exists (select * from t2 where r1 = t1.r1);

select * from t1 where exists (select * from t2 where r1 >= t1.r1);

select * from t1 where exists (select * from t2 where r1 + t1.r1 = 10);

select * from t1 where exists (select * from t2 where r1 + t1.r1 >= 10);

select * from t1 where exists (select * from (select avg(r2) avg_r2 from t2 where r1 = t1.r1 and id <= t1.id) v where avg_r2 >= 1);


---------------------------
-- correlated NOT EXISTS --
---------------------------

select * from t1 where not exists (select * from t2 where r1 = t1.r1 and r2 <= t1.id);

select * from t1 where not exists (select * from t2 where r1 = t1.r1 and id <= t1.id);

select * from t1 where not exists (select * from t2 where r1 = t1.r1);

select * from t1 where not exists (select * from t2 where r1 >= t1.r1);

select * from t1 where not exists (select * from t2 where r1 + t1.r1 = 10);

select * from t1 where not exists (select * from t2 where r1 + t1.r1 >= 10);

select * from t1 where not exists (select * from (select avg(r2) avg_r2 from t2 where r1 = t1.r1 and id <= t1.id) v where avg_r2 >= 1);
