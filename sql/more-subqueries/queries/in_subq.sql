---------------------
-- uncorrelated IN --
---------------------

select * from t1 where r1 in (select r1 from t2 where r2 = 1);

select * from t1 where r1 in (select r1 from t2 where r2 = 2);

select * from t1 where r1 in (select r1 from t2 where r2 <= 1);

select * from t1 where r1 in (select r1 from t2 where r2 <= 10);


-------------------
-- correlated IN --
-------------------

select * from t1 where r1 in (select r1 from t2 where r2 = t1.id);

select * from t1 where r1 in (select r1 from t2 where r2 = t1.id and r1 is not null);

select * from t1 where r1 in (select r1 from t2 where r2 <= t1.id);

select * from t1 where r1 in (select r1 from t2 where r2 + t1.id <= 10);

-------------------------
-- uncorrelated NOT IN --
-------------------------

select * from t1 where r1 not in (select r1 from t2 where r2 = 1);

select * from t1 where r1 not in (select r1 from t2 where r2 = 2);

select * from t1 where r1 not in (select r1 from t2 where r2 <= 1);

select * from t1 where r1 not in (select r1 from t2 where r2 <= 10);


-----------------------
-- correlated NOT IN --
-----------------------

select * from t1 where r1 not in (select r1 from t2 where r2 = t1.id);

select * from t1 where r1 not in (select r1 from t2 where r2 = t1.id and r1 is not null);

select * from t1 where r1 not in (select r1 from t2 where r2 <= t1.id);

select * from t1 where r1 not in (select r1 from t2 where r2 + t1.id <= 10);
