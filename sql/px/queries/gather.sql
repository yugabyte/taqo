set statement_timeout="240s";

SELECT
    *
FROM events
ORDER BY ts DESC;

SELECT
    status,
    sum(amt)
FROM ord
WHERE status='paid'
GROUP BY status;

SELECT
    grp,
    ts,
    amt,
    row_number() OVER (
        PARTITION BY grp
        ORDER BY ts DESC
    ) AS rn
FROM events
WHERE grp BETWEEN 100 AND 700
ORDER BY grp, ts DESC;


WITH seg_revenue AS (
    SELECT o.k2, count(*) AS n, sum(e.amt) AS revenue
    FROM ord o JOIN events e ON e.id = o.id
    GROUP BY o.k2
)
SELECT k2, n, revenue,
       dense_rank() OVER (ORDER BY revenue DESC) AS rnk,
       round(100.0 * revenue / sum(revenue) OVER (), 2) AS pct
FROM seg_revenue
WHERE n > (SELECT avg(n) FROM seg_revenue)
ORDER BY rnk LIMIT 20;

SELECT count(*) FROM ord WHERE k1 < 200 OR ts > timestamptz '2026-06-30 20:00:00';
SELECT id, k1, amt FROM ord WHERE (k1 < 150 OR k1 > 29850) AND status = 'paid';
SELECT count(*) FROM ord WHERE k1 < 300 OR k1 > 29700;

SELECT 'edge' AS metric, count(*) FROM ord WHERE k1 < 300 OR k1 > 29700
UNION ALL
SELECT 'recent', count(*) FROM ord WHERE id > (SELECT max(id) - 50000 FROM ord);

SELECT 'edge_or_stale' AS metric, count(*) FROM ord WHERE k1 < 200 OR ts > timestamptz '2026-06-30 20:00:00'
UNION ALL
SELECT 'recent_ord', count(*) FROM ord WHERE id > (SELECT max(id) - 30000 FROM ord)
UNION ALL
SELECT 'recent_events', count(*) FROM events WHERE id > (SELECT max(id) - 3000 FROM events);

SELECT 'edge_or_stale' AS metric, count(*) FROM ord WHERE k1 < 200 OR ts > timestamptz '2026-06-30 20:00:00'
UNION ALL
SELECT 'recent_ord', count(*) FROM ord WHERE id > (SELECT max(id) - 30000 FROM ord)
UNION ALL
SELECT 'recent_events', count(*) FROM events_h WHERE id > (SELECT max(id) - 3000 FROM events_h);


SELECT count(*), sum(amt) FROM ord
WHERE id > (SELECT max(id) - 50000 FROM ord)
  AND amt > (SELECT avg(amt) FROM ord WHERE k1 < 100 OR k1 > 29900);


WITH edge_keys AS MATERIALIZED (
    SELECT id FROM ord WHERE k1 < 150 OR k1 > 29850
)
SELECT (SELECT count(*) FROM edge_keys) AS edge_ids,
       count(*) AS paid_orders, sum(amt) AS paid_total
FROM ord WHERE status = 'paid';


SELECT 'paid_vs_events' AS metric, count(*), sum(e.amt) FROM ord o JOIN events e ON e.id = o.id WHERE o.status = 'paid'
UNION ALL
SELECT 'edge_slice', count(*), sum(amt) FROM ord WHERE (k1 < 250 OR k1 > 29750) AND status = 'paid';

SELECT src, id, amt, rank() OVER (ORDER BY amt DESC) AS overall_rank FROM (
  (SELECT 'big_paid' AS src, id, amt FROM ord WHERE status = 'paid' AND k2 < 15 ORDER BY amt DESC LIMIT 300)
  UNION ALL
  (SELECT 'big_any', id, amt FROM ord WHERE k2 < 15 ORDER BY amt DESC LIMIT 300)
) u;

(SELECT 'largest' AS bucket, id, amt FROM ord WHERE k2 = 500 ORDER BY amt DESC LIMIT 100)
UNION ALL
(SELECT 'latest', id, amt FROM ord WHERE k2 = 500 ORDER BY id LIMIT 100);


SELECT src, id, amt, dense_rank() OVER (ORDER BY amt DESC) AS overall_rank FROM (
  (SELECT 'flagged' AS src, o.id, o.amt FROM ord o
    WHERE o.k2 = 250 AND EXISTS (SELECT 1 FROM events e WHERE e.grp = o.k1 % 97)
    ORDER BY o.id LIMIT 150)
  UNION ALL
  (SELECT 'biggest', id, amt FROM ord WHERE k2 = 750 ORDER BY amt DESC LIMIT 150)
) u;


SELECT
    count(*) FILTER (WHERE status='paid') paid,
    count(*) FILTER (WHERE status='cancelled') cancelled,
    count(*) FILTER (WHERE status='completed') completed,
    sum(amt) FILTER (WHERE k2 < 200),
    sum(amt) FILTER (WHERE k2 BETWEEN 200 AND 600),
    avg(amt) FILTER (WHERE k2 > 600),
    max(amt),
    min(amt)
FROM ord;

SELECT
    count(*),
    sum(amt),
    (
        SELECT avg(amt)
        FROM ord
    ) global_avg,
    (
        SELECT stddev(amt)
        FROM ord
    ) global_stddev,
    (
        SELECT sum(amt)
        FROM events
    ) total_event_amt
FROM ord
WHERE status='paid';


WITH j AS (
    SELECT
        o.k2,
        e.grp,
        e.amt
    FROM ord o
    JOIN events e
      ON o.id=e.id
)
SELECT
    grp,
    count(*),
    sum(amt),
    avg(amt),
    rank() OVER (ORDER BY sum(amt) DESC)
FROM j
GROUP BY grp;

WITH base AS (
    SELECT *
    FROM events
),
agg AS (
    SELECT
        grp,
        count(*) cnt,
        sum(amt) total
    FROM base
    GROUP BY grp
)
SELECT *,
       rank() OVER (ORDER BY total DESC)
FROM agg
ORDER BY total DESC;


SELECT DISTINCT ON (grp) grp, ts FROM events_h ORDER BY grp, ts DESC LIMIT 5;
SELECT DISTINCT ON (grp) grp, ts FROM events_h ORDER BY grp, ts DESC LIMIT 20;

(SELECT DISTINCT ON (grp) grp, ts FROM events_h WHERE grp < 30 ORDER BY grp, ts DESC LIMIT 5)
UNION ALL
(SELECT DISTINCT ON (grp) grp, ts FROM events_h WHERE grp >= 30 AND grp < 60 ORDER BY grp, ts DESC LIMIT 5)
UNION ALL
(SELECT DISTINCT ON (grp) grp, ts FROM events_h WHERE grp >= 60 ORDER BY grp, ts DESC LIMIT 5);

SELECT 1 AS w, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '30 minutes' FROM events_h)
UNION ALL
SELECT 2, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '60 minutes' FROM events_h)
UNION ALL
SELECT 3, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '90 minutes' FROM events_h)
UNION ALL
SELECT 4, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '120 minutes' FROM events_h)
UNION ALL
SELECT 5, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '150 minutes' FROM events_h)
UNION ALL
SELECT 6, count(*) FROM events_h WHERE ts > (SELECT max(ts) - interval '180 minutes' FROM events_h)
ORDER BY w;


WITH seg_revenue AS (
    SELECT o.k2, count(*) AS n, sum(e.amt) AS revenue
    FROM ord o JOIN events_h e ON e.id = o.id
    GROUP BY o.k2
)
SELECT k2, n, revenue,
       dense_rank() OVER (ORDER BY revenue DESC) AS rnk,
       round(100.0 * revenue / sum(revenue) OVER (), 2) AS pct
FROM seg_revenue
WHERE n > (SELECT avg(n) FROM seg_revenue)
ORDER BY rnk LIMIT 20;


WITH j AS (
    SELECT
        o.k2,
        e.grp,
        e.amt
    FROM ord o
    JOIN events_h e
      ON o.id=e.id
)
SELECT
    grp,
    count(*),
    sum(amt),
    avg(amt),
    rank() OVER (ORDER BY sum(amt) DESC)
FROM j
GROUP BY grp;


