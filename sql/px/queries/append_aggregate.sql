set statement_timeout="240s";

SELECT id,
       grp,
       amt,
       (
           SELECT avg(e2.amt)
           FROM events e2
           WHERE e2.grp = e1.grp
       ) grp_avg
FROM events e1
WHERE grp < 500
ORDER BY ts DESC
LIMIT 500;

SELECT count(*) FROM events WHERE id > (SELECT max(id) - 5000 FROM events);

SELECT 1 AS window_n, count(*) AS cnt FROM events WHERE id > (SELECT max(id) - 500 FROM events)
UNION ALL
SELECT 2, count(*) FROM events WHERE id > (SELECT max(id) - 1000 FROM events)
UNION ALL
SELECT 3, count(*) FROM events WHERE id > (SELECT max(id) - 1500 FROM events)
UNION ALL
SELECT 4, count(*) FROM events WHERE id > (SELECT max(id) - 2000 FROM events)
UNION ALL
SELECT 5, count(*) FROM events WHERE id > (SELECT max(id) - 2500 FROM events)
UNION ALL
SELECT 6, count(*) FROM events WHERE id > (SELECT max(id) - 3000 FROM events)
UNION ALL
SELECT 7, count(*) FROM events WHERE id > (SELECT max(id) - 3500 FROM events)
UNION ALL
SELECT 8, count(*) FROM events WHERE id > (SELECT max(id) - 4000 FROM events)
UNION ALL
SELECT 9, count(*) FROM events WHERE id > (SELECT max(id) - 4500 FROM events)
UNION ALL
SELECT 10, count(*) FROM events WHERE id > (SELECT max(id) - 5000 FROM events)
UNION ALL
SELECT 11, count(*) FROM events WHERE id > (SELECT max(id) - 5500 FROM events)
UNION ALL
SELECT 12, count(*) FROM events WHERE id > (SELECT max(id) - 6000 FROM events)
ORDER BY window_n;

SELECT count(*), avg(amt) FROM events;

SELECT count(*), sum(e.amt) FROM ord o JOIN events e ON e.id = o.id - 1 WHERE o.status = 'paid';

SELECT count(*) FROM ord o WHERE EXISTS (SELECT 1 FROM events e WHERE e.grp = o.k2);

SELECT count(*), sum(e.amt) FROM ord o JOIN events e ON e.id = o.id WHERE o.status = 'paid';

SELECT
    CASE
        WHEN grp < 100 THEN 'A'
        WHEN grp < 200 THEN 'B'
        WHEN grp < 300 THEN 'C'
        WHEN grp < 400 THEN 'D'
        ELSE 'E'
    END bucket,
    count(*),
    avg(amt),
    max(ts)
FROM events
GROUP BY bucket
ORDER BY bucket;

SELECT e.grp, count(*) AS n, sum(o.amt) AS revenue
FROM events e JOIN ord o ON o.id = e.id
GROUP BY e.grp ORDER BY e.grp;

SELECT count(*), sum(e.amt)
FROM ord o JOIN events e ON e.id = o.id
WHERE o.id < (SELECT min(o2.id) + 700000 FROM ord o2);

SELECT count(*), sum(e.amt)
FROM ord o JOIN events_h e ON e.id = o.id
WHERE o.id < (SELECT min(o2.id) + 700000 FROM ord o2);

SELECT count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 50000 FROM ord);

SELECT o.k2, count(*) AS n, sum(e.amt) AS revenue
FROM ord o JOIN events e ON e.id = o.id
GROUP BY o.k2;

SELECT (k1 % 500) AS bucket, count(*) AS n FROM ord GROUP BY 1;

SELECT k1, count(*) AS n FROM ord WHERE k1 BETWEEN 5000 AND 25000 GROUP BY k1 ORDER BY k1;
SELECT status, count(*) AS n, sum(amt) AS total FROM ord GROUP BY status ORDER BY status;

SELECT 1 AS window_n, count(*) AS cnt, sum(amt) AS total FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 2, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 3, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 4, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 5, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 6, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 7, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 8, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 9, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 10, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 11, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 12, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 13, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 14, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 15, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 16, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 17, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 18, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
UNION ALL
SELECT 19, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 1000 FROM ord)
UNION ALL
SELECT 20, count(*), sum(amt) FROM ord WHERE id > (SELECT max(id) - 2000 FROM ord)
ORDER BY window_n;

WITH grp_stats AS (
    SELECT
        grp,
        count(*) cnt,
        sum(amt) total_amt,
        avg(amt) avg_amt
    FROM events
    GROUP BY grp
)
SELECT
    count(*) AS groups,
    sum(cnt) AS rows,
    avg(avg_amt) AS overall_avg,
    max(total_amt) AS max_group_total
FROM grp_stats;

-- aggregate over aggregate
SELECT
    avg(cnt),
    max(total_amt),
    min(avg_amt)
FROM (
    SELECT
        grp,
        count(*) cnt,
        sum(amt) total_amt,
        avg(amt) avg_amt
    FROM events
    GROUP BY grp
) s;


SELECT
    status,
    count(*),
    sum(amt)
FROM ord
WHERE status IN ('paid','completed')
GROUP BY status;


(SELECT DISTINCT k1, k2 FROM ord WHERE k2 = 111 ORDER BY k1 LIMIT 100)
UNION ALL
(SELECT DISTINCT k1, k2 FROM ord WHERE k2 = 555 ORDER BY k1 LIMIT 100)
UNION ALL
(SELECT DISTINCT k1, k2 FROM ord WHERE k2 = 999 ORDER BY k1 LIMIT 100);


SELECT d.k1, d.k2, e.amt
FROM (SELECT DISTINCT k1, k2 FROM ord WHERE k2 = 333 ORDER BY k1 LIMIT 100) d
LEFT JOIN events e ON e.id = d.k1 * 10
UNION ALL
SELECT d.k1, d.k2, e.amt
FROM (SELECT DISTINCT k1, k2 FROM ord WHERE k2 = 777 ORDER BY k1 LIMIT 100) d
LEFT JOIN events e ON e.id = d.k1 * 10;

SELECT count(*), avg(amt) FROM events_h
WHERE ts > (SELECT max(ts) - interval '1 hour' FROM events_h);

SELECT 1 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '1 hours' FROM events_h)
UNION ALL
SELECT 2 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '2 hours' FROM events_h)
UNION ALL
SELECT 3 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '3 hours' FROM events_h)
UNION ALL
SELECT 4 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '4 hours' FROM events_h)
UNION ALL
SELECT 5 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '5 hours' FROM events_h)
UNION ALL
SELECT 6 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '6 hours' FROM events_h)
UNION ALL
SELECT 7 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '7 hours' FROM events_h)
UNION ALL
SELECT 8 AS hours_back, count(*) AS cnt, avg(amt) AS avg_amt FROM events_h WHERE ts > (SELECT max(ts) - interval '8 hours' FROM events_h)
ORDER BY hours_back;

SELECT count(*) FROM events_h WHERE id > (SELECT max(id) - 5000 FROM events_h);

SELECT e.grp, count(*) AS n, sum(o.amt) AS revenue
FROM events_h e JOIN ord o ON o.id = e.id
GROUP BY e.grp ORDER BY e.grp;

SELECT count(*), sum(amt), avg(amt)
FROM events_h
WHERE ts > (
    SELECT max(ts) - interval '15 minutes'
    FROM events
);

SELECT e.grp,
       count(*),
       sum(o.amt)
FROM (
    SELECT id, grp
    FROM events_h
    WHERE ts > (
        SELECT max(ts) - interval '6 hours'
        FROM events_h
    )
) e
JOIN ord o USING (id)
GROUP BY e.grp
ORDER BY e.grp;



WITH ids AS (
    SELECT DISTINCT grp
    FROM events_h
    WHERE ts > (
        SELECT max(ts) - interval '3 hours'
        FROM events_h
    )
)
SELECT
    ids.grp,
    (
        SELECT count(*)
        FROM events_h e
        WHERE e.grp = ids.grp
          AND e.ts > (
              SELECT max(ts) - interval '3 hours'
              FROM events_h
          )
    ) AS recent_cnt
FROM ids
ORDER BY recent_cnt DESC;


WITH recent AS (
    SELECT id, grp, ts, amt
    FROM events_h
    WHERE ts > (
        SELECT max(ts) - interval '48 hours'
        FROM events_h
    )
),
joined AS (
    SELECT DISTINCT
           r.id,
           r.grp,
           r.ts,
           r.amt,
           o.k1,
           o.k2
    FROM recent r
    JOIN ord o USING (id)
),
grp_stats AS (
    SELECT
        grp,
        k2,
        count(*) cnt,
        sum(amt) revenue,
        avg(amt) avg_amt
    FROM joined
    GROUP BY grp, k2
)
SELECT
    grp,
    k2,
    cnt,
    revenue,
    avg_amt,
    dense_rank() OVER (ORDER BY revenue DESC) rev_rank,
    percent_rank() OVER (ORDER BY revenue DESC) pct_rank,
    revenue / sum(revenue) OVER () AS revenue_share
FROM grp_stats
WHERE revenue >
(
    SELECT avg(revenue)
    FROM grp_stats
)
ORDER BY rev_rank
LIMIT 100;