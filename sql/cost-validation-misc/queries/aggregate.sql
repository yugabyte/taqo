select min(c3), max(c3) from t1000000c10 t group by c4 having c4 = 5;
select min(c4), max(c4) from t1000000c10 t group by c3 having c3 = 5;
