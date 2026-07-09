set statement_timeout="240s";


SELECT id, k2, status, amt
  FROM ord
 WHERE k2 = 500
 ORDER BY id DESC
 LIMIT 200;

SELECT o.id, o.k2, e.amt
  FROM ord o
  LEFT JOIN events e ON e.id = o.id
 WHERE o.k2 = 500
 ORDER BY o.id DESC
 LIMIT 200;

SELECT o.id, o.k2, e.amt
  FROM ord o
  LEFT JOIN events_h e ON e.id = o.id
 WHERE o.k2 = 500
 ORDER BY o.id DESC
 LIMIT 200;

SELECT id, k2, status, amt
  FROM ord
 WHERE k2 = 500
   AND id > 2000000
 ORDER BY id DESC
 LIMIT 200;

SELECT id, ts, amt
  FROM ord
 WHERE k2 = 500
 ORDER BY ts DESC
 LIMIT 200;

SELECT k1, k2
  FROM ord
 WHERE k2 IN (500, 501)
 ORDER BY k1 DESC
 LIMIT 300;

SELECT k1, k2
  FROM ord
 WHERE k2 = 500
 ORDER BY k1 DESC
 LIMIT 200;

SELECT id, k1, k2
  FROM (
    SELECT id, k1, k2,
           row_number() OVER (ORDER BY k1 DESC) AS rn
      FROM ord
     WHERE k1 BETWEEN 10000 AND 19999
  ) x
 WHERE rn <= 100;


SELECT id,
       k2,
       status,
       amt,
       amt * 1.18 AS amt_with_tax,
       length(payload) AS payload_len
FROM ord
WHERE k2 = 500
  AND status IN ('new', 'completed')
  AND amt > 1000
ORDER BY id DESC
LIMIT 200;

SELECT id,
       k1,
       k2,
       status,
       amt,
       rank() OVER (ORDER BY amt DESC) rnk
FROM ord
WHERE k2 BETWEEN 450 AND 550
  AND amt > 500
ORDER BY id DESC
LIMIT 300;

SELECT id,
       ts,
       status,
       amt
FROM ord
WHERE status IN ('completed','cancelled')
UNION ALL
SELECT id,
       ts,
       status,
       amt
FROM ord
WHERE k2 BETWEEN 100 AND 120
ORDER BY ts DESC
LIMIT 400;

SELECT *
FROM (
        SELECT id,
               status,
               amt,
               sum(amt) OVER(
                    PARTITION BY status
                    ORDER BY ts
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) running_total
        FROM ord
        WHERE ts > now()-interval '90 days'
     ) s
WHERE running_total>100000
ORDER BY running_total DESC;

WITH p1 AS (
    SELECT *
    FROM events
    WHERE grp < 200
),
p2 AS (
    SELECT *
    FROM events
    WHERE grp BETWEEN 200 AND 500
),
p3 AS (
    SELECT *
    FROM events
    WHERE grp > 500
)
SELECT grp,
       avg(amt),
       count(*)
FROM (
    SELECT * FROM p1
    UNION ALL
    SELECT * FROM p2
    UNION ALL
    SELECT * FROM p3
) t
GROUP BY grp
ORDER BY avg(amt) DESC;


SELECT id, k2, status, amt
  FROM ord
 WHERE k2 = 500
 ORDER BY id DESC
 LIMIT 50 OFFSET 400;

SELECT id, k2, status, amt
  FROM ord
 WHERE k2 = 500
   AND id < 2500000
 ORDER BY id DESC
 LIMIT 200;

SELECT id, ts, status
  FROM ord
 WHERE status = 'cancelled'
   AND k2 < 20
 ORDER BY ts DESC
 LIMIT 200;

SELECT id, ts, status
  FROM ord
 WHERE k2 IN (500, 501)
 ORDER BY id DESC
 LIMIT 300;

SELECT id, ts, status
  FROM ord
 WHERE k2 = 123
 ORDER BY id DESC
 LIMIT 500;

SELECT DISTINCT k1, k2
  FROM ord
 WHERE k2 = 500
 ORDER BY k1 DESC
 LIMIT 100;

SELECT DISTINCT k1, k2
  FROM ord
 WHERE k2 = 500
   AND k1 < 20000
 ORDER BY k1 DESC
 LIMIT 200;

SELECT DISTINCT k1, k2
  FROM ord
 WHERE k2 = 500
 ORDER BY k1 DESC
 LIMIT 100 OFFSET 300;


WITH p1 AS (
    SELECT *
    FROM events_h
    WHERE grp < 200
),
p2 AS (
    SELECT *
    FROM events
    WHERE grp BETWEEN 200 AND 500
),
p3 AS (
    SELECT *
    FROM events_h
    WHERE grp > 500
)
SELECT grp,
       avg(amt),
       count(*)
FROM (
    SELECT * FROM p1
    UNION ALL
    SELECT * FROM p2
    UNION ALL
    SELECT * FROM p3
) t
GROUP BY grp
ORDER BY avg(amt) DESC;