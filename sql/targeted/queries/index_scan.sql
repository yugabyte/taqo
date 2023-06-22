-- 1. Should not try Index scan because of inequality on hash column
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 > 5000;

SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 > 5000 and
    id_asc_1 > 5000 and
    id_asc_2 > 5000 and
    id_asc_3 > 5000 and
    id_asc_4 > 5000;

-- 2. Equality filter on primary key
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_3 = 5000 and
    id_asc_4 = 5000;

-- 3. Equality and inequality filters on full primary key
-- 3.1. num_seeks = 1, num_nexts ~ 49999
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_3 = 5000 and
    id_asc_4 > 5000;

-- 3.2. Skip scan will be needed. num_seeks ~ 5000, num_nexts = 0
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_3 > 5000 and
    id_asc_4 = 5000;

-- 3.3. Multiple inequality columns. We seek to each matching value of id_asc_3
--      but the cost model assumes num_seeks = distinct_count(id_asc_3) / 2 ie
--      num_seeks ~ 5000
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_3 > 5000 and
    id_asc_4 > 5000;

-- 3.4. Same as above but seek for each matching value of id_asc_2 and id_asc_3.
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 > 5000 and
    id_asc_3 > 5000 and
    id_asc_4 > 5000;

-- 4. Eq and Ineq filters on part of primary index
-- num_seeks = 1
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000;

-- num_seeks = 1, but higher num_nexts as previous query
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 > 5000;

-- num_seeks = 1 but fewer num_nexts as both of previous queries
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_3 > 5000;

-- Skip scan filters
-- Filter missing on id_asc_3 => seeks for all values of id_asc_3
-- num_seeks ~ 10000
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_2 = 5000 and
    id_asc_4 = 5000;

-- num_seeks ~ 100000000
SELECT * FROM t_composite_pk_10k WHERE
    id_hash_1 = 5000 and
    id_asc_1 = 5000 and
    id_asc_4 > 5000;