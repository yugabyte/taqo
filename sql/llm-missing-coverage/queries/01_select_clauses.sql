SELECT DISTINCT ON (c_grp) c_grp, c_int, c_text
FROM lmc_main
WHERE c_int < 3000
ORDER BY c_grp, c_int DESC;

SELECT DISTINCT ON (c_grp % 10, c_bool) c_grp % 10 AS g, c_bool, c_num
FROM lmc_main
ORDER BY c_grp % 10, c_bool, c_num DESC NULLS LAST;

SELECT ALL c_grp, c_int
FROM lmc_main
WHERE c_int < 50
ORDER BY c_int;

SELECT c_int, c_nullable
FROM lmc_main
WHERE c_int < 200
ORDER BY c_nullable NULLS FIRST, c_int
LIMIT 30;

SELECT c_int, c_nullable
FROM lmc_main
WHERE c_int < 200
ORDER BY c_nullable DESC NULLS LAST, c_int ASC NULLS FIRST
LIMIT 30;

SELECT c_int, c_grp
FROM lmc_main
WHERE c_int < 500
ORDER BY c_grp USING >, c_int USING <
LIMIT 20;

SELECT c_int, c_text
FROM lmc_main
WHERE c_int < 500
ORDER BY c_text USING ~<~ NULLS LAST
LIMIT 20;

SELECT c_int
FROM lmc_main
ORDER BY c_int
OFFSET 100 LIMIT 10;

SELECT c_int
FROM lmc_main
ORDER BY c_int
LIMIT ALL OFFSET 9990;

SELECT c_int, c_grp
FROM lmc_main
ORDER BY c_int
FETCH FIRST 5 ROWS ONLY;

SELECT c_int, c_grp
FROM lmc_main
ORDER BY c_int
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;

SELECT c_int, c_grp
FROM lmc_main
ORDER BY c_int
OFFSET 3 ROW FETCH NEXT ROW ONLY;

SELECT c_int, c_grp
FROM lmc_main
ORDER BY c_int
FETCH FIRST ROWS ONLY;

SELECT *
FROM (SELECT c_grp, c_int
      FROM lmc_main
      ORDER BY c_grp
      FETCH FIRST 3 ROWS WITH TIES) t
ORDER BY c_grp, c_int;

SELECT *
FROM (SELECT c_grp, c_int
      FROM lmc_main
      ORDER BY c_grp DESC
      FETCH NEXT ROW WITH TIES) t
ORDER BY c_grp, c_int;

SELECT c_grp, c_int
FROM lmc_main
ORDER BY c_grp, c_int
OFFSET 200 ROWS FETCH FIRST (2 + 3) ROWS ONLY;

SELECT c_int, c_text
FROM lmc_main
WHERE c_int <= 10
ORDER BY c_int
FOR READ ONLY;

((SELECT c_int, c_grp FROM lmc_main WHERE c_int < 20 ORDER BY c_int));

(((SELECT c_int FROM lmc_small ORDER BY c_int DESC LIMIT 5)));

TABLE lmc_small ORDER BY c_int LIMIT 10;

TABLE ONLY lmc_tree ORDER BY c_int DESC LIMIT 10;

SELECT *
FROM lmc_small *
WHERE c_int < 10
ORDER BY c_int;

SELECT s.*
FROM ONLY lmc_small s
WHERE s.c_int BETWEEN 10 AND 20
ORDER BY 1;

VALUES (1, 'one'), (2, 'two'), (3, 'three')
ORDER BY 1 DESC
LIMIT 2;

SELECT v.a, v.b, s.c_text
FROM (VALUES (1, 'x'), (2, 'y'), (3, 'z')) AS v(a, b)
         JOIN lmc_small s ON s.c_int = v.a
ORDER BY v.a;

SELECT (SELECT c_arr FROM lmc_main WHERE c_int = 7)[2] AS second_elem,
       (SELECT c_json FROM lmc_main WHERE c_int = 7) -> 'name' AS name_elem;

SELECT (SELECT ARRAY [c_int, c_grp] FROM lmc_small WHERE c_int = 42)[1:2] AS pair;
