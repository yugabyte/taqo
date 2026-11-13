SELECT c_grp FROM lmc_main WHERE c_int < 1000
INTERSECT
SELECT c_grp FROM lmc_small WHERE c_int < 500
ORDER BY 1;

SELECT c_grp FROM lmc_main WHERE c_int < 1000
INTERSECT ALL
SELECT c_grp FROM lmc_small
ORDER BY 1
LIMIT 30;

SELECT c_grp FROM lmc_main WHERE c_int < 3000
EXCEPT
SELECT c_grp FROM lmc_small WHERE c_int < 400
ORDER BY 1;

SELECT c_grp FROM lmc_main WHERE c_int < 300
EXCEPT ALL
SELECT c_grp FROM lmc_small WHERE c_int < 150
ORDER BY 1;

SELECT c_int FROM lmc_small WHERE c_int < 10
UNION DISTINCT
SELECT c_int FROM lmc_main WHERE c_int < 15
ORDER BY 1;

(SELECT c_int FROM lmc_small WHERE c_int < 50 EXCEPT SELECT c_int FROM lmc_main WHERE c_int % 2 = 0)
INTERSECT
(SELECT c_int FROM lmc_tree WHERE c_parent < 20 UNION ALL SELECT 1)
ORDER BY 1;

WITH a AS (SELECT c_grp, count(*) AS cnt FROM lmc_main GROUP BY c_grp),
     b AS (SELECT c_grp, max(c_int) AS mx FROM lmc_small GROUP BY c_grp),
     c AS (SELECT a.c_grp, a.cnt, b.mx FROM a JOIN b USING (c_grp))
SELECT *
FROM c
ORDER BY c_grp
LIMIT 20;

WITH m AS MATERIALIZED (SELECT c_int, c_grp FROM lmc_main WHERE c_bool)
SELECT m.c_grp, count(*)
FROM m
WHERE m.c_int < 5000
GROUP BY m.c_grp
ORDER BY 1;

WITH m AS NOT MATERIALIZED (SELECT c_int, c_grp, c_num FROM lmc_main)
SELECT m1.c_int, m2.c_num
FROM m m1
         JOIN m m2 ON m1.c_int = m2.c_int + 1
WHERE m1.c_int < 100
ORDER BY 1;

WITH time AS (SELECT c_int, c_ts FROM lmc_main WHERE c_int < 10)
SELECT *
FROM time
ORDER BY c_int;

WITH RECURSIVE walk(c_int, c_parent, depth) AS (
    SELECT c_int, c_parent, 0 FROM lmc_tree WHERE c_int = 777
    UNION ALL
    SELECT t.c_int, t.c_parent, w.depth + 1
    FROM lmc_tree t
             JOIN walk w ON t.c_int = w.c_parent
)
SELECT *
FROM walk
ORDER BY depth;

WITH RECURSIVE sub(c_int, c_parent) AS (
    SELECT c_int, c_parent FROM lmc_tree WHERE c_int = 3
    UNION ALL
    SELECT t.c_int, t.c_parent
    FROM lmc_tree t
             JOIN sub s ON t.c_parent = s.c_int
) SEARCH DEPTH FIRST BY c_int SET ordercol
SELECT c_int, c_parent
FROM sub
ORDER BY ordercol
LIMIT 40;

WITH RECURSIVE sub(c_int, c_parent) AS (
    SELECT c_int, c_parent FROM lmc_tree WHERE c_int = 3
    UNION ALL
    SELECT t.c_int, t.c_parent
    FROM lmc_tree t
             JOIN sub s ON t.c_parent = s.c_int
) SEARCH BREADTH FIRST BY c_int SET ordercol
SELECT c_int, c_parent
FROM sub
ORDER BY ordercol
LIMIT 40;

WITH RECURSIVE ring(n, nxt) AS (
    SELECT c_int, c_int % 10 + 1 FROM lmc_small WHERE c_int = 1
    UNION ALL
    SELECT r.nxt, r.nxt % 10 + 1 FROM ring r
) CYCLE n SET is_cycle USING path
SELECT n, is_cycle
FROM ring
ORDER BY n
LIMIT 20;

WITH RECURSIVE ring(n, nxt) AS (
    SELECT c_int, c_int % 5 + 1 FROM lmc_small WHERE c_int = 2
    UNION ALL
    SELECT r.nxt, r.nxt % 5 + 1 FROM ring r
) CYCLE n SET looped TO 'Y' DEFAULT 'N' USING trail
SELECT n, looped
FROM ring
ORDER BY n, looped
LIMIT 20;

WITH RECURSIVE up(c_int, lvl) AS (
    SELECT c_int, 1 FROM lmc_tree WHERE c_int = 999
    UNION
    SELECT t.c_parent, u.lvl + 1 FROM lmc_tree t JOIN up u ON t.c_int = u.c_int WHERE t.c_parent IS NOT NULL
)
SELECT max(lvl), min(c_int)
FROM up;
