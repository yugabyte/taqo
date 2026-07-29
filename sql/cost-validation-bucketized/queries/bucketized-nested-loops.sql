
SELECT t1.c1, t2.c4, t3.c5
FROM t100 t1
JOIN t1000 t2 ON t1.c2 = t2.c2
JOIN t100000 t3 ON t2.c4 = t3.c4
WHERE t1.c2 BETWEEN 5 AND 500;

select big.c1, big.c2, small.c3
from (
    select c1, c2, c3
    from t1000
    where bucketid in (0,1,2)
    order by c1, c2
) small
join t100000 big
  on big.c1 = small.c1
 and big.c2 = small.c2
where big.c1>big.c2
order by big.c1, big.c2;


select m.c1, m.c2, m.c3, t.c4
from t100000 t
join t1000000m m
  on m.c1 = t.c1
 and m.c3 = t.c3
where greatest(m.c1, m.c3) = m.c1
order by m.c1, m.c3;


select w.c1, w.c2, w.v, m.c3
from t100000w w
join t1000000m m
  on m.c1 = w.c1
 and m.c2 = w.c2
where sign(w.c1 - w.c2) = 1
order by w.c1, w.c2;


select m.c1, m.c2, w.v, t.c3
from t1000000m m
join t100000w w
  on w.c1 = m.c1
 and abs(w.c2 - m.c2) = 0
join t100000 t
  on t.c2 = m.c2
 and coalesce(t.c1, 0) <= greatest(m.c1, w.c1)
where
    sign(m.c1 - m.c2) >= 0
and (m.c1 * 2 + m.c2) <> (m.c2 * 2 + m.c1)
and least(m.c1, m.c2) >= 0
order by m.c1, m.c2;



select m.c1, m.c2, w.v
from t1000000m m
join t100000w w
  on w.c1 = m.c1
 and abs(w.c2 - m.c2) = 0
where
    (
        m.c3 in (5, 10, 15)
        or m.c4 between 100 and 200
    )
and (
        m.c1 >= m.c2
     or (m.c1 + m.c2) % 2 = 1
    )
and least(m.c1, m.c2) >= 0
order by m.c1, m.c2;


SELECT t1.c1, t1.c2, t2.c4, t2.v
FROM t100 t1
JOIN t1000 t2
  ON t1.c2 = t2.c2
WHERE t1.c2 BETWEEN 10 AND 200
  AND t2.c4 IS NOT NULL order by t1.c1,t1.c2;

SELECT t1.c1, t1.c2, t2.c2, t2.c4
FROM t100 t1
JOIN t1000 t2
  ON t1.c2 = t2.c2
WHERE t2.c2>t2.c4
  AND t2.c4 IS NOT NULL order by t2.c2,t2.c4;


SELECT t1.c2, t1.v, t5.c3
FROM t100 t1
JOIN t100000w t5
  ON lower(t1.v) LIKE lower('%abc%')
WHERE t5.c2 < 50000 limit 1000;


select m.c1,
       m.c2,
       w.v,
       row_number() over (order by m.c1, m.c2) as rn
from (
    select c1, c2, v
    from t100000w
    where
          c1 >= 0
      and c2 >= 0
      and abs(c1 - c2) >= 0
    order by c1, c2
    limit 5000
) w
join t1000000m m
  on m.c1 = w.c1
 and m.c2 = w.c2
where
      m.c1 >= m.c2
  and (m.c1 + m.c2) % 3 in (0,1,2)
  and greatest(m.c1, m.c2) >= 0
order by m.c1, m.c2
limit 1000;



select m.c2,
       count(*) as cnt,
       avg(m.c6) as avg_c6
from t1000000m m
join t100000w w
  on w.c2 = m.c2
where
      m.c2 >= 0
  and w.c2 >= 0
  and abs(m.c2 - w.c2) = 0
  and (m.c2 + coalesce(m.c6,0)) >= m.c2
group by m.c2
order by m.c2 limit 1000;


select m.c1, m.c2, m.c3
from t1000000m m
where exists (
    select 1
    from t100000w w
    where w.c1 = m.c1
      and w.c2 = m.c2
      and w.c1>w.c2
)
order by m.c1, m.c2 limit 100;

select m.c1,
       m.c2,
       ntile(3) over (order by m.c1, m.c2) as nt,
       w.v
from t1000000m m
join t100000w w
  on w.c1 = m.c1
 and w.c2 = m.c2
where
      m.c1 >= m.c2
  and abs(m.c1 - m.c2) >= 0
  and (m.c1 + m.c2) >= m.c1
  and (m.c1 * 2) >= m.c2
order by m.c1, m.c2;


select m.c1, m.c2,
       sum(m.c6) over(partition by m.c2 order by m.c1 rows between unbounded preceding and current row) as run_sum
from t1000000m m
join t100000w w
  on m.c2 = w.c2
where  w.bucketid in (0,1,2)
order by m.c2, m.c1;


select m.c1, m.c2, w.v, t.c3
from t1000000m m
join t100000w w
  on w.c1 = m.c1
join t100000 t
  on t.c2 = m.c2
where w.bucketid in (0,1,2)
  and t.bucketid in (0,1,2)
order by m.c1, m.c2;



select m.c1, m.c2, w.v
from t1000000m m
join t100000w w
  on w.c1 = m.c1
where m.c1>m.c2
order by m.c1 desc, m.c2 desc;

select a.c1, a.c2, b.c3
from t1000000m a
join t1000000m b
  on a.c1 = b.c1
 and a.c2 = b.c2
where a.c1 > a.c2
  and b.c1 < b.c2 + 10
order by a.c1, a.c2;


with filtered as (
    select c1, c2
    from t100000w
    where c1 > 10
      and c2 < 1000
    order by c1, c2
    limit 5000
)
select m.c1, m.c2, m.c3
from t1000000m m
join filtered f
  on f.c1 = m.c1
 and f.c2 = m.c2
where m.c1 + m.c2 > 50
order by m.c1, m.c2;

with buckets(b) as (
    select generate_series(0,2)
)
select r.*
from buckets,
lateral (
    select *
    from t1000
      where c3 < 50
      and c5 > 10
    order by c2, c4
    limit 60
) r
order by c2, c4
limit 60;

with drivers as (
  select c1, c4, bucketid
  from t100000w
  where c1>c4
  order by bucketid, c1, c4
)
select d.c1, d.c4, m.c2, m.c6
from drivers d,
lateral (
  select c1, c2, c6
  from t1000000m
  where c1 = d.c1
    and c6 between 10 and 90000
    and (c2 > 100 or c2 < 50)
  order by c1, c2
  limit 15
) m
order by m.c1, m.c2;


with recursive r(c1,c2,depth) as (
  select c1, c2, 1
  from t100
    where c1>c2
  union all

  select t.c1, t.c2, depth+1
  from r
  join t1000 t
    on t.c1 = r.c1
   and t.c2 = r.c2
  where depth < 3
)
select r.c1, r.c2, x.c3
from r,
lateral (
  select c1, c3
  from t1000000m
  where c1 = r.c1
  order by c1, c3
  limit 10
) x
order by r.c1, r.c2;

with recursive r1(c1,c2,depth) as (
    select c1, c2, 1
    from t100
    where c1 > c2
    union all
    select t.c1, t.c2, depth + 1
    from r1
    join t1000 t
      on t.c1 = r1.c1
     and t.c2 = r1.c2
    where depth < 3
),
r2 as (
    select c1, c2
    from t10000
    where c2 between 5 and 50
)
select r1.c1, r1.c2, x.c3, x.c4, x.c5, x.v
from r1,
lateral (
    select c1, c3, c4, c5, v
    from t100000
    where c1 = r1.c1
      and c2 = r1.c2
      and coalesce(c3,0) + least(c4,100) > 10
      and greatest(c5,0) < 500
    order by c3 desc
    limit 5
) x

union all

select r2.c1, r2.c2, y.c3, y.c4, y.c5, y.v
from r2,
lateral (
    select c1, c3, c4, c5, v
    from t100000w
    where c1 = r2.c1
      and c2 = r2.c2
      and (coalesce(c3,0) % 7) = 0
      and substr(v,1,2) = '00'
    order by c4 desc
    limit 10
) y

union all

select s.c1, s.c2, z.c3, z.c4, z.c5, z.v
from (
    select c1, c2
    from t1000000m
    where c1 > 10 and c2 < 500
) s,
lateral (
    select c1, c3, c4, c5, v
    from t100000w
    where c1 = s.c1
      and c2 = s.c2
      and coalesce(c3,0) + coalesce(c4,0) < 1000
      and length(v) > 5
    order by c3 desc, c5 desc
    limit 7
) z

order by 1,2;

with src as (
    select c2, c3
    from t1000 where c2>c3
)
select src.c2, src.c3, z.c4, z.rnk
from src,
lateral (
    select c2, c3, c4,
           rank() over(order by coalesce(c4,0) desc) as rnk
    from t100000w
    where c2 = src.c2
      and c3 = src.c3
      and abs(c4 - coalesce(c3,0)) % 7 in (1,4,6)
      and greatest(c4, coalesce(c2,0), 10) < 100
      and least(c4, coalesce(c2,0), 1000) > 0
      and substr(c2::text || c3::text,1,2) = '10'
) z
where z.rnk <= 5
order by src.c2, src.c3;


with s as (
    select c1, v
    from t10000
    where v like '----%'
)
select s.c1, s.v, x.c3
from s,
lateral (
    select c1, c3
    from t100000w
    where c1 = s.c1
      and c3 not in (
          select c3
          from t1000 where c1>c2
      )
      and length(s.v) > 0
      and abs(c3 - coalesce(s.c1,0)) % 5 in (1,3)
      and greatest(c3, coalesce(s.c1,0), 10) < 100
      and least(c3, coalesce(s.c1,0), 1000) > 0
      and substr(s.v,1,3) = '---'
) x
order by s.c1, x.c3;



with seed as (
    select c1
    from t100
    where bucketid in (0,1,2)
)
select seed.c1, t.c2, t.c3
from seed,
lateral (
    select a.c2, b.c3
    from t10000 a
    full join t10000 b
      on a.c1 = b.c1
    where a.c1 = seed.c1
      and coalesce(a.c2,0) > 10
      and greatest(a.c3, b.c3, 0) < 100
      and least(a.c4, b.c4, 1000) > 0
      and abs(a.c2 - b.c2) % 7 in (1,3,5)

) t
order by t.c2, t.c3;


select distinct on (c1, c2)
       c1, c2, c3, c4
from t1000000m
where c3 is not null
  and c4 > 50
  and c1 + c2 < 200
  and c5 % 10 in (1, 3, 7)
order by c1, c2, c4 desc;


SELECT c1, c2, sum(c3), avg(c4)
FROM t1000000m
WHERE c1>c2
GROUP BY GROUPING SETS ((c1,c2),(c1),(c2))
ORDER BY c1, c2;

SELECT c1, c2, count(*)
FROM t100000
GROUP BY c1, c2
HAVING sign(c1 - c2) >= 0
    and (c1 * 2 + c2) <> (c2 * 2 + c1)
ORDER BY c1, c2;

SELECT c1, c2
FROM t100000

INTERSECT

SELECT c1, c2
FROM t1000000m
WHERE sign(c1 - c2) >= 0  and coalesce(c1, 0) <= greatest(c1, c1)
ORDER BY c1, c2;


SELECT a.c1, a.c2, b.c3
FROM t100000 a
JOIN t100000 b
  ON a.c1 = b.c1
 AND a.c2 = b.c2
WHERE sign(a.c1 - b.c2) >= 0
    and (b.c1 * 2 + b.c2) <> (a.c2 * 2 + b.c1) and coalesce(a.c1, 0) <= greatest(a.c1, b.c1)
ORDER BY a.c1, a.c2;

SELECT c1, c2, c3
FROM t100000 t
WHERE EXISTS (
   SELECT 1
   FROM t100 t2
   WHERE t2.c1 = t.c1
     AND t2.c2 = t.c2
)
AND sign(c1 - c2) >= 0
    and (c1 * 2 + c2) <> (c2 * 2 + c1) and coalesce(c1, 0) <= greatest(c1, c1)
ORDER BY c1, c2;


WITH x AS (
   SELECT *,
          row_number() OVER (ORDER BY c1,c2) AS rn
   FROM t100000
   WHERE
    sign(c1 - c2) >= 0
    and (c1 * 2 + c2) <> (c2 * 2 + c1)
)
SELECT *
FROM x
WHERE rn % 2 = 0
ORDER BY c1, c2;

WITH z AS (
   SELECT *,
          dense_rank() OVER (PARTITION BY c1 ORDER BY c2) r
   FROM t100000
   WHERE c1>c2
)
SELECT *
FROM z
WHERE r < 5
ORDER BY c1, c2;


with buckets(mod) as (select generate_series(0,2))
select r.* from buckets,lateral (
  select * from t10000
  where c2=c4
  order by c2,c4
) r limit 10;


with buckets(mod) as (select generate_series(0,2))
  select r.*
  from buckets,
  lateral (
    select c1, c2, c3, c4, c5, c6, bucketid
    from t100000w
    where bucketid in (0,1,2)
      and c3>10
    order by bucketid, c2, c3
    limit 29
  ) r
  order by bucketid, c2, c3
  limit 29;


with seeds as (
    select c1, c2
    from t100
    where bucketid in (0,1,2)
    order by c1, c2
  )
  select s.c1, s.c2, x.avg_c4, x.max_c5
  from seeds s,
  lateral (
    select avg(c4) as avg_c4,
           max(c5) as max_c5
    from t100000
    where c1 = s.c1
      and c2 = s.c2
  ) x
  order by s.c1, s.c2;


WITH src AS (
    SELECT c2, c3
    FROM t10000
    WHERE c2 > c3
)
SELECT src.c2, src.c3, z.c4, z.rnk
FROM src,
LATERAL (
    SELECT *
    FROM (
        SELECT m.c2, m.c3, m.c4,
               rank() OVER (ORDER BY m.c4 DESC) rnk,
               row_number() OVER (PARTITION BY m.c2 ORDER BY m.c4 DESC) rn
        FROM t100000w m
        WHERE abs(m.c4 - src.c3) % 7 IN (1,4,6)
    ) sub
    WHERE sub.rn <= 50
) z
WHERE z.rnk <= 10
ORDER BY src.c2, src.c3;

with src as (
    select c2, c3
    from t10000
    where c2 > c3
)
select src.c2, src.c3, z.c4, z.rnk
from src,
lateral (
    select c2, c3, c4,
           rank() over (order by coalesce(c4, 0) desc) as rnk
    from t100000w
    where c2 = src.c2
      and c3 = src.c3
      and abs(c4 - coalesce(c3, 0)) % 7 in (1, 4, 6)
      and greatest(c4, coalesce(c2, 0), 10) < 100
      and least(c4, coalesce(c2, 0), 1000) > 0
      and substr(c2::text || c3::text, 1, 2) = '10'
) z
where z.rnk <= 5
order by src.c2, src.c3;


with src as (
    select c1, c2, c3
    from t1000000m
)
select src.c1, src.c2, z.c5, z.rnk
from src,
lateral (
    select m.c5, m.c6,
           rank() over (
               order by coalesce(m.c6, 0) desc,
                        coalesce(m.c5, 0),
                        m.c1
           ) as rnk
    from t1000000m m
    where m.c3 = src.c3
) z
where z.rnk <= 80
order by src.c1, src.c2;

with src as (
    select c1, c2, c3
    from t1000000m
)
select src.c1, src.c3, z.c6, z.rn1, z.rn2
from src,
lateral (
    select c6,
           row_number() over (order by coalesce(c6, 0) desc, c5) as rn1,
           dense_rank() over (order by c4, c5) as rn2
    from t1000000m m
    where m.c3 = src.c3
) z
where z.rn1 <= 120
  and z.rn2 <= 40
order by src.c1, src.c3;


with src as (
    select c2, c3
    from t10000
    where c2 > c3
    order by c2, c3
    limit 6000
)
select src.c2, src.c3, z.c4, z.rnk
from src,
lateral (
    select c2, c3, c4,
           rank() over (order by coalesce(c4, 0) desc) as rnk
    from t100000w
    where c2 = src.c2
      and c3 = src.c3
) z
where z.rnk <= 10
order by src.c2, src.c3;


with src as (
    select c1, c3
    from t1000000m
)
select src.c1, z1.mx as mx_c6, z2.mn as mn_c5
from src,
lateral (
    select max(coalesce(m.c6, 0)) as mx
    from t1000000m m
    where m.c3 = src.c3
) z1,
lateral (
    select min(coalesce(m.c5, 0)) as mn
    from t1000000m m
    where m.c3 = src.c3
) z2
order by src.c1;


with seeds as (
    select c1, c2
    from t10000
    where c2 > c3
    order by c1, c2
    limit 8000
)
select s.c1, s.c2, x.c4, x.run_sum
from seeds s,
lateral (
    select b.c4,
           sum(coalesce(b.c6, 0)) over (
               order by b.c5
               rows between unbounded preceding and current row
           ) as run_sum
    from table_bucketized b
    where b.c1 = s.c1
      and b.c2 = s.c2
) x
order by s.c1, s.c2;

select a.c1,
       a.c2,
       b.c3 as b_c3,
       c.c4 as c_c4,
       dense_rank() over (order by a.c1, a.c2, coalesce(b.c6, 0) + coalesce(c.c6, 0)) as dr
from t100000 a
join t100000 b
  on a.c1 = b.c1
 and a.c2 = b.c2
join t100000 c
  on c.c1 = a.c1
 and c.c2 = (a.c2 + sign(a.c2 - b.c2))
where a.c1 > a.c2
  and nullif(b.c3, c.c3) is not null
  and abs(coalesce(a.c4, 0) - coalesce(b.c4, 0) - coalesce(c.c4, 0)) % 5 in (0, 2, 4)
  and greatest(a.c5, b.c5, least(c.c5, 999999)) between 1 and 999999
order by a.c1, a.c2;


select m.c1,
       m.c2,
       t.c3,
       b.c5,
       sum(coalesce(m.c6, 0) * sign(t.c1 - t.c2 + 1)) over (
           partition by m.c3, t.bucketid
           order by m.c1, m.c2
           rows between 2 preceding and 2 following
       ) as wsum
from t1000000m m
join t100000 t
  on t.c1 = m.c1
 and t.c2 = m.c2 - 10000
join table_bucketized b
  on b.c1 = m.c1
 and b.c2 = m.c2
where m.c2 > m.c1
  and coalesce(t.c4, 0) + coalesce(b.c4, 0) < 200000
  and substr(b.v, 1, 3) = substr(t.v, 1, 3)
  and (m.c5 + b.c5 + abs(coalesce(t.c3, 0))) % 13 in (1, 5, 9)
order by m.c1, m.c2
limit 1500;


select t1.c2,
       t2.c3,
       m.c6,
       ntile(4) over (order by greatest(t1.c1, t2.c1, m.c1)) as q
from t100 t1
join t10000 t2
  on t2.c2 = t1.c2 + (t1.c1 % 7) * sign(t1.c1)
join t1000000m m
  on m.c1 = t2.c1
 and m.c2 = t2.c2 + 10000
where least(t1.c3, t2.c3, coalesce(m.c3, 0)) >= 0
  and greatest(coalesce(t1.c6, 0), t2.c6, m.c6) is not null
  and (t1.c4 * t2.c4 + coalesce(m.c4, 0)) % 17 <> 15
order by t1.c2, m.c1
limit 3000;


select count(*) as cnt
from (
    select v.c1, v.c2, v.c3, g.n
    from t10000 v
    cross join generate_series(1, 10000) g(n)
    where v.c2 > v.c3
    order by v.c1, v.c2, g.n
    limit 5000
) d,
lateral (
    select rank() over (
               order by coalesce(w.c4, 0) desc,
                        length(substr(w.v, 1, least(600, greatest(100, (d.n * 37 + w.c1) % 500)))),
                        w.c5
           ) as rk
    from t100000w w
    where w.c1 = d.c1
      and w.c2 = d.c2
      and greatest(coalesce(w.c3, 0), d.c3, 0) < 100000
      and least(coalesce(w.c4, 999), coalesce(w.c5, 0), 999999) > -999999
      and abs(coalesce(w.c4, 0) - d.c3 - d.n) % 5 in (0, 1, 2, 3, 4)
) z
where z.rk <= 120;


select (select count(*) from generate_series(1, 9000) g(i),
        lateral (
            select rank() over (order by m.c6 desc, m.c5, m.c4) rk
            from t1000000m m
            where m.c3 = ((abs(g.i) % 10) + 1) * 10
        ) l
        where l.rk <= 300
       )
     + (select count(*) from generate_series(1, 9000) g(i),
        lateral (
            select dense_rank() over (partition by m.c4 order by m.c6, m.c5) dr
            from t1000000m m
            where m.c3 = ((abs(g.i + 3) % 10) + 1) * 10
        ) l2
        where l2.dr <= 300
       ) as pair_cnt;


SELECT COUNT(*)
FROM generate_series(1, 7000) g(i),
LATERAL (
    SELECT *
    FROM (
        SELECT m.*,
               row_number() OVER (PARTITION BY m.c4 ORDER BY m.c6 DESC) rn,
               dense_rank() OVER (ORDER BY m.c5) dr
        FROM t1000000m m
        WHERE m.c3 = ((g.i % 10) + 1) * 10
    ) sub
    WHERE rn <= 20 AND dr <= 100
) x;


WITH src AS (
    SELECT c2, c3
    FROM t10000
    WHERE c2 > c3
)
SELECT src.c2, src.c3, z.c4, z.rnk
FROM src,
LATERAL (
    SELECT *
    FROM (
        SELECT m.c2, m.c3, m.c4,
               rank() OVER (ORDER BY m.c4 DESC) rnk,
               dense_rank() OVER (PARTITION BY m.c3 ORDER BY m.c4) dr,
               sum(m.c4) OVER (PARTITION BY m.c2) s
        FROM t100000w m
        WHERE abs(m.c4 - src.c3) % 7 IN (1,4,6)
          AND (m.c2 + m.c3 + m.c4) % 5 <> 0
          AND random() < 0.95
    ) sub1,
    LATERAL (
        SELECT avg(m2.c4) avg_val
        FROM t100000w m2
        WHERE m2.c2 = sub1.c2
    ) sub2
    WHERE sub1.dr <= 100
) z
WHERE z.rnk <= 20
ORDER BY src.c2, src.c3;


WITH src AS (
    SELECT c2, c3
    FROM t10000
    WHERE c2 > c3
    ORDER BY c2, c3
    LIMIT 6000
)
SELECT src.c2, src.c3, z.c4, z.rnk
FROM src,
LATERAL (
    SELECT *
    FROM (
        SELECT m.c2, m.c3, m.c4,
               rank() OVER (ORDER BY m.c4 DESC) rnk,
               dense_rank() OVER (PARTITION BY m.c3 ORDER BY m.c4) dr
        FROM t100000w m
        WHERE m.c2 = src.c2
          AND random() < 0.98
    ) sub1,
    LATERAL (
        SELECT avg(m2.c4) avg_val
        FROM t100000w m2
        WHERE m2.c3 = sub1.c3
    ) sub2
    WHERE sub1.dr <= 200
) z
WHERE z.rnk <= 20
ORDER BY src.c2, src.c3;


WITH src AS (
    SELECT c2, c3
    FROM t10000
    WHERE c2 > c3
    ORDER BY c2, c3
    LIMIT 6000
)
SELECT src.c2, src.c3, z.c4, z.rnk
FROM src,
generate_series(1, 5),
LATERAL (
    SELECT *
    FROM (
        SELECT c2, c3, c4,
               rank() OVER (ORDER BY random()) rnk,  -- worst-case sort
               row_number() OVER (PARTITION BY c2 ORDER BY random()) rn
        FROM t100000w
        WHERE (c2 + 0) = src.c2
          AND (c3 + 0) = src.c3
          AND random() < 0.99
    ) t
    WHERE rn <= 200
) z
WHERE z.rnk <= 50
ORDER BY src.c2, src.c3;