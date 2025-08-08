Tables can be range of hash or range sharded. Colocated tables can only have 
range primary keys.

CREATE TABLE t_hash (k1 INT, v1 INT, PRIMARY KEY (k1 HASH)) SPLIT INTO 10 TABLETS;
CREATE TABLE t_range (k1 INT, v1 INT, PRIMARY KEY (k1 ASC)) SPLIT AT VALUES (1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 7000000, 8000000, 9000000);
CREATE TABLE t_colocated (k1 INT, v1 INT, PRIMARY KEY (k1 ASC));

CREATE INDEX t_hash_index_hash on t_hash (v1 HASH);
CREATE INDEX t_range_index_hash on t_range (v1 HASH);
CREATE INDEX t_hash_index_range on t_hash (v1 ASC);
CREATE INDEX t_range_index_range on t_range (v1 ASC);
CREATE INDEX t_colocated_index on t_colocated (v1 ASC);

INSERT INTO t_hash (SELECT s, s FROM generate_series(1, 10000000) s);
INSERT INTO t_range (SELECT s, s FROM generate_series(1, 10000000) s);
INSERT INTO t_colocated (SELECT s, s FROM generate_series(1, 10000000) s);

SELECT * FROM t_hash WHERE k1 > 1234567;
-- should be seq scan, no index is useful
SELECT * FROM t_hash WHERE k1 IN (123456, 234567, 345678, 456789, 567890, 678901, 789012, 890123, 901234);
-- should be pkey index scan

SELECT * FROM t_hash WHERE v1 > 1234567;
-- should be t_hash_index_range index scan.

SELECT * FROM t_hash WHERE v1 IN (123456, 234567, 345678, 456789, 567890, 678901, 789012, 890123, 901234);
-- should be t_hash_index_hash index scan.