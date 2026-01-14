SELECT c1, c2 FROM t100 WHERE bucketid IN (0,1,2) order by c1,c2;
SELECT c1, c2, c3, c4 FROM t100 WHERE bucketid IN (0,1,2) AND c1<>0 order by c1,c2;
SELECT c1, c2 FROM t100 WHERE bucketid IN (0,1,2) and c1 between 10 and 20 order by c1,c2;
SELECT c1, c2, c3, c4 FROM t100 WHERE bucketid IN (0,1,2) AND c1=0 order by c1,c2;
SELECT c1,c2 FROM t100 WHERE bucketid in (0,1,2) and c1>c2 order by c1,c2;
SELECT c1,c2 FROM t100 WHERE bucketid in (0,1,2) and c2>c1 order by c1,c2;
SELECT c2, c4 FROM t1000 WHERE (yb_hash_code(c2, c4) % 3) IN (0,1, 2) order by c2,c4;
SELECT c2, c3 FROM t1000 WHERE (yb_hash_code(c2, c3) % 3) IN (0,1,2) and c2 >= 0 and c3 >= 1 order by c2,c3;
SELECT c2, c3 FROM t1000 WHERE (yb_hash_code(c2, c3) % 3) IN (0,1,2) and c2 >= -1 and c3 >= c2 order by c2,c3;
SELECT c2, c4 FROM t1000 WHERE (yb_hash_code(c2, c4) % 3) IN (0,1, 2) and c2=10 order by c2,c4;
SELECT c1, c2 FROM t10000 WHERE bucketid in (0,1,2) order by c1,c2;
SELECT c2, c4 FROM t10000 WHERE (yb_hash_code(c2, c4) % 3) in (0,1,2) order by c2,c4;
SELECT c2, c4 FROM t10000 WHERE (yb_hash_code(c2, c4) % 3) in (0,1,2) and c2=10 order by c2,c4;
SELECT c1, c2 FROM t10000 WHERE (yb_hash_code(c2, c1) % 3) in (0,1,2) and c1>c2 order by c1,c2;
SELECT c1, c2 FROM t10000 WHERE (yb_hash_code(c2, c1) % 3) in (0,1,2) and c1>10 and c2>10 order by c1,c2;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and c1>length(v) order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and length(v) between 10 and 20 order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and length(trim(v)) > 1000 order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and substr(v, 1, 5) = '00000' order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and v like '----%' order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and length(v)=2 order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and length(v)=4 or c2>10 order by c1,v;
SELECT c1,v FROM t10000 WHERE (yb_hash_code(c1, v) % 3) in (0,1,2) and length(v)=4 or c2>10 and c4 between 10 and 20 order by c1,v;
SELECT c2,c3,c4 FROM t10000 WHERE (yb_hash_code(c3, c4) % 3) in (0,1,2) order by c2,c3,c4;
SELECT c1, c2, c3, c4 FROM t100000 WHERE bucketid in (0,2,1) order by c1,c2;
/*+IndexScan (t100000_bucketized_1)*/ SELECT c2, c3 FROM t100000 WHERE (yb_hash_code(c2, c3)%3) in (0,2,1) order by c2,c3;
/*+ IndexScan(t100000_bucketized_2) */SELECT c2, c3, c4 FROM t100000 WHERE (yb_hash_code(c2, c4) % 3) in (0,1,2) and c3 IS NOT NULL order by c2,c4;
SELECT c1, c2, c3, c4 FROM t100000w WHERE bucketid in (0,2,1) order by c1,c2;
SELECT c1, c2, c3, c4 FROM t100000w WHERE bucketid in (0,2,1) and c1=10 order by c1,c2;
set enable_seqscan to false;
/*+IndexScan(t100000w_bucketized_1)*/SELECT c1, c2, c3, c4 FROM t100000w WHERE (yb_hash_code(c2, c3) % 3) in (0,2,1)  order by c2,c3;
/*+IndexScan(t100000w_bucketized_1)*/SELECT c1, c2, c3, c4 FROM t100000w WHERE (yb_hash_code(c2, c3) % 3) in (0,2,1)  and v like '----%'  order by c2,c3;
/*+IndexScan(t100000w_bucketized_1)*/SELECT c1, c2, c3, c4 FROM t100000w WHERE (yb_hash_code(c2, c3) % 3) in (0,2,1) and c2 between 10 and 1000 order by c2,c3;
/*+IndexScan(t100000w_bucketized_4)*/SELECT bucketid FROM t100000w WHERE (yb_hash_code(bucketid, v) % 3) in (0,2,1)  order by bucketid,v;
/*+IndexScan(t100000w_bucketized_5)*/SELECT c2,v FROM t100000w WHERE (yb_hash_code(c2, v) % 3) in (0,2,1)  order by c2,v;
/*+IndexScan(t100000w_bucketized_5)*/SELECT c2,v FROM t100000w WHERE (yb_hash_code(c2, v) % 3) in (0,2,1) and  v like '----%' order by c2,v;
SELECT c1, c2, c3, c4 FROM t1000000m WHERE bucketid in (0,2,1) order by c1,c2;
SELECT c1, c2, c3, c4 FROM t1000000m WHERE bucketid in (0,2,1) and c2=10 order by c1,c2;
/*+IndexScan(t1000000m_bucketized_1)*/SELECT c2, c3, c4 FROM t100000w WHERE (yb_hash_code(c2, c3) % 3) in (0,2,1)  order by c2,c3;
/*+IndexScan(t1000000m_bucketized_1)*/SELECT c2, c3, c4 FROM t100000w WHERE (yb_hash_code(c2, c3) % 3) in (0,2,1) and c2=10 order by c2,c3;
/*+IndexScan(t1000000m_bucketized_2)*/SELECT c2,c4 FROM t100000w WHERE (yb_hash_code(c2, c4) % 3) in (0,2,1) and c2>c4 order by c2,c4;
/*+IndexScan(t1000000m_bucketized_3)*/SELECT c1,c2,c3 FROM t100000w WHERE (yb_hash_code(c1, c2) % 3) in (0,2,1) and c1>c2 order by c1,c2;
/*+IndexScan(t1000000m_bucketized_4)*/SELECT bucketid,c6 FROM t100000w WHERE (yb_hash_code(bucketid, c6) % 3) in (0,2,1) order by bucketid,c6;
/*+IndexScan(t1000000m_bucketized_4)*/SELECT bucketid,c6 FROM t100000w WHERE (yb_hash_code(bucketid, c6) % 3) in (0,2,1) and bucketid =2 order by bucketid,c6;
/*+IndexScan(t1000000m_bucketized_5)*/SELECT c2,c5 FROM t100000w WHERE (yb_hash_code(c2, c5) % 3) in (0,2,1) order by c2,c5;
SELECT m.c2, m.c3 FROM t1000000m m WHERE (yb_hash_code(m.c2, m.c3) % 3) in (0,1,2) AND m.c2 = 15 AND m.c3 = 3 order by c2,c3;
select c2, c3, c4 from t1000000m where (yb_hash_code(c2, c4) % 3) in (0,1,2) and c2 in (50, 100) order by c2, c4 limit 500;
SELECT m.c1, m.c2, m.c3 FROM t1000000m m WHERE c1 = 50 AND c3 = 20 AND EXISTS ( SELECT 1 FROM t1000000m x WHERE x.c1 = m.c1 AND x.c2 = m.c2 AND x.c4 = 100) order by c2,c4;
SELECT a.c1, a.c2, a.c3 FROM t1000000m a WHERE a.c1 = 100 AND a.c3 = 30 AND a.c2 = 4 AND a.c5 IN ( SELECT c2 FROM t1000000m WHERE c5 = 1 );
SELECT a.c2 as col2, a.c4 as col4 FROM t10000 a WHERE a.c2 <> 0 AND a.c3 > 100 AND a.c3 IN (SELECT c2 FROM t1000 WHERE c3 <> 0);
select a.c2 as col2, a.c3 as col3 from t10000 a where a.c2 <> 0 and a.v is not null and a.c4 not in (select c2 from t10000 where c3 > 198);
select c1, c2 from t100 where bucketid in (0,1,2) and c2 between 5 and 50 order by c1, c2;
select c1, c2, c3 from t100 where bucketid in (0,1,2) and c3 is not null order by c1, c2;
select c1, c2 from t100 where bucketid in (0,1,2) and (c1 + c2) > 10 order by c1, c2;
select c1, c2 from t100 where bucketid in (0,1,2) and c2 between 1 and 99999 order by c1, c2;
select c1, c2, c3 from t100 where bucketid in (0,1,2) and c3 <> c2 order by c1, c2;
select c1, c2, c3 from t100 where bucketid in (0,1,2) and c1 is null or c2 is not null order by c1, c2;
select c2, c4 from t1000 where (yb_hash_code(c2, c4) % 3) in (0,1,2) and c4 between 1 and 500 order by c2, c4;
select c2, c3 from t1000 where (yb_hash_code(c2, c3) % 3) in (0,1,2) and c3 in (5,10,15,20) order by c2, c3;
select c2, c4 from t1000 where (yb_hash_code(c2, c4) % 3) in (0,1,2) and c2 <> c4 order by c2, c4;
select c2, c3, c4 from t1000 where (yb_hash_code(c3, c4) % 3) in (0,1,2) and c3 > 0 order by c3, c4;
select c2, c4 from t1000 where (yb_hash_code(c2, c4) % 3) in (0,1,2) and v like '---%' order by c2, c4;
select c1, c2 from t10000 where (yb_hash_code(c1, c2) % 3) in (0,1,2) and v like '---% 'order by c1, c2;
select c1, v from t10000 where (yb_hash_code(c1, v) % 3) in (0,1,2) and v like '__abc%' order by c1, v;
select c1, v from t10000 where (yb_hash_code(c1, v) % 3) in (0,1,2) and length(v) > 5 and v like '---%'order by c1, v;
select c1, v from t10000 where (yb_hash_code(c1, v) % 3) in (0,1,2) and position('xyz' in v) > 0 order by c1, v;
select c1, c2, c3 from t100000 where bucketid in (0,1,2) and c2 > 100 order by c1, c2;
select c2, c3 from t100000 where (yb_hash_code(c2, c3) % 3) in (0,1,2) and c3 < 5000 order by c2, c3;
select c2, c4 from t100000 where (yb_hash_code(c2, c4) % 3) in (0,1,2) and c4 between 10 and 20 order by c2, c4;
select c1, c2, c4 from t100000 where bucketid in (0,1,2) and c4 <> 0 order by c1, c2;
select c2, v from t100000w where (yb_hash_code(c2, v) % 3) in (0,1,2) and v like 'aa%' order by c2, v;
select c1, c2, c3, c4 from t100000w where bucketid in (0,1,2) and c3 between 5 and 500 order by c1, c2;
select c2, v from t100000w where (yb_hash_code(c2, v) % 3) in (0,1,2) and v similar to '[0-9]{2}%' order by c2, v;
select c1, c2, c3, c4 from t1000000m where bucketid in (0,1,2) and c2 between 100 and 5000 order by c1, c2;
select c2, c3 from t1000000m where (yb_hash_code(c2, c3) % 3) in (0,1,2) and c3 in (1,2,3,4,5) order by c2, c3;
select c2, c4 from t1000000m where (yb_hash_code(c2, c4) % 3) in (0,1,2) and c4 <> 0 order by c2, c4;
select c1, c2, c5 from t1000000m where bucketid in (0,1,2) and (c5 % 7) = 0 order by c1, c2;









