-- minimize influence from the data transfer overhead by selecting a literal
select 0 from t1000000m where c1 = 50;
select 0 from t1000000m where c1 <= 50;
select 0 from t1000000m where c2 = 50;
select 0 from t1000000m where c2 <= 50;
select 0 from t1000000m where c3 = 50;
select 0 from t1000000m where c3 <= 50;
select 0 from t1000000m where c4 = 50;
select 0 from t1000000m where c4 <= 50;
select 0 from t1000000m where c2 = 50 and c3 = 50;

select 0 from t1000000m where c1 = 50 and c2 = 50;
select 0 from t1000000m where c1 <= 50 and c2 = 50;
select 0 from t1000000m where c1 = 50 and c2 = 50 and c3 = 50;
select 0 from t1000000m where c1 <= 50 and c2 = 50 and c3 = 50;
select 0 from t1000000m where c1 = 50 and c2 <= 50 and c3 = 50;
select 0 from t1000000m where c1 = 50 and c3 = 50;

select 0 from t1000000m where c4 = 50 and c2 = 50;
select 0 from t1000000m where c4 <= 50 and c2 = 50;
select 0 from t1000000m where c4 = 50 and c2 = 50 and c3 = 50;
select 0 from t1000000m where c4 <= 50 and c2 = 50 and c3 = 50;
select 0 from t1000000m where c4 = 50 and c2 <= 50 and c3 = 50;
select 0 from t1000000m where c4 = 50 and c3 = 50;
