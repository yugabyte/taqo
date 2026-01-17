select * from t1000 where c2 <= 10 and c6 <= 1;
select * from t10000 where c2 <= 100 and c6 <= 1;
select * from t10000 where c2 <= 1000 and c6 <= 10;
select * from t100000 where c2 <= 100 and c6 <= 1;
select * from t100000 where c2 <= 1000 and c6 <= 10;
select * from t1000000m where c6 < 1 and c5 < 5;
select * from t1000000m where c6 < 10 and c5 < 100;
select * from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select * from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);
select * from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10);
select * from t1000 where c2 <= 10 and c6 <= 1 order by c2 limit 1024;
select * from t10000 where c2 <= 10 and c6 <= 1 order by c2 limit 1024;
select * from t100000 where c2 <= 100 and c6 <= 1 order by c2 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 10000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c6 < 1 and c5 < 10 order by c5, c4, c3 limit 1024;
select c3, c4, c5, c1 - c1 from t1000000m where c6 < 1000 and c5 < 10000 order by c5, c4, c3 limit 1024;
select avg(c4) from t1000 where c2 <= 100 and c6 <= 1;
select avg(c4) from t1000 where c2 <= 500 and c6 <= 5;
select avg(c4) from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select avg(c4) from t100000 where c2 <= 10 and c6 <= 1;
select avg(c4) from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select avg(c4) from t1000000m where c6 < 1 and c5 < 10;
select * from t100 where c1 <= 1 or c2 <= 1;
select * from t10000 where c1 <= 100 or c2 <= 100 order by c1 limit 1024;
select * from t100000 where c1 <= 9000 or c2 <= 9000;
select * from t100000 where (c6 <= 10 and c2 <= 1000) or c2 > 99000 order by c1 limit 1024;
select * from t100000 where (c6 <= 10 and c2 <= 1000) or (c6 > 990 and c2 > 99000) order by c1 limit 1024;
select avg(c5) from t100000 where (c6 <= 10 and c2 <= 1000) or (c6 > 990 and c2 > 99000);
select avg(c5) from t100000 where (c6 <= 10 or c2 <= 1000) and (c6 > 990 or c2 > 99000);
select * from t100000 where (c6 <= 100 and c2 <= 10000) or c2 > 90000 order by c1 limit 1024;
select * from t100000 where (c6 <= 150 and c2 <= 15000) or c2 > 85000 order by c1 limit 1024;
select * from t1000000m where c0 <= 50000 or c5 <= 5000;
select * from t1000000m where c0 <= 60000 or c5 <= 6000;
select * from t1000000m where c0 <= 65000 or c5 <= 6500;
select * from t1000000m where c0 <= 70000 or c5 <= 7000;
select * from t1000000m where c0 <= 100000 or c5 <= 10000;
select * from t1000000m where c0 <= 105000 or c5 <= 10500;
select * from t1000000m where c0 <= 110000 or c5 <= 11000;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4);
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 = 4 or c3 = 4) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4) order by c5, c4, c3 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10) order by c3, c4, c5 limit 1024;
select c3, c4, c5 from t1000000m where c5 <= 100000 and (c4 <= 10 or c3 <= 10) order by c5, c4, c3 limit 1024;
select avg(c3) from t1000000m where c5 <= 100 and (c4 = 4 or c3 = 4);
select avg(c3) from t1000000m where c5 <= 1000 and (c4 <= 10 or c3 <= 10);
select avg(c3) from t1000000m where c5 <= 100 and (c4 <= 10 or c3 <= 10);


SELECT c1, c2, c3
FROM t10000
WHERE c1>c2 and c3<c4 and c2<c4 or c1>c4
ORDER BY c1, c2;


SELECT a.c1, a.c2, b.c3
FROM t1000000m a
JOIN t100000w b
  ON a.c1 = b.c1
WHERE a.c1=a.c2 and b.c2>b.c3
ORDER BY a.c1, a.c2;


SELECT c2, c3
FROM t1000
WHERE c2>c3 and c3<c4
ORDER BY c2, c3;

SELECT t1.c1, t1.c2, t2.c3
FROM t100 t1
JOIN t1000 t2
  ON t1.c2 = t2.c2
WHERE t1.c2=t2.c4
ORDER BY t1.c1, t1.c2;



SELECT m.c1, m.c2, w.v
FROM t1000000m m
JOIN t100000w w
  ON w.c1 = m.c1
WHERE m.c1>m.c2
ORDER BY m.c1 DESC, m.c2 DESC;

SELECT c1,c2
FROM t1000 t
WHERE EXISTS (
    SELECT 1 FROM t100 t2
    WHERE t.c2 = t2.c2
)
ORDER BY c1,c2;