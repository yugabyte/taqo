-- tags: dml

INSERT INTO lmc_small AS s (c_int, c_grp, c_text)
VALUES (100001, 1, 'ins-a'), (100002, DEFAULT, 'ins-b')
RETURNING s.c_int, s.c_text;

INSERT INTO lmc_tree DEFAULT VALUES
RETURNING c_text;

INSERT INTO lmc_tree (c_int, c_parent, c_text) OVERRIDING SYSTEM VALUE
VALUES (2000001, 1, 'osv')
RETURNING *;

INSERT INTO lmc_tree (c_parent, c_text) OVERRIDING USER VALUE
SELECT c_int, 'ouv' FROM lmc_small WHERE c_int < 3
RETURNING c_parent;

INSERT INTO lmc_small (c_int, c_grp, c_text)
SELECT c_int + 200000, c_grp, c_text || '-copy'
FROM lmc_small
WHERE c_int < 5
RETURNING c_int;

INSERT INTO lmc_small AS s (c_int, c_grp, c_text)
VALUES (1, 7, 'upd-1')
ON CONFLICT (c_int) DO UPDATE SET c_grp = EXCLUDED.c_grp, c_text = s.c_text || '+'
WHERE s.c_grp IS DISTINCT FROM EXCLUDED.c_grp
RETURNING s.c_int, s.c_grp;

INSERT INTO lmc_small (c_int, c_grp, c_text)
VALUES (2, 7, 'skip-2')
ON CONFLICT DO NOTHING
RETURNING c_int;

INSERT INTO lmc_small (c_int, c_grp, c_text)
VALUES (3, 7, 'oc-3')
ON CONFLICT ON CONSTRAINT lmc_small_pkey DO NOTHING;

INSERT INTO lmc_small (c_int, c_grp, c_text)
VALUES (300001, 7, 'c_text_1')
ON CONFLICT (c_text) WHERE c_grp > 0 DO NOTHING;

INSERT INTO lmc_small (c_int, c_grp, c_text)
VALUES (4, 7, 'rowset')
ON CONFLICT (c_int) DO UPDATE SET (c_grp, c_text) = (EXCLUDED.c_grp, EXCLUDED.c_text)
RETURNING c_int, c_text;

WITH src AS (SELECT c_int + 400000 AS k, c_grp FROM lmc_small WHERE c_int < 4)
INSERT INTO lmc_small (c_int, c_grp, c_text)
SELECT k, c_grp, 'cte-' || k FROM src
RETURNING c_int;
