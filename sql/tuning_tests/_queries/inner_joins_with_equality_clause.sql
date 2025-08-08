-- Bugs identified
-- * [YSQL] BNLJ is slower when inner table is hash sharded, than when inner table is range sharded #17357
--   https://github.com/yugabyte/yugabyte-db/issues/17357

SELECT * FROM t_hash_20k JOIN t_hash_50k ON
    t_hash_20k.id = t_hash_50k.id;

SELECT * FROM t_range_20k JOIN t_hash_50k ON
    t_range_20k.id = t_hash_50k.id;

SELECT * FROM t_hash_20k JOIN t_range_50k ON
    t_hash_20k.id = t_range_50k.id;

SELECT * FROM t_range_20k JOIN t_range_50k ON
    t_range_20k.id = t_range_50k.id;
    

SELECT * FROM t_hash_10k JOIN t_hash_50k ON
    t_hash_10k.id = t_hash_50k.id;

SELECT * FROM t_range_10k JOIN t_hash_50k ON
    t_range_10k.id = t_hash_50k.id;

SELECT * FROM t_hash_10k JOIN t_range_50k ON
    t_hash_10k.id = t_range_50k.id;

SELECT * FROM t_range_10k JOIN t_range_50k ON
    t_range_10k.id = t_range_50k.id;


SELECT * FROM t_hash_10k JOIN t_hash_20k ON
    t_hash_10k.id = t_hash_20k.id;

SELECT * FROM t_range_10k JOIN t_hash_20k ON
    t_range_10k.id = t_hash_20k.id;

SELECT * FROM t_hash_10k JOIN t_range_20k ON
    t_hash_10k.id = t_range_20k.id;

SELECT * FROM t_range_10k JOIN t_range_20k ON
    t_range_10k.id = t_range_20k.id;


SELECT * FROM t_hash_1k JOIN t_hash_50k ON
    t_hash_1k.id = t_hash_50k.id;

SELECT * FROM t_range_1k JOIN t_hash_50k ON
    t_range_1k.id = t_hash_50k.id;

SELECT * FROM t_hash_1k JOIN t_range_50k ON
    t_hash_1k.id = t_range_50k.id;

SELECT * FROM t_range_1k JOIN t_range_50k ON
    t_range_1k.id = t_range_50k.id;