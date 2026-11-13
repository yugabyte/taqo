SELECT c_int, c_text
FROM lmc_small
WHERE c_int < 5
ORDER BY c_int
FOR UPDATE;

SELECT c_int, c_text
FROM lmc_small
WHERE c_int BETWEEN 5 AND 9
ORDER BY c_int
FOR NO KEY UPDATE NOWAIT;

SELECT c_int
FROM lmc_small
WHERE c_int BETWEEN 10 AND 14
ORDER BY c_int
FOR SHARE SKIP LOCKED;

SELECT c_int
FROM lmc_small
WHERE c_int BETWEEN 15 AND 19
ORDER BY c_int
FOR KEY SHARE;

SELECT s.c_int, t.c_parent
FROM lmc_small s
         JOIN lmc_tree t ON s.c_int = t.c_int
WHERE s.c_int < 6
ORDER BY 1
FOR UPDATE OF s FOR SHARE OF t SKIP LOCKED;

SELECT c_int
FROM lmc_small
WHERE c_int < 4
ORDER BY c_int
LIMIT 3
FOR UPDATE;

SELECT c_int
FROM lmc_small
WHERE c_int < 4
ORDER BY c_int
FOR SHARE OF lmc_small NOWAIT
LIMIT 2;

WITH w AS (SELECT c_int FROM lmc_tree WHERE c_int < 5)
SELECT s.c_int
FROM lmc_small s
         JOIN w USING (c_int)
ORDER BY 1
FOR UPDATE OF s;

WITH w AS (SELECT c_int FROM lmc_tree WHERE c_int < 5)
SELECT c_int
FROM lmc_small
WHERE c_int IN (SELECT c_int FROM w)
ORDER BY 1
LIMIT 3
FOR KEY SHARE OF lmc_small;
