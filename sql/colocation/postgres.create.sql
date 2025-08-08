CREATE TABLE t_10M_colocated(k1 INT, v1 INT, PRIMARY KEY (k1 ASC));
CREATE INDEX t_10M_colocated_index ON t_10M_colocated (v1 ASC);
INSERT INTO t_10M_colocated (SELECT s, s FROM generate_series(1, 10000000));

CREATE TABLE t_10M_hash(k1 INT, v1 INT, PRIMARY KEY (k1 ASCS));
CREATE INDEX t_10M_hash_index ON t_10M_hash (v1 ASC);
INSERT INTO t_10M_hash (SELECT s, s FROM generate_series(1, 10000000));

CREATE TABLE t_10M_asc(k1 INT, v1 INT, PRIMARY KEY (k1 ASC));
CREATE INDEX t_10M_asc_index ON t_10M_asc (v1 ASC);
INSERT INTO t_10M_asc (SELECT s, s FROM generate_series(1, 10000000));
