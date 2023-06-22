-- Bugs identified
-- * [YSQL] BNLJ is slower when inner table is hash sharded, than when inner table is range sharded #17357
--   https://github.com/yugabyte/yugabyte-db/issues/17357

SELECT * FROM t_hash_pk_20k JOIN t_hash_pk_50k ON
    t_hash_pk_20k.id = t_hash_pk_50k.id;

SELECT * FROM t_range_pk_20k JOIN t_hash_pk_50k ON
    t_range_pk_20k.id = t_hash_pk_50k.id;

SELECT * FROM t_hash_pk_20k JOIN t_range_pk_50k ON
    t_hash_pk_20k.id = t_range_pk_50k.id;

SELECT * FROM t_range_pk_20k JOIN t_range_pk_50k ON
    t_range_pk_20k.id = t_range_pk_50k.id;
    

SELECT * FROM t_hash_pk_10k JOIN t_hash_pk_50k ON
    t_hash_pk_10k.id = t_hash_pk_50k.id;

SELECT * FROM t_range_pk_10k JOIN t_hash_pk_50k ON
    t_range_pk_10k.id = t_hash_pk_50k.id;

SELECT * FROM t_hash_pk_10k JOIN t_range_pk_50k ON
    t_hash_pk_10k.id = t_range_pk_50k.id;

SELECT * FROM t_range_pk_10k JOIN t_range_pk_50k ON
    t_range_pk_10k.id = t_range_pk_50k.id;


SELECT * FROM t_hash_pk_10k JOIN t_hash_pk_20k ON
    t_hash_pk_10k.id = t_hash_pk_20k.id;

SELECT * FROM t_range_pk_10k JOIN t_hash_pk_20k ON
    t_range_pk_10k.id = t_hash_pk_20k.id;

SELECT * FROM t_hash_pk_10k JOIN t_range_pk_20k ON
    t_hash_pk_10k.id = t_range_pk_20k.id;

SELECT * FROM t_range_pk_10k JOIN t_range_pk_20k ON
    t_range_pk_10k.id = t_range_pk_20k.id;


SELECT * FROM t_hash_pk_1k JOIN t_hash_pk_50k ON
    t_hash_pk_1k.id = t_hash_pk_50k.id;

SELECT * FROM t_range_pk_1k JOIN t_hash_pk_50k ON
    t_range_pk_1k.id = t_hash_pk_50k.id;

SELECT * FROM t_hash_pk_1k JOIN t_range_pk_50k ON
    t_hash_pk_1k.id = t_range_pk_50k.id;

SELECT * FROM t_range_pk_1k JOIN t_range_pk_50k ON
    t_range_pk_1k.id = t_range_pk_50k.id;