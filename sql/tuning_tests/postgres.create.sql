CREATE TABLE t_range_100k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr100kv1 ON t_range_100k (v1);

CREATE TABLE t_range_200k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr200kv1 ON t_range_200k (v1);

CREATE TABLE t_range_300k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr300kv1 ON t_range_300k (v1);

CREATE TABLE t_range_400k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr400kv1 ON t_range_400k (v1);

CREATE TABLE t_range_500k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr500kv1 ON t_range_500k (v1);

CREATE TABLE t_range_600k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr600kv1 ON t_range_600k (v1);

CREATE TABLE t_range_700k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr700kv1 ON t_range_700k (v1);

CREATE TABLE t_range_800k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr800kv1 ON t_range_800k (v1);

CREATE TABLE t_range_900k (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr900kv1 ON t_range_900k (v1);

CREATE TABLE t_range_1m (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE INDEX tr1mv1 ON t_range_1m (v1);

CREATE TABLE t_range_100k_1update (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE TABLE t_range_100k_2update (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE TABLE t_range_100k_3update (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);
CREATE TABLE t_range_100k_4update (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT, v4 INT);

CREATE TABLE t_range_100k_1column (id INT PRIMARY KEY);
CREATE TABLE t_range_100k_2column (id INT PRIMARY KEY, v1 INT);
CREATE TABLE t_range_100k_3column (id INT PRIMARY KEY, v1 INT, v2 INT);
CREATE TABLE t_range_100k_4column (id INT PRIMARY KEY, v1 INT, v2 INT, v3 INT);

INSERT INTO t_range_100k (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
INSERT INTO t_range_200k (SELECT s, s, s, s, s FROM generate_series(1, 200000) s);
INSERT INTO t_range_300k (SELECT s, s, s, s, s FROM generate_series(1, 300000) s);
INSERT INTO t_range_400k (SELECT s, s, s, s, s FROM generate_series(1, 400000) s);
INSERT INTO t_range_500k (SELECT s, s, s, s, s FROM generate_series(1, 500000) s);
INSERT INTO t_range_600k (SELECT s, s, s, s, s FROM generate_series(1, 600000) s);
INSERT INTO t_range_700k (SELECT s, s, s, s, s FROM generate_series(1, 700000) s);
INSERT INTO t_range_800k (SELECT s, s, s, s, s FROM generate_series(1, 800000) s);
INSERT INTO t_range_900k (SELECT s, s, s, s, s FROM generate_series(1, 900000) s);
INSERT INTO t_range_1m (SELECT s, s, s, s, s FROM generate_series(1, 1000000) s);

INSERT INTO t_range_100k_1update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_1update SET v1 = v1 + 1;

INSERT INTO t_range_100k_2update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_2update SET v1 = v1 + 1;
UPDATE t_range_100k_2update SET v2 = v2 + 1;

INSERT INTO t_range_100k_3update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_3update SET v1 = v1 + 1;
UPDATE t_range_100k_3update SET v2 = v2 + 1;
UPDATE t_range_100k_3update SET v3 = v3 + 1;

INSERT INTO t_range_100k_4update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_4update SET v1 = v1 + 1;
UPDATE t_range_100k_4update SET v2 = v2 + 1;
UPDATE t_range_100k_4update SET v3 = v3 + 1;
UPDATE t_range_100k_4update SET v4 = v4 + 1;

INSERT INTO t_range_100k_1column (SELECT s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_2column (SELECT s, s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_3column (SELECT s, s, s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_4column (SELECT s, s, s, s FROM generate_series(1, 100000) s);
