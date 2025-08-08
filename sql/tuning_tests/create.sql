CREATE TABLE t_range_100k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr100kv1 ON t_range_100k (v1 ASC);
INSERT INTO t_range_100k (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);

CREATE TABLE t_range_200k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr200kv1 ON t_range_200k (v1 ASC);
INSERT INTO t_range_200k (SELECT s, s, s, s, s FROM generate_series(1, 200000) s);

CREATE TABLE t_range_300k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr300kv1 ON t_range_300k (v1 ASC);
INSERT INTO t_range_300k (SELECT s, s, s, s, s FROM generate_series(1, 300000) s);

CREATE TABLE t_range_400k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr400kv1 ON t_range_400k (v1 ASC);
INSERT INTO t_range_400k (SELECT s, s, s, s, s FROM generate_series(1, 400000) s);

CREATE TABLE t_range_500k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr500kv1 ON t_range_500k (v1 ASC);
INSERT INTO t_range_500k (SELECT s, s, s, s, s FROM generate_series(1, 500000) s);

CREATE TABLE t_range_600k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr600kv1 ON t_range_600k (v1 ASC);
INSERT INTO t_range_600k (SELECT s, s, s, s, s FROM generate_series(1, 600000) s);

CREATE TABLE t_range_700k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr700kv1 ON t_range_700k (v1 ASC);
INSERT INTO t_range_700k (SELECT s, s, s, s, s FROM generate_series(1, 700000) s);

CREATE TABLE t_range_800k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr800kv1 ON t_range_800k (v1 ASC);
INSERT INTO t_range_800k (SELECT s, s, s, s, s FROM generate_series(1, 800000) s);

CREATE TABLE t_range_900k (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr900kv1 ON t_range_900k (v1 ASC);
INSERT INTO t_range_900k (SELECT s, s, s, s, s FROM generate_series(1, 900000) s);

CREATE TABLE t_range_1m (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
CREATE INDEX tr1mv1 ON t_range_1m (v1 ASC);
INSERT INTO t_range_1m (SELECT s, s, s, s, s FROM generate_series(1, 1000000) s);

CREATE TABLE t_range_100k_1update (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_1update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_1update SET v1 = v1 + 1;

CREATE TABLE t_range_100k_2update (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_2update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_2update SET v1 = v1 + 1;
UPDATE t_range_100k_2update SET v2 = v2 + 1;

CREATE TABLE t_range_100k_3update (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_3update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_3update SET v1 = v1 + 1;
UPDATE t_range_100k_3update SET v2 = v2 + 1;
UPDATE t_range_100k_3update SET v3 = v3 + 1;

CREATE TABLE t_range_100k_4update (id INT, v1 INT, v2 INT, v3 INT, v4 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_4update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_4update SET v1 = v1 + 1;
UPDATE t_range_100k_4update SET v2 = v2 + 1;
UPDATE t_range_100k_4update SET v3 = v3 + 1;
UPDATE t_range_100k_4update SET v4 = v4 + 1;

CREATE TABLE t_range_100k_1column (id INT PRIMARY KEY);
INSERT INTO t_range_100k_1column (SELECT s FROM generate_series(1, 100000) s);

CREATE TABLE t_range_100k_2column (id INT, v1 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_2column (SELECT s, s FROM generate_series(1, 100000) s);

CREATE TABLE t_range_100k_3column (id INT, v1 INT, v2 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_3column (SELECT s, s, s FROM generate_series(1, 100000) s);

CREATE TABLE t_range_100k_4column (id INT, v1 INT, v2 INT, v3 INT, PRIMARY KEY (id ASC));
INSERT INTO t_range_100k_4column (SELECT s, s, s, s FROM generate_series(1, 100000) s);

CREATE TABLE t_range_1m_4keys (k1 INT, k2 INT, k3 INT, k4 INT, v1 INT, PRIMARY KEY (k1 ASC, k2 ASC, k3 ASC, k4 ASC));
INSERT INTO t_range_1m_4keys (SELECT s1, s2, s3, s4 FROM generate_series(1, 10) s1, generate_series(1, 20) s2, generate_series(1, 50) s3, generate_series(1, 100) s4);

CREATE TABLE t_int_100k (v1 int, v2 int, v3 int, v4 int, v5 int, v6 int, v7 int, v8 int);
INSERT INTO t_int_100k SELECT s, s/2, s/4, s/8, s/8, s/4, s/2, s FROM generate_series(1, 100000) s;

CREATE TABLE t_numeric_100k (v1 numeric(12,6), v2 numeric(12,6), v3 numeric(12,6), v4 numeric(12,6), v5 numeric(12,6), v6 numeric(12,6), v7 numeric(12,6), v8 numeric(12,6));
INSERT INTO t_numeric_100k SELECT s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric), s+(s/1000000::numeric) FROM generate_series(100000, 200000) s;

CREATE TABLE t_real_100k (v1 real, v2 real, v3 real, v4 real, v5 real, v6 real, v7 real, v8 real);
INSERT INTO t_real_100k SELECT s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real), s+(s/1000000::real) FROM generate_series(100000, 200000) s;

CREATE TABLE t_char4_100k (v1 char(4), v2 char(4), v3 char(4), v4 char(4), v5 char(4), v6 char(4), v7 char(4), v8 char(4));
INSERT INTO t_char4_100k SELECT left(md5((s)::text), 4), left(md5((s/2)::text), 4), left(md5((s/4)::text), 4), left(md5((s/8)::text), 4), left(md5((s/8)::text), 4), left(md5((s/4)::text), 4), left(md5((s/2)::text), 4), left(md5((s)::text), 4) FROM generate_series(1, 100000) s;

CREATE TABLE t_char8_100k (v1 char(8), v2 char(8), v3 char(8), v4 char(8), v5 char(8), v6 char(8), v7 char(8), v8 char(8));
INSERT INTO t_char8_100k SELECT left(md5((s)::text), 8), left(md5((s/2)::text), 8), left(md5((s/4)::text), 8), left(md5((s/8)::text), 8), left(md5((s/8)::text), 8), left(md5((s/4)::text), 8), left(md5((s/2)::text), 8), left(md5((s)::text), 8) FROM generate_series(1, 100000) s;

CREATE TABLE t_char16_100k (v1 char(16), v2 char(16), v3 char(16), v4 char(16), v5 char(16), v6 char(16), v7 char(16), v8 char(16));
INSERT INTO t_char16_100k SELECT left(md5((s)::text), 16), left(md5((s/2)::text), 16), left(md5((s/4)::text), 16), left(md5((s/8)::text), 16), left(md5((s/8)::text), 16), left(md5((s/4)::text), 16), left(md5((s/2)::text), 16), left(md5((s)::text), 16) FROM generate_series(1, 100000) s;