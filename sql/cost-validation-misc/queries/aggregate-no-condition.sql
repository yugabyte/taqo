-- count(*)
select count(*) from t100;
select count(*) from t1000;
select count(*) from t10000;
select count(*) from t100000;
select count(*) from t100000w;
select count(*) from t1000000m;

-- avg
select avg(c2) from t100;
select avg(c2) from t1000;
select avg(c2) from t10000;
select avg(c2) from t100000;
select avg(c2) from t100000w;
select avg(c2) from t1000000m;
select avg(c3) from t100;
select avg(c3) from t1000;
select avg(c3) from t10000;
select avg(c3) from t100000;
select avg(c3) from t100000w;
select avg(c3) from t1000000m;
select avg(c4) from t100;
select avg(c4) from t1000;
select avg(c4) from t10000;
select avg(c4) from t100000;
select avg(c4) from t100000w;
select avg(c4) from t1000000m;


-- HashAggregate vs. ordered-result producer + GroupAggregate trade off

select c3, count(c2) from t100 group by c3 order by c3;
select c3, count(c2) from t1000 group by c3 order by c3;
select c3, count(c2) from t10000 group by c3 order by c3;
select c3, count(c2) from t100000 group by c3 order by c3;
select c3, count(c2) from t100000w group by c3 order by c3;

select c3, count(v) from t100 group by c3 order by c3;
select c3, count(v) from t1000 group by c3 order by c3;
select c3, count(v) from t10000 group by c3 order by c3;
select c3, count(v) from t100000 group by c3 order by c3;
select c3, count(v) from t100000w group by c3 order by c3;
