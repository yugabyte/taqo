SELECT m.c1, m.c2, m.c3, t.c4
FROM t1000000m m
JOIN t100000 t
  ON t.c1 = m.c1
 AND t.c3 = m.c3
  AND m.c4 IS NOT NULL
  AND t.c4 > 0
ORDER BY m.c1 DESC, m.c3 DESC;


SELECT big.c1, big.c2, small.c3
FROM t100000 big
JOIN t1000 small
  ON small.c1 = big.c1
 AND small.c2 = big.c2
ORDER BY big.c1 DESC, big.c2 DESC;


SELECT c1, c2, c5
FROM t100000w
WHERE c1 BETWEEN 100 AND 50000
ORDER BY c1 DESC, c2 DESC;


SELECT m.c1, m.c2, m.c3
FROM t1000000m m
WHERE EXISTS (
    SELECT 1
    FROM t100000 t
    WHERE t.c1 = m.c1
      AND t.c2 = m.c2
)
ORDER BY m.c1 DESC, m.c2 DESC;


SELECT DISTINCT ON (c1,c2) c1, c2, c3
FROM t100000w
ORDER BY c1 DESC, c2 DESC, c3 DESC;


WITH x AS (
    SELECT c1, c2, c3,
           row_number() OVER (ORDER BY c1 DESC, c2 DESC) AS rn
    FROM t100000
)
SELECT c1, c2, c3
FROM x
WHERE rn <= 100
ORDER BY c1 DESC, c2 DESC;


SELECT a.c1, a.c2, b.c3
FROM t1000000m a
JOIN t1000000m b
  ON a.c1 = b.c1
 AND a.c2 = b.c2
WHERE a.c1>a.c2
ORDER BY a.c1 DESC, a.c2 DESC;


SELECT c1, c2, c3
FROM (
   SELECT c1, c2, c3
   FROM t100000

   UNION ALL

   SELECT c1, c2, c3
   FROM t1000000m
) q
ORDER BY c1 DESC, c2 DESC;



SELECT c1, c2, c3
FROM t1000000m
WHERE c1>c2
ORDER BY c1 DESC, c2 DESC
LIMIT 500;


select m.c1, m.c2,
       case when m.c3 > 100 then m.c3 else 0 end as adjusted_c3,
       w.v
from t1000000m m
join t100000w w
  on w.c1 = m.c1
  where (case when m.c4 is null then 0 else m.c4 end) >= 0
order by m.c1 desc, m.c2 desc;


select c1, c2,
       count(*) filter (where c3 > 10) as cnt_hi,
       count(*) filter (where c3 <= 10) as cnt_lo
from t100000
group by c1, c2
order by c1 desc, c2 desc;


select m.c1, m.c2, m.c3
from t1000000m m
where exists (
    select 1
    from t100000 t
    where t.c1 = m.c1
      and t.c2 = m.c2
      and t.c3 = m.c3
)
order by m.c1 desc, m.c2 desc;


with x as (
    select c1, c2, c3,
           dense_rank() over (partition by c1 order by c3) as dr
    from t100000w
)
select c1, c2, c3, dr
from x
order by c1 desc, c2 desc;


select c1, c2, sum(c3) as s
from t100000
group by c1, c2
order by c1 desc, c2 desc;



select c1, c2, c3
from t100000
where c1 not in (1,2,3,4,5)
order by c1 desc, c2 desc;

select c1, c2, c3
from t100000
where c1=3
order by c1 desc, c2 desc;


select c1, c2, c3
from t1000000m
  where (c3 + c2 - c1) > 0
order by c1 desc, c2 desc;


select m.c1, m.c2
from t1000000m m
where not exists (
    select 1
    from t100000w w
    where w.c1 = m.c1
      and w.c2 = m.c2
)
order by m.c1 desc, m.c2 desc;


select c1, c2, c3
from t1000000m
where (c1,c2) in (
    select c1, c2
    from t100000
)
order by c1 desc, c2 desc;



select a.c1, a.c2, b.c3
from t1000000m a
join t1000000m b
  on a.c1 = b.c1
 and a.c2 = b.c2
where a.c1>a.c2
order by a.c1 desc, a.c2 desc;


with recursive r(c1,c2) as (
    select c1, c2
    from t100000

    union all

    select c1+1, c2
    from r
    where c1 < 10
)
select *
from r
order by c1 desc, c2 desc;



select m.c1, m.c2, m.c3
from t1000000m m
  where m.c3 > (m.c1 - m.c2)
order by m.c1 desc, m.c2 desc;



select c1, c2, v
from t100000w
  where v not like '%aaa%' and v='aaa'
order by c1 desc, c2 desc;



select c1, c2, v
from t100000w
  where length(v) > 5
order by c1 desc, c2 desc;


select m.c1, m.c2, t.c3
from t1000000m m
cross join t100 t
  where t.c1 = m.c1
order by m.c1 desc, m.c2 desc;


select m.c1, m.c2
from t1000000m m
  where exists (
      select 1
      from t100000w w
      where w.c1 = m.c1
  )
order by m.c1 desc, m.c2 desc;


select m.c1, m.c2, sum(w.c3) as s
from t1000000m m
join t100000w w
  on m.c1 = w.c1
where m.c1>m.c2
group by m.c1, m.c2
order by m.c1 desc, m.c2 desc;


select c1, c2, sum(c3) over (order by c1 desc range between unbounded preceding and current row)
from t100000w
  where c3 between 10 and 100
order by c1 desc, c2 desc;


with filtered as (
    select *
    from t100000w
)
select m.c1, m.c2, f.c3
from t1000000m m
join filtered f
  on m.c1 = f.c1
where m.c1>m.c2
order by m.c1 desc, m.c2 desc;
