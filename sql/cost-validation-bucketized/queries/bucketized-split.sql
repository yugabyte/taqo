SELECT s.c2,s.c3 FROM table_split s JOIN table_hm h ON h.c1=s.c1 WHERE s.c2<=800000 ORDER BY s.c2,s.c3 LIMIT 50;

with x AS MATERIALIZED (select c2,c3 FROM table_split WHERE c2<=400000 ORDER BY c2,c3) select x.c2,x.c3 FROM x JOIN table_hm h ON h.c2=x.c2;

SELECT s.c2,s.c3 FROM table_split s JOIN table_hm h ON h.c2=s.c2 WHERE s.c2<=200000 ORDER BY s.c2,s.c3;

SELECT s.c2,s.c3 FROM table_split s
WHERE NOT EXISTS (SELECT 1 FROM table_hm h WHERE h.c2=s.c2 AND h.c3=s.c3) AND s.c2<=150000
ORDER BY s.c2,s.c3 LIMIT 50;

SELECT DISTINCT s.c2,s.c3 FROM table_split s JOIN table_hm h ON h.c2=s.c2 WHERE s.c2<=500000;

with g as materialized (
    select c2, c3, count(*) as cnt
    from table_split
    where c2 <= 800000
    group by c2, c3
    order by c2, c3
)
select g.c2, t.c6, sum(g.cnt) as s, avg(h.c4) as a
from g
join t10000 t on t.c2 = g.c2
join table_hm h on h.c2 = g.c2
group by grouping sets ((g.c2, t.c6), (g.c2), ())
order by g.c2, t.c6;

SELECT s.c2, s.c3 FROM table_split s JOIN t10000 t ON t.c2 = s.c2 WHERE s.c2 <= 200000 ORDER BY s.c2, s.c3;

SELECT s.c2,s.c3 FROM table_split s WHERE NOT EXISTS (SELECT 1 FROM table_hm h WHERE h.c1=s.c1 AND h.c2=s.c2 AND h.c3=s.c3 AND h.c4=s.c4) AND s.c2<=800000 ORDER BY s.c2,s.c3 LIMIT 100;

SELECT c2,c4 FROM table_split WHERE c2<=30000 ORDER BY c4;
SELECT c1,c7,c2 FROM table_split WHERE c2<=800000 ORDER BY c1,c4;

with recursive r(n) as (
    select 1
    union all
    select n + 1
    from r
    where n < 20
)
select u.c2, u.c3
from (
    (
        select c2, c3
        from table_split
        where c2 <= 400000
        order by c2, c3
    )
    union all
    (
        select c2, c3
        from table_split
        where c2 between 400001 and 800000
        order by c2, c3
    )
) u
join t10000 t
    on t.c2 = u.c2
union
select r.n, r.n
from r
order by 1, 2;

SELECT s.c2,s.c3 FROM table_split s JOIN t10000 t ON t.c2=s.c2 WHERE s.c2<=400001 ORDER BY s.c2,s.c3;

(SELECT c2,c3 FROM table_split WHERE c2<=400000 ORDER BY c2,c3) UNION ALL (SELECT c2,c3 FROM table_split WHERE c2 BETWEEN 400001 AND 800000 ORDER BY c2,c3) ORDER BY c2,c3;

SELECT s.c2, s.c3, row_number() OVER (ORDER BY s.c2,s.c3), count(*) OVER (PARTITION BY t.c6) FROM table_split s JOIN t10000 t ON t.c2=s.c2 WHERE s.c2<=400000;

SELECT DISTINCT s.c3, t.c4 FROM table_split s JOIN t10000 t ON t.c2=s.c2 WHERE s.c2<=500000;

WITH RECURSIVE r(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM r WHERE n<20)
SELECT q.c2, q.c3
FROM (
    SELECT s.c2, s.c3 FROM table_split s JOIN t10000 t ON t.c2=s.c2 WHERE s.c2<=1000000
    UNION ALL
    SELECT c2, c3 FROM table_split WHERE c2 BETWEEN 100001 AND 900000
) q
JOIN generate_series(1,50) g(n) ON q.c3 = g.n
WHERE q.c2 IN (SELECT n FROM r)
ORDER BY q.c2, q.c3 LIMIT 500;


WITH x AS MATERIALIZED (SELECT c2,c3 FROM table_split WHERE c2<=800000 ORDER BY c2,c3) SELECT x.c2, x.c3 FROM x JOIN generate_series(1,40) g(n) ON x.c3=g.n;

with x as materialized (
    select c2, c3
    from table_split
    where c2 <= 800000
    order by c2, c3
    limit 100
)
select x.c2, x.c3
from x
where not exists (
    select 1
    from table_hm h
    where h.c2 = x.c2
      and h.c3 = x.c3
);

select s.c2, s.c3
from table_split s
where exists (
    select 1
    from table_hm h
    where h.c1 = s.c1
)
and s.c2 <= 700000
order by s.c2, s.c3
limit 50;

SELECT count(*)
FROM generate_series(1,50) o(k)
CROSS JOIN LATERAL (
    SELECT c2, c3 FROM table_split
    WHERE c2 <= 800000 AND c2 <> o.k
    ORDER BY c2, c3 LIMIT 3000
) m;

SELECT DISTINCT c2, c3 FROM table_split WHERE c2 < 302000;


SELECT *
FROM table_split s
WHERE EXISTS
(
    SELECT 1
    FROM t10000 t
    WHERE t.c2=s.c2
)
AND NOT EXISTS
(
    SELECT 1
    FROM table_hm h
    WHERE h.c2=s.c2
      AND h.c3=s.c3
)
ORDER BY c2,c3
LIMIT 500;

SELECT c1,c2,c3,c4 FROM table_split WHERE bucketid IN (0,1,2,3) AND c1<=400000 ORDER BY c1,c2;
SELECT c1,c2,v,ts FROM table_split WHERE bucketid IN (0,1,2,3) AND c1<=200000 ORDER BY c1,c2;

SELECT c1,c2,c3,c4,c5,c6 FROM table_hm
WHERE bucketid IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63)
  AND c1<=200000 ORDER BY c1,c2;

SELECT c4,c5 FROM table_hm WHERE c4<=60000 ORDER BY c4,c5;
SELECT c4,c5 FROM table_hm WHERE c4 BETWEEN 5000 AND 55000 ORDER BY c4 DESC, c5 DESC;


WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4 BETWEEN 2000 AND 60000 AND c4%4<>0 ORDER BY c4,c5)
SELECT c4, c5, row_number() OVER (ORDER BY c4,c5) rn, avg(c5) OVER (PARTITION BY c4) a
FROM m WHERE c5%3=0 ORDER BY c4,c5 LIMIT 3000;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=50000 ORDER BY c4,c5)
SELECT DISTINCT ON (c4) c4,c5 FROM m WHERE c5>100 AND c4%2=1 ORDER BY c4,c5 LIMIT 500;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=40000 ORDER BY c4,c5)
SELECT m.c4,m.c5,t.c6 FROM m JOIN t10000 t ON t.c2=m.c4 WHERE t.c2<60 AND m.c5%7=0 ORDER BY m.c4,m.c5 LIMIT 1000;

WITH RECURSIVE r(n) AS (SELECT 5000 UNION ALL SELECT n+5000 FROM r WHERE n<50000),
     m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=55000 ORDER BY c4,c5)
SELECT m.c4,m.c5 FROM m JOIN r ON m.c4=r.n WHERE m.c5%2=0 ORDER BY m.c4,m.c5;


WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=30000 ORDER BY c4,c5 LIMIT 500)
SELECT m.c4,m.c5,x.c6 FROM m CROSS JOIN LATERAL (SELECT c6 FROM t10000 t WHERE t.c2=m.c4 ORDER BY t.c1 LIMIT 1) x
ORDER BY m.c4,m.c5;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=40000 ORDER BY c4,c5)
SELECT m.c4,m.c5 FROM m
  JOIN generate_series(1000,40000,1000) g(n) ON m.c4=g.n
  JOIN (VALUES(10000),(20000),(30000)) v(x) ON m.c4>=v.x
WHERE m.c5%3=0 ORDER BY m.c4,m.c5 LIMIT 500;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=50000 ORDER BY c4,c5)
SELECT m.c4,m.c5 FROM m
WHERE EXISTS (SELECT 1 FROM t10000 t WHERE t.c2=m.c4)
  AND NOT EXISTS (SELECT 1 FROM table_split s WHERE s.c2=m.c5)
ORDER BY m.c4,m.c5 LIMIT 300;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=40000 ORDER BY c4,c5)
SELECT c4,c5 FROM m WHERE c5%2=0
UNION
SELECT c4,c5 FROM m WHERE c4%3=0
ORDER BY c4,c5 LIMIT 1000;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=40000 ORDER BY c4,c5)
SELECT c4, count(*), avg(c5) FROM m WHERE c5>50 GROUP BY GROUPING SETS ((c4),()) ORDER BY c4 LIMIT 200;

WITH m AS MATERIALIZED (SELECT c4,c5 FROM table_hm WHERE c4<=20000 ORDER BY c4,c5)
SELECT c4, c5, generate_series(1,c4%3+1) FROM m WHERE c5%4=0 ORDER BY c4,c5 LIMIT 500;