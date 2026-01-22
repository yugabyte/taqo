SELECT c1, c2 FROM table_simple WHERE bucketid IN (0,1,2) ORDER BY c1, c2;
SELECT c1, c2 FROM table_simple WHERE c1 + c2 < 100 AND c1 > c2 ORDER BY c1, c2;
SELECT c2, c3 FROM table_simple WHERE c2 >= 0 AND c3 >= 1 AND (c2 + c3 * 3) % 7 < 5 ORDER BY c2, c3;
SELECT c2, c4 FROM table_simple WHERE c2 = 10 ORDER BY c2, c4;
SELECT c1, c2 FROM table_simple WHERE bucketid IN (0,1,2) AND c1 BETWEEN 10 AND 20 ORDER BY c1, c2;
SELECT c2, c4 FROM table_simple WHERE c2 * 3 + c4 < 10000 AND MOD(c2 + c4, 13) <= 8 ORDER BY c2, c4;
SELECT c1, v FROM table_simple WHERE c1 > length(v) ORDER BY c1, v;
SELECT c1, v FROM table_simple WHERE length(v) BETWEEN 10 AND 20 ORDER BY c1, v;
SELECT c2, v FROM table_simple WHERE v LIKE 'aa%' AND c2 % 17 < 12 AND LENGTH(v) > 3 ORDER BY c2, v;
SELECT c4, c5 FROM table_simple WHERE c4 BETWEEN 1 AND 500 AND c4 % 11 + c5 % 7 < 15 ORDER BY c4, c5;


SELECT c1, c2, c3, c4 FROM table_simple ORDER BY c1 DESC, c2 DESC;
SELECT c2, c3 FROM table_simple WHERE c2 BETWEEN 100 AND 50000 ORDER BY c2 DESC, c3 DESC;
SELECT DISTINCT ON (c1, c2) c1, c2, c3 FROM table_simple ORDER BY c1 DESC, c2 DESC, c3 DESC;
SELECT c1, c2, c3 FROM table_simple WHERE c1 NOT IN (1,2,3,4,5) ORDER BY c1 DESC, c2 DESC;
SELECT c1, c2, c3 FROM table_simple WHERE c1 = 3 ORDER BY c1 DESC, c2 DESC;
SELECT c1, c2, c3 FROM table_simple WHERE (c3 + c2 - c1) > 0 ORDER BY c1 DESC, c2 DESC;
SELECT c1, c2, v FROM table_simple WHERE v NOT LIKE '%aaa%' AND v = 'aaa' ORDER BY c1 DESC, c2 DESC;
SELECT c1, c2, v FROM table_simple WHERE c1=2 ORDER BY c1 DESC, c2 DESC;
SELECT c1, c2, c3 FROM table_simple WHERE c1 BETWEEN 100 AND 50000 and c2=10 ORDER BY c1 DESC, c2 DESC LIMIT 500;
SELECT c2, c3, c4 FROM table_simple WHERE c2 > c3 ORDER BY c2 DESC, c3 DESC;


SELECT * FROM table_simple WHERE c5 <= 100000 AND (c4 = 4 OR c3 = 4);
SELECT * FROM table_simple WHERE c5 <= 100000 AND (c4 <= 10 OR c3 <= 10);
SELECT * FROM table_simple WHERE c2 <= 10 AND c6 <= 1 ORDER BY c2 LIMIT 1024;
SELECT c3, c4, c5 FROM table_simple WHERE c5 <= 100 AND (c4 = 4 OR c3 = 4) ORDER BY c5, c4, c3 LIMIT 1024;
SELECT * FROM table_simple WHERE c1 <= 100 OR c2 <= 100 ORDER BY c1 LIMIT 1024;


SELECT c2, c3, row_number() OVER (PARTITION BY c2 ORDER BY c3 NULLS LAST) AS rn, avg(c4) OVER (PARTITION BY c2) AS avg_c4 FROM table_simple WHERE c2 BETWEEN 10 AND 90 AND c3 IS NOT NULL;
SELECT c2, c3, dense_rank() OVER (PARTITION BY c2 ORDER BY c2, c3) AS dr, avg(c4) OVER (PARTITION BY c2) AS avg_c4 FROM table_simple ORDER BY c2, c3;
SELECT c2, c4, row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn, dense_rank() OVER (PARTITION BY c2 ORDER BY coalesce(c4,0)) AS dr FROM table_simple ORDER BY c2, c4;
SELECT c2, c3, row_number() OVER (PARTITION BY c2 ORDER BY c3) AS rn, count(*) OVER (PARTITION BY c3) AS freq FROM table_simple WHERE c2 BETWEEN 100 AND 900;
SELECT c2, c3, rank() OVER (PARTITION BY c2 ORDER BY c3) AS rnk, count(*) OVER (PARTITION BY c2) AS cnt FROM table_simple ORDER BY c2, c3;
SELECT c2, length(v) AS vlen, row_number() OVER (PARTITION BY c2 ORDER BY length(v)) AS rn FROM table_simple ORDER BY c2, v;
SELECT c2, c4, avg(c5) OVER (ORDER BY c2 ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) AS mov_avg FROM table_simple WHERE c2 > c4 ORDER BY c2, c4;
SELECT c2, c3, count(*) OVER (PARTITION BY c3) AS cnt, avg(c5) OVER (PARTITION BY c2) AS avg_c5 FROM table_simple WHERE c2 BETWEEN 1000005 AND 1005000;
SELECT c2, c5, sum(c6) OVER (ORDER BY c5 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum FROM table_simple WHERE c5 BETWEEN 1000 AND 90000 ORDER BY c2, c5;
SELECT c1, c2, row_number() OVER (ORDER BY c1, c2) AS rn FROM table_simple WHERE bucketid IN (0,1,2) ORDER BY c1, c2;


SELECT t1.c1, t1.c2, t2.c4 FROM table_simple t1 JOIN table_simple t2 ON t1.c2 = t2.c2 WHERE t1.c2 BETWEEN 5 AND 500;
SELECT m.c1, m.c2, t.c3 FROM table_simple m JOIN table_simple t ON m.c1 = t.c1 WHERE m.c2 > m.c1;
SELECT t1.c1, t1.c2, t1.c4, t2.c3 FROM table_simple t1 JOIN table_simple t2 ON t1.c2 = t2.c2 WHERE t1.c4 BETWEEN 20 AND 80 order by t1.c1, t1.c4;
SELECT big.c1, big.c2, small.c3 FROM table_simple big JOIN table_simple small ON small.c1 = big.c1 AND small.c2 = big.c2 WHERE big.c1 > big.c2 ORDER BY big.c1, big.c2;
SELECT m.c1, m.c2, m.c3, t.c4 FROM table_simple t JOIN table_simple m ON m.c1 = t.c1 AND m.c3 = t.c3 WHERE greatest(m.c1, m.c3) = m.c1 and m.c2=10 ORDER BY m.c1, m.c3;
SELECT m.c1, m.c2, w.v FROM table_simple w JOIN table_simple m ON m.c1 = w.c1 AND m.c2 = w.c2 WHERE sign(w.c1 - w.c2) = 1 and m.c2=10 ORDER BY w.c1, w.c2;
SELECT m.c1, m.c2, w.v, t.c3 FROM table_simple m JOIN table_simple w ON w.c1 = m.c1 AND abs(w.c2 - m.c2) = 0 and m.c1=100 JOIN table_simple t ON t.c2 = m.c2 WHERE sign(m.c1 - m.c2) >= 0 ORDER BY m.c1, m.c2;
SELECT m.c1, m.c2, w.v FROM table_simple m JOIN table_simple w ON w.c1 = m.c1 AND abs(w.c2 - m.c2) = 0 WHERE (m.c3 IN (5, 10, 15) OR m.c4 BETWEEN 100 AND 200) AND m.c1 >= m.c2 ORDER BY m.c1, m.c2;
SELECT a.c1, a.c2, b.c3 FROM table_simple a JOIN table_simple b ON a.c1 = b.c1 AND a.c2 = b.c2 WHERE a.c1 > a.c2 AND b.c1 < b.c2 + 10 and b.c1=20 and a.c1=10 ORDER BY a.c1, a.c2;
create or replace function bucketed_or_full_scan_simple()
returns table (c1 int, c2 int)
language plpgsql
as $$
begin
  return query
  select m.c1, m.c2
  from table_simple m
  where exists (
    select 1
    from table_simple w
    where w.c1 = m.c1
      and w.c2 = m.c2
      and (yb_hash_code(w.c1, w.c2) % 3) in (0,1,2)
  )
  order by m.c1, m.c2;
exception when others then
  return query
  select *
  from table_simple;
end;
$$;
select * from bucketed_or_full_scan_simple();
