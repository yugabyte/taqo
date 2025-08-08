------------------
-- uncorrelated --
------------------

select r1, array(select r2 from t2 where r1 <= 4) from t1;

----------------
-- correlated --
----------------

select r1, array(select r2 from t2 where r1 = t1.r1) from t1;
