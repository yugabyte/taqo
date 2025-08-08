-------------------------------------------
-- uncorrelated IN AND correlated EXISTS --
-------------------------------------------

select * from t2 where r1 in (select r1 from t1 where id <= 5) and exists (select 0 from t1 where id = t2.r2);

--------------------------------------------------
-- nested uncorrelated IN and correlated EXISTS --
--------------------------------------------------

select * from t2 t2b where r1 in (select r1 from t1 where exists (select 0 from t2 where r1 = t1.r1));

select * from t2 t2b where r1 in (select r1 from t1 where exists (select 0 from t2 where id = t1.r1));

------------------------------------------------------
-- nested correlated IN and correlated (NOT) EXISTS --
------------------------------------------------------

select * from t2 t2b where r1 in (select r1 from t1 where id = t2b.r2 + 1 and exists (select 0 from t2 where id = t1.r1));

select * from t2 t2b where r1 in (select r1 from t1 where id <= t2b.r2 + 2 and not exists (select 0 from t2 where r2 = t1.r1 + 1));
