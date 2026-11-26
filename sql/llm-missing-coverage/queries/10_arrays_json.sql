SELECT ARRAY [[1, 2], [3, 4]] AS nested,
       ARRAY [ARRAY [c_int, c_grp], ARRAY [c_grp, c_int]] AS nested2,
       ARRAY []::int[] AS empty_arr,
       ARRAY [[], []]::int[][] AS empty_nested,
       ARRAY(SELECT c_int FROM lmc_small WHERE c_int < 4 ORDER BY 1) AS sub_arr
FROM lmc_main
WHERE c_int = 5;

SELECT c_arr[1] AS a1,
       c_arr[2:3] AS a23,
       c_arr[:2] AS a_head,
       c_arr[2:] AS a_tail,
       c_arr[:] AS a_all,
       (ARRAY [[1, 2], [3, 4]])[2][1] AS two_d,
       (ARRAY [[1, 2], [3, 4]])[1:2][2] AS two_d_slice,
       (c_json -> 'tags') -> 0 AS j0,
       c_json['name'] AS jsub,
       c_json['tags'][1] AS jsub2
FROM lmc_main
WHERE c_int < 5
ORDER BY c_int;

SELECT c_int
FROM lmc_main
WHERE c_arr @> ARRAY [1]
  AND c_arr && ARRAY [2, 3]
  AND 1 = ANY (c_arr)
ORDER BY c_int
LIMIT 20;

SELECT c_int,
       c_json ->> 'name' AS name,
       c_json #> '{tags,1}' AS tag1,
       c_json #>> '{tags,0}' AS tag0,
       c_json ? 'k' AS has_k,
       c_json ?| ARRAY ['k', 'zz'] AS has_any,
       c_json ?& ARRAY ['k', 'name'] AS has_all,
       c_json @> '{"k": 3}' AS contains_k3,
       c_json - 'tags' AS without_tags,
       c_json || '{"extra": true}' AS with_extra,
       jsonb_path_exists(c_json, '$.tags[*] ? (@ > 1)') AS path_ok
FROM lmc_main
WHERE c_int < 6
ORDER BY c_int;

SELECT c_json -> 'k' AS k, count(*)
FROM lmc_main
WHERE c_json @? '$.tags[*] ? (@ == 2)'
GROUP BY c_json -> 'k'
ORDER BY 1;

SELECT (c_arr)[1] + (c_arr)[2] AS s,
       array_length(c_arr, 1) AS len,
       cardinality(c_arr) AS card,
       array_position(c_arr, c_int % 13) AS pos,
       unnest(c_arr) AS u
FROM lmc_main
WHERE c_int < 3
ORDER BY c_int, u;

SELECT (ROW (c_int, c_text)::record) IS NOT NULL AS r_nn,
       ROW () IS NULL AS empty_row,
       (lmc_small.*) IS NOT NULL AS whole_row,
       (s2).c_text AS field_of_row
FROM lmc_small,
     LATERAL (SELECT s1 FROM lmc_small s1 WHERE s1.c_int = lmc_small.c_int + 1) AS l(s2)
WHERE lmc_small.c_int < 4
ORDER BY lmc_small.c_int;
