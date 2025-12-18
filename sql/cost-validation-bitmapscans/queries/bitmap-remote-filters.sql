select * from t100 where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);
select * from t100;
select * from t1000 where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);
select * from t10000 where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);
select * from t100000 where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);
select * from t100000w where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);
select * from t1000000m where c1 < 1000 or (c2 < 1000 and c2 % 2 = 0 and c3 < 1000 and c3 % 2 = 0);

select * from t100 where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));
select * from t1000 where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));
select * from t10000 where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));
select * from t100000 where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));
select * from t100000w where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));
select * from t1000000m where (c1 < 100 and c2 % 2 = 0) or ((c2 < 100 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 100 and c3 % 2 = 0));

select * from t100 where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));
select * from t1000 where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));
select * from t10000 where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));
select * from t100000 where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));
select * from t100000w where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));
select * from t1000000m where (c1 < 1000 and c2 % 2 = 0) or ((c2 < 1000 or (c4 < 100 and c4 % 2 = 0)) and (c3 < 1000 and c3 % 2 = 0));

select * from t100 where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
select * from t1000 where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
select * from t10000 where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
select * from t100000 where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
select * from t100000w where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
select * from t1000000m where (c1 < 100 and c1 % 2 = 0) or (c2 < 100 and c2 % 2 = 0) or (c4 < 100 and c4 % 2 = 0);
