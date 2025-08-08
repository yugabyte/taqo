select * from t1, lateral(select * from t2 where r2 = t1.r1) as v where t1.r1 = v.r2;

select * from t1, lateral(select * from t2 where r2 = t1.r1) as v where t1.id <= v.id;

select * from t1, lateral(select * from t2 where r2 = t1.r1) as v;

select * from t1, lateral(select * from t2 where r1 = t1.r1 + 2 and r2 = t1.r1) as v where t1.id <= v.id;

select * from t1 left join lateral(select * from t2 where r2 = t1.r1) as v on t1.r1 = v.r2 where t1.id <= 10;

select * from t1 left join lateral(select * from t2 where r2 = t1.r1) as v on t1.id <= v.id where t1.id <= 10;
