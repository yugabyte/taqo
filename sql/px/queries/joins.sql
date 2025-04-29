select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 = 2500;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 <= 2000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 <= 5000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.id;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 500;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 800;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 1000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 500000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.k1 = t2.k3 and t2.id <= 1000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.k1 = t2.k3 and t2.id <= 50000;

select
  t1.id - t2.id + t1.k1 - t2.k1 + t1.k2 - t2.k2 + t1.k3 - t2.k3 + length(t1.v) - length(t2.v)
from t5m t1, t5m t2 where t1.k3 = t2.k3 and t2.id <= 20000;


select 0 from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 = 2500;
select 0 from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 <= 2000;
select 0 from t5m t1, t5m t2 where t1.id = t2.id and t2.k3 <= 5000;
select 0 from t5m t1, t5m t2 where t1.id = t2.id;
select 0 from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 500;
select 0 from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 800;
select 0 from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 1000;
select 0 from t5m t1, t5m t2 where t1.id = t2.k3 and t2.id <= 500000;
select 0 from t5m t1, t5m t2 where t1.k1 = t2.k3 and t2.id <= 1000;
select 0 from t5m t1, t5m t2 where t1.k1 = t2.k3 and t2.id <= 70000;
select 0 from t5m t1, t5m t2 where t1.k1 = t2.k3 and t2.id <= 500000;
select 0 from t5m t1, t5m t2 where t1.k3 = t2.k3 and t2.id = 25000;
select 0 from t5m t1, t5m t2 where t1.k3 = t2.k3 and t2.id <= 100;
select 0 from t5m t1, t5m t2 where t1.k3 = t2.k3 and t2.id <= 10000;
