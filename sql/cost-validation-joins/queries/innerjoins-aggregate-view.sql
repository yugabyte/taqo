-- join to aggregate view
select t1.c2, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t1000 t2) v on t1.c2 = v.avg_c2;
select t1.c3, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t1000 t2) v on t1.c3 = v.avg_c2;
select t1.c2, v.avg_c3 from t100000 t1 left join (select avg(c3) avg_c3 from t1000 t2) v on t1.c2 = v.avg_c3;
select t1.c4, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t1000 t2) v on t1.c4 = v.avg_c2;
select t1.c2, v.avg_c4 from t100000 t1 left join (select avg(c4) avg_c4 from t1000 t2) v on t1.c2 = v.avg_c4;
select t1.c4, v.avg_c3 from t100000 t1 left join (select avg(c3) avg_c3 from t1000 t2) v on t1.c4 = v.avg_c3;
select t1.c3, v.avg_c4 from t100000 t1 left join (select avg(c4) avg_c4 from t1000 t2) v on t1.c3 = v.avg_c4;


select t1.c2, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t10000 t2) v on t1.c2 = v.avg_c2;
select t1.c3, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t10000 t2) v on t1.c3 = v.avg_c2;
select t1.c2, v.avg_c3 from t100000 t1 left join (select avg(c3) avg_c3 from t10000 t2) v on t1.c2 = v.avg_c3;
select t1.c4, v.avg_c2 from t100000 t1 left join (select avg(c2) avg_c2 from t10000 t2) v on t1.c4 = v.avg_c2;
select t1.c2, v.avg_c4 from t100000 t1 left join (select avg(c4) avg_c4 from t10000 t2) v on t1.c2 = v.avg_c4;
select t1.c4, v.avg_c3 from t100000 t1 left join (select avg(c3) avg_c3 from t10000 t2) v on t1.c4 = v.avg_c3;
select t1.c3, v.avg_c4 from t100000 t1 left join (select avg(c4) avg_c4 from t10000 t2) v on t1.c3 = v.avg_c4;
