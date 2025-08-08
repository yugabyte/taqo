select distinct c0 from t1000000m t1;
select distinct c1 from t1000000m t1;
select distinct c1, c2 from t1000000m t1;
select distinct c1, c2, c3 from t1000000m t1;
select distinct c1, c2, c3, c4 from t1000000m t1;
select distinct c1, c2, c3, c4, c5 from t1000000m t1;
select distinct c1, c2, c3, c4, c5, c6 from t1000000m t1;
select distinct c2 from t1000000m t1;
select distinct c2, c1 from t1000000m t1;
select distinct c2, c1, c4, c3 from t1000000m t1;
select distinct c3 from t1000000m t1;
select distinct c3, c1 from t1000000m t1;
select distinct c3, c2, c1 from t1000000m t1;
select distinct c3, c4, c5 from t1000000m t1;
select distinct c4 from t1000000m t1;
select distinct c4, c5 from t1000000m t1;
select distinct c4, c5, c3 from t1000000m t1;
select distinct c5 from t1000000m t1;
select distinct c6 from t1000000m t1;

select distinct v from t1000000d10;
select distinct v from t1000000d20;
select distinct v from t1000000d30;
select distinct v from t1000000d40;
select distinct v from t1000000d50;
select distinct v from t1000000d60;
select distinct v from t1000000d70;
select distinct v from t1000000d80;
select distinct v from t1000000d90;
select distinct v from t1000000d100;

select distinct v from t1000000i;
select distinct v from t1000000bi;
select distinct v from t1000000flt;
select distinct v from t1000000dbl;

-- semantically equivalent queries

select c0 from t1000000m t1 group by c0;
select c1 from t1000000m t1 group by c1;
select c1, c2 from t1000000m t1 group by c1, c2;
select c1, c2, c3 from t1000000m t1 group by c1, c2, c3;
select c1, c2, c3, c4 from t1000000m t1 group by c1, c2, c3, c4;
select c1, c2, c3, c4, c5 from t1000000m t1 group by c1, c2, c3, c4, c5;
select c1, c2, c3, c4, c5, c6 from t1000000m t1 group by c1, c2, c3, c4, c5, c6;
select c2 from t1000000m t1 group by c2;
select c2, c1 from t1000000m t1 group by c2, c1;
select c2, c1, c4, c3 from t1000000m t1 group by c2, c1, c4, c3;
select c3 from t1000000m t1 group by c3;
select c3, c1 from t1000000m t1 group by c3, c1;
select c3, c2, c1 from t1000000m t1 group by c3, c2, c1;
select c3, c4, c5 from t1000000m t1 group by c3, c4, c5;
select c4 from t1000000m t1 group by c4;
select c4, c5 from t1000000m t1 group by c4, c5;
select c4, c5, c3 from t1000000m t1 group by c4, c5, c3;
select c5 from t1000000m t1 group by c5;
select c6 from t1000000m t1 group by c6;

select v from t1000000d10 group by v;
select v from t1000000d20 group by v;
select v from t1000000d30 group by v;
select v from t1000000d40 group by v;
select v from t1000000d50 group by v;
select v from t1000000d60 group by v;
select v from t1000000d70 group by v;
select v from t1000000d80 group by v;
select v from t1000000d90 group by v;
select v from t1000000d100 group by v;

select v from t1000000i group by v;
select v from t1000000bi group by v;
select v from t1000000flt group by v;
select v from t1000000dbl group by v;
