CREATE TABLE t_range_pk_1M as SELECT
    s id,
    s v1,
    s v2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_range_pk_1M ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_1M AS SELECT * FROM t_range_pk_1M;

CREATE TABLE t_range_pk_500K as SELECT
    s*2 id,
    s*2 v1,
    s*2 v2
    FROM generate_series(1, 50000) s;
ALTER TABLE t_range_pk_500K ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_500K AS SELECT * FROM t_range_pk_500K;

CREATE TABLE t_range_pk_200K as SELECT
    s*5 id,
    s*5 v1,
    s*5 v2
    FROM generate_series(1, 20000) s;
ALTER TABLE t_range_pk_200K ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_200K AS SELECT * FROM t_range_pk_200K;

CREATE TABLE t_range_pk_100K as SELECT
    s*10 id,
    s*10 v1,
    s*10 v2
    FROM generate_series(1, 10000) s;
ALTER TABLE t_range_pk_100K ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_100K AS SELECT * FROM t_range_pk_100K;

CREATE TABLE t_range_pk_1K as SELECT
    s*1000 id,
    s*1000 v1,
    s*1000 v2
    FROM generate_series(1, 100) s;
ALTER TABLE t_range_pk_1K ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_1K AS SELECT * FROM t_range_pk_1K;
