-- Bugs identified
-- * [YSQL] BNLJ is slower when inner table is hash sharded, than when inner table is range sharded #17357
--   https://github.com/yugabyte/yugabyte-db/issues/17357

SELECT * FROM t_hash_pk_200k JOIN t_hash_pk_500k ON
    t_hash_pk_200k.id = t_hash_pk_500k.id;

SELECT * FROM t_range_pk_200k JOIN t_hash_pk_500k ON
    t_range_pk_200k.id = t_hash_pk_500k.id;

SELECT * FROM t_hash_pk_200k JOIN t_range_pk_500k ON
    t_hash_pk_200k.id = t_range_pk_500k.id;

SELECT * FROM t_range_pk_200k JOIN t_range_pk_500k ON
    t_range_pk_200k.id = t_range_pk_500k.id;
    

SELECT * FROM t_hash_pk_100k JOIN t_hash_pk_500k ON
    t_hash_pk_100k.id = t_hash_pk_500k.id;

SELECT * FROM t_range_pk_100k JOIN t_hash_pk_500k ON
    t_range_pk_100k.id = t_hash_pk_500k.id;

SELECT * FROM t_hash_pk_100k JOIN t_range_pk_500k ON
    t_hash_pk_100k.id = t_range_pk_500k.id;

SELECT * FROM t_range_pk_100k JOIN t_range_pk_500k ON
    t_range_pk_100k.id = t_range_pk_500k.id;


SELECT * FROM t_hash_pk_100k JOIN t_hash_pk_200k ON
    t_hash_pk_100k.id = t_hash_pk_200k.id;

SELECT * FROM t_range_pk_100k JOIN t_hash_pk_200k ON
    t_range_pk_100k.id = t_hash_pk_200k.id;

SELECT * FROM t_hash_pk_100k JOIN t_range_pk_200k ON
    t_hash_pk_100k.id = t_range_pk_200k.id;

SELECT * FROM t_range_pk_100k JOIN t_range_pk_200k ON
    t_range_pk_100k.id = t_range_pk_200k.id;


SELECT * FROM t_hash_pk_1k JOIN t_hash_pk_500k ON
    t_hash_pk_1k.id = t_hash_pk_500k.id;

SELECT * FROM t_range_pk_1k JOIN t_hash_pk_500k ON
    t_range_pk_1k.id = t_hash_pk_500k.id;

SELECT * FROM t_hash_pk_1k JOIN t_range_pk_500k ON
    t_hash_pk_1k.id = t_range_pk_500k.id;

SELECT * FROM t_range_pk_1k JOIN t_range_pk_500k ON
    t_range_pk_1k.id = t_range_pk_500k.id;