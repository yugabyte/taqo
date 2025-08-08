------------------
-- uncorrelated --
------------------

select * from t1 where r1 <= ANY (select r1 from t2 where r2 <= 1);

select * from t1 where r1 >= ANY (select r1 from t2 where r2 <= 1);

select * from t1 where r1 <= ALL (select r1 from t2 where r2 <= 1 and id <> 0);

select * from t1 where r1 >= ALL (select r1 from t2 where r2 <= 1 and id <> 0);


----------------
-- correlated --
----------------

select * from t1 where r1 <= ANY (select r1 from t2 where r2 = t1.r1);

select * from t1 where r1 >= ANY (select r1 from t2 where r2 = t1.r1);

select * from t1 where r1 <= ALL (select r1 from t2 where r2 = t1.r1);

select * from t1 where r1 >= ALL (select r1 from t2 where r2 = t1.r1);
