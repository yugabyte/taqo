CREATE TABLE t_range_pk_100k as SELECT
    s id,
    s v1,
    s v2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_range_pk_100k ADD PRIMARY KEY (id);
CREATE INDEX tr100kv1 ON t_range_pk_100k (v1 ASC);

CREATE VIEW t_hash_pk_100k AS SELECT * FROM t_range_pk_100k;

CREATE TABLE t_range_wide_pk_100k as SELECT
    s id,
    s v1,
    s v2,
    md5(random()::text) s1,
    md5(random()::text) || md5(random()::text) || md5(random()::text) || md5(random()::text) s2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_range_wide_pk_100k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_wide_pk_100k AS SELECT * FROM t_range_wide_pk_100k;

CREATE TABLE t_range_pk_50k as SELECT
    s*2 id,
    s*2 v1,
    s*2 v2
    FROM generate_series(1, 50000) s;
ALTER TABLE t_range_pk_50k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_50k AS SELECT * FROM t_range_pk_50k;

CREATE TABLE t_range_pk_20k as SELECT
    s*5 id,
    s*5 v1,
    s*5 v2
    FROM generate_series(1, 20000) s;
ALTER TABLE t_range_pk_20k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_20k AS SELECT * FROM t_range_pk_20k;

CREATE TABLE t_range_pk_10k as SELECT
    s*10 id,
    s*10 v1,
    s*10 v2
    FROM generate_series(1, 10000) s;
ALTER TABLE t_range_pk_10k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_10k AS SELECT * FROM t_range_pk_10k;

CREATE TABLE t_range_pk_1k as SELECT
    s*1000 id,
    s*1000 v1,
    s*1000 v2
    FROM generate_series(1, 1000) s;
ALTER TABLE t_range_pk_1k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_1k AS SELECT * FROM t_range_pk_1k;
