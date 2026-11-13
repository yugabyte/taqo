SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN c_grp * 2 AND 400;

SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN c_grp % 7 AND c_grp + 50;

SELECT count(*)
FROM lmc_main
WHERE c_float BETWEEN 2 ^ 3 AND 2 ^ 6;

SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN -c_grp AND +c_grp;

SELECT count(*)
FROM lmc_main
WHERE c_int BETWEEN +5 AND 50;

SELECT count(*)
FROM lmc_main
WHERE c_num BETWEEN c_int::numeric AND c_int::numeric * 2;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_int < 500 AND true;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_int > 9000 AND true
  AND c_bool BETWEEN c_grp = 7 AND true;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_grp <= 3 AND true
  AND c_bool BETWEEN c_grp >= 1 AND true;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_grp <> 3 AND true;

SELECT count(*)
FROM lmc_small
WHERE c_text BETWEEN c_text || '' AND 'zzz';

SELECT count(*)
FROM lmc_main
WHERE c_float BETWEEN |/ c_float AND @ -c_float;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_nullable IS DISTINCT FROM 5 AND true;

SELECT count(*)
FROM lmc_main
WHERE c_bool BETWEEN c_nullable IS NOT DISTINCT FROM c_grp AND true;

SELECT c_int / 3 * 3 % 5 + (2 ^ 2)::int - 1 AS arith,
       +c_int AS pos,
       -c_num AS neg,
       c_float ^ 0.5 AS root,
       c_int << 2 AS shl,
       c_int & 7 AS band,
       c_int | 8 AS bor,
       ~c_int AS bnot,
       c_float * 2 / 3 AS ratio
FROM lmc_main
WHERE c_int < 10
ORDER BY c_int;
