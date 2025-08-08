-- Cheaper scan + explicit Sort vs. ordered-result-producing scan trade off

select c2/c2, c3 from t100 order by c3 limit 1;
select c2/c2, c3 from t1000 order by c3 limit 1;
select c2/c2, c3 from t10000 order by c3 limit 1;
select c2/c2, c3 from t100000 order by c3 limit 1;
select c2/c2, c3 from t100000w order by c3 limit 1;

select c3, case when c1+c2+c4+c5+c6+length(v) is not null then null end from t100 order by c3 limit 1;
select c3, case when c1+c2+c4+c5+c6+length(v) is not null then null end from t1000 order by c3 limit 1;
select c3, case when c1+c2+c4+c5+c6+length(v) is not null then null end from t10000 order by c3 limit 1;
select c3, case when c1+c2+c4+c5+c6+length(v) is not null then null end from t100000 order by c3 limit 1;
select c3, case when c1+c2+c4+c5+c6+length(v) is not null then null end from t100000w order by c3 limit 1;

select c0 from t1000000m order by c0 limit 1;
select c1 from t1000000m order by c1 limit 1;
select c2 from t1000000m order by c2 limit 1;
select c3 from t1000000m order by c3 limit 1;
select c4 from t1000000m order by c4 limit 1;
select c5 from t1000000m order by c5 limit 1;
select c2, c4 from t1000000m order by c4, c2 limit 1;
select c4, c5 from t1000000m order by c5, c4 limit 1;

select c0, case when c1+c2+c3+c4+c5+c6 is not null then null end from t1000000m order by c0 limit 1;
select c1, case when c0+c2+c3+c4+c5+c6 is not null then null end from t1000000m order by c1 limit 1;
select c2, case when c0+c1+c3+c4+c5+c6 is not null then null end from t1000000m order by c2 limit 1;
select c3, case when c0+c1+c2+c4+c5+c6 is not null then null end from t1000000m order by c3 limit 1;
select c4, case when c0+c1+c2+c3+c5+c6 is not null then null end from t1000000m order by c4 limit 1;
select c5, case when c0+c1+c2+c3+c4+c6 is not null then null end from t1000000m order by c5 limit 1;
select c4, c2, case when c0+c1+c3+c5+c6 is not null then null end from t1000000m order by c4, c2 limit 1;
select c4, c5, case when c0+c1+c2+c3+c6 is not null then null end from t1000000m order by c5, c4 limit 1;
