select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 = v.r1;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 * t1.r1 = v.r1 * v.r1;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 - v.r1 = 0;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 <= v.r2;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 = v.r1 and t1.r1 = v.r2 + 2;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 = v.r1 and t1.r1 <= v.r2;

select * from t1, (select * from t2 where r2 <= 4) as v where t1.r1 = v.r1 and t1.id <= v.id;
