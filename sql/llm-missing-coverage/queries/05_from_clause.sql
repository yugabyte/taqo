SELECT a.c_int, b.c_int
FROM lmc_small a
         CROSS JOIN lmc_tree b
WHERE a.c_int < 4
  AND b.c_int < 4
ORDER BY 1, 2;

SELECT *
FROM lmc_small
         NATURAL JOIN lmc_main
WHERE lmc_small.c_int < 20
ORDER BY c_int;

SELECT c_int, c_text, c_parent
FROM lmc_small
         NATURAL LEFT JOIN lmc_tree
WHERE c_int < 15
ORDER BY c_int;

SELECT c_int, c_text
FROM lmc_tree
         NATURAL FULL OUTER JOIN lmc_small
WHERE c_int BETWEEN 990 AND 1000
ORDER BY c_int;

SELECT c_int, s.c_text, m.c_num
FROM lmc_small s
         JOIN lmc_main m USING (c_int, c_grp)
WHERE c_int < 30
ORDER BY c_int;

SELECT j.c_int, s.c_grp
FROM lmc_small s
         LEFT JOIN lmc_main m USING (c_int) AS j
WHERE j.c_int < 10
ORDER BY 1;

SELECT x.a, x.b, x.c
FROM (lmc_small s JOIN lmc_tree t ON s.c_int = t.c_int) AS x(a, b, c)
WHERE x.a < 10
ORDER BY 1;

SELECT s.c_int, t.c_parent, m.c_num
FROM ((lmc_small s JOIN lmc_tree t ON s.c_int = t.c_int))
         LEFT JOIN lmc_main m ON m.c_int = s.c_int
WHERE s.c_int < 10
ORDER BY 1;

SELECT q.n, q.t
FROM (SELECT c_int, c_text FROM lmc_small WHERE c_int < 10) q(n, t)
ORDER BY q.n;

SELECT a.n, a.v
FROM lmc_small s,
     unnest(ARRAY [s.c_int, s.c_grp]) WITH ORDINALITY
AS a(v, n)
WHERE s.c_int < 5
ORDER BY s.c_int, a.n;

SELECT r.a, r.b, r.n
FROM ROWS FROM (generate_series(1, 4), unnest(ARRAY ['p', 'q', 'r'])) WITH ORDINALITY
AS r(a, b, n)
ORDER BY r.n;

SELECT r.x, r.y
FROM ROWS FROM (jsonb_to_recordset('[{"x":1,"y":"a"},{"x":2,"y":"b"}]') AS (x int, y text), generate_series(10, 11)) AS r(x, y, z)
ORDER BY r.x;

SELECT r.*
FROM ROWS FROM (generate_series(1, 3)) r
ORDER BY 1;

SELECT k, v
FROM jsonb_to_record('{"k": 5, "v": "five"}') AS (k int, v text);

SELECT rec.k, rec.v
FROM jsonb_to_record('{"k": 6, "v": "six"}') rec(k int, v text COLLATE "C");

SELECT rec.k
FROM json_to_recordset('[{"k":1},{"k":2}]') AS rec(k int)
ORDER BY 1;

SELECT m.c_int, l.mx
FROM lmc_small m
         CROSS JOIN LATERAL (SELECT max(c_int) AS mx FROM lmc_main x WHERE x.c_grp = m.c_grp AND x.c_int < 2000) l
WHERE m.c_int < 10
ORDER BY 1;

SELECT m.c_int, e.key, e.value
FROM lmc_main m,
     LATERAL jsonb_each_text(m.c_json) e
WHERE m.c_int < 4
ORDER BY 1, 2;

SELECT s.c_int, x.n
FROM lmc_small s
         LEFT JOIN LATERAL generate_series(1, s.c_int % 3) AS x(n) ON true
WHERE s.c_int < 6
ORDER BY 1, 2;
