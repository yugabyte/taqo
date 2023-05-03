CREATE TABLE t_range_pk_1m as SELECT
    s id,
    s v1,
    s v2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_range_pk_1m ADD PRIMARY KEY (id ASC);

CREATE TABLE t_hash_pk_1m WITH (COLOCATED=false) as SELECT
    s id,
    s v1,
    s v2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_hash_pk_1m ADD PRIMARY KEY (id HASH);

CREATE TABLE t_range_pk_500k as SELECT
    s*2 id,
    s*2 v1,
    s*2 v2
    FROM generate_series(1, 50000) s;
ALTER TABLE t_range_pk_500k ADD PRIMARY KEY (id ASC);

CREATE TABLE t_hash_pk_500k WITH (COLOCATED=false) as SELECT
    s*2 id,
    s*2 v1,
    s*2 v2
    FROM generate_series(1, 50000) s;
ALTER TABLE t_hash_pk_500k ADD PRIMARY KEY (id HASH);

CREATE TABLE t_range_pk_200k as SELECT
    s*5 id,
    s*5 v1,
    s*5 v2
    FROM generate_series(1, 20000) s;
ALTER TABLE t_range_pk_200k ADD PRIMARY KEY (id ASC);

CREATE TABLE t_hash_pk_200k WITH (COLOCATED=false) as SELECT
    s*5 id,
    s*5 v1,
    s*5 v2
    FROM generate_series(1, 20000) s;
ALTER TABLE t_hash_pk_200k ADD PRIMARY KEY (id HASH);

CREATE TABLE t_range_pk_100k as SELECT
    s*10 id,
    s*10 v1,
    s*10 v2
    FROM generate_series(1, 10000) s;
ALTER TABLE t_range_pk_100k ADD PRIMARY KEY (id ASC);

CREATE TABLE t_hash_pk_100k WITH (COLOCATED=false) as SELECT
    s*10 id,
    s*10 v1,
    s*10 v2
    FROM generate_series(1, 10000) s;
ALTER TABLE t_hash_pk_100k ADD PRIMARY KEY (id HASH);

CREATE TABLE t_range_pk_1k as SELECT
    s*1000 id,
    s*1000 v1,
    s*1000 v2
    FROM generate_series(1, 100) s;
ALTER TABLE t_range_pk_1k ADD PRIMARY KEY (id ASC);

CREATE TABLE t_hash_pk_1k WITH (COLOCATED=false) as SELECT
    s*1000 id,
    s*1000 v1,
    s*1000 v2
    FROM generate_series(1, 100) s;
ALTER TABLE t_hash_pk_1k ADD PRIMARY KEY (id HASH);