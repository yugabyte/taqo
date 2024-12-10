select id, k1, k2, k3, substring(v, 1, 20) from t1m;

select id, k1, k2, k3, substring(v, 1, 20) from t1m where k1 = 5000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k1 <= 100;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k1 <= 2500;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k1 <= 5000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k1 <= 7500;

select id, k1, k2, k3, substring(v, 1, 20) from t1m where k2 = 50000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k2 <= 1000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k2 <= 25000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k2 <= 50000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k2 <= 75000;

select id, k1, k2, k3, substring(v, 1, 20) from t1m where k3 = 62500;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k3 <= 2500;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k3 <= 62500;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k3 <= 125000;
select id, k1, k2, k3, substring(v, 1, 20) from t1m where k3 <= 187500;


select k1, k2, k3 from t1m;

select k1, k2, k3 from t1m where k1 = 5000;
select k1, k2, k3 from t1m where k1 <= 100;
select k1, k2, k3 from t1m where k1 <= 2500;
select k1, k2, k3 from t1m where k1 <= 5000;
select k1, k2, k3 from t1m where k1 <= 7500;

select k1, k2, k3 from t1m where k2 = 50000;
select k1, k2, k3 from t1m where k2 <= 1000;
select k1, k2, k3 from t1m where k2 <= 25000;
select k1, k2, k3 from t1m where k2 <= 50000;
select k1, k2, k3 from t1m where k2 <= 75000;

select k1, k2, k3 from t1m where k3 = 62500;
select k1, k2, k3 from t1m where k3 <= 2500;
select k1, k2, k3 from t1m where k3 <= 62500;
select k1, k2, k3 from t1m where k3 <= 125000;
select k1, k2, k3 from t1m where k3 <= 187500;
