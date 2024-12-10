select id, k1, k2, k3, substring(v, 1, 20) from t10m order by 1, 2, 3 limit 1;

select id, k1, k2, k3, substring(v, 1, 20) from t10m where k1 = 50000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k1 <= 1000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k1 <= 25000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k1 <= 50000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k1 <= 75000 order by 1, 2, 3 limit 1;

select id, k1, k2, k3, substring(v, 1, 20) from t10m where k2 = 500000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k2 <= 10000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k2 <= 250000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k2 <= 500000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k2 <= 750000 order by 1, 2, 3 limit 1;

select id, k1, k2, k3, substring(v, 1, 20) from t10m where k3 = 1250000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k3 <= 25000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k3 <= 625000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k3 <= 1250000 order by 1, 2, 3 limit 1;
select id, k1, k2, k3, substring(v, 1, 20) from t10m where k3 <= 1875000 order by 1, 2, 3 limit 1;


select k1, k2, k3 from t10m order by 1, 2, 3 limit 1;

select k1, k2, k3 from t10m where k1 = 50000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k1 <= 1000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k1 <= 25000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k1 <= 50000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k1 <= 75000 order by 1, 2, 3 limit 1;

select k1, k2, k3 from t10m where k2 = 500000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k2 <= 10000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k2 <= 250000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k2 <= 500000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k2 <= 750000 order by 1, 2, 3 limit 1;

select k1, k2, k3 from t10m where k3 = 1250000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k3 <= 25000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k3 <= 625000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k3 <= 1250000 order by 1, 2, 3 limit 1;
select k1, k2, k3 from t10m where k3 <= 1875000 order by 1, 2, 3 limit 1;
