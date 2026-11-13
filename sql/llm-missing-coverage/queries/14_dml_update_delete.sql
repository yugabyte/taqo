-- tags: dml

UPDATE lmc_small
SET (c_grp, c_text) = (c_grp + 1, c_text || '!')
WHERE c_int < 5
RETURNING c_int, c_grp;

UPDATE lmc_small s
SET (c_grp, c_text) = (SELECT t.c_parent, t.c_text FROM lmc_tree t WHERE t.c_int = s.c_int)
WHERE s.c_int BETWEEN 5 AND 8
RETURNING s.c_int;

UPDATE lmc_tree
SET c_text = DEFAULT, c_parent = NULL
WHERE c_int < 4
RETURNING c_int, c_text;

UPDATE lmc_small AS s
SET c_grp = t.c_parent
FROM lmc_tree t
WHERE t.c_int = s.c_int AND s.c_int < 10
RETURNING s.c_int, t.c_parent;

UPDATE ONLY lmc_small
SET c_grp = c_grp * 2
WHERE c_int IN (SELECT c_int FROM lmc_tree WHERE c_parent = 3);

DELETE FROM lmc_small s
USING lmc_tree t
WHERE s.c_int = t.c_int AND t.c_parent = 5
RETURNING s.*;

DELETE FROM ONLY lmc_tree AS t
WHERE t.c_int > 990
RETURNING t.c_int;

WITH moved AS (
    DELETE FROM lmc_tree WHERE c_int BETWEEN 900 AND 905 RETURNING c_int, c_text
)
INSERT INTO lmc_small (c_int, c_grp, c_text)
SELECT c_int + 500000, 0, c_text FROM moved
RETURNING c_int;

WITH upd AS (
    UPDATE lmc_small SET c_grp = 0 WHERE c_int < 3 RETURNING c_int
)
SELECT count(*) FROM upd;

WITH RECURSIVE sub AS (
    SELECT c_int FROM lmc_tree WHERE c_int = 50
    UNION ALL
    SELECT t.c_int FROM lmc_tree t JOIN sub ON t.c_parent = sub.c_int
)
DELETE FROM lmc_tree WHERE c_int IN (SELECT c_int FROM sub);
