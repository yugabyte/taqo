CREATE TABLE t_range_pk_1m as SELECT
    s id,
    s v1,
    s v2
    FROM generate_series(1, 100000) s;
ALTER TABLE t_range_pk_1m ADD PRIMARY KEY (id);
CREATE INDEX tr1mv1 ON t_range_pk_1m (v1 ASC);

CREATE VIEW t_hash_pk_1m AS SELECT * FROM t_range_pk_1m;

CREATE TABLE t_range_pk_500k as SELECT
    s*2 id,
    s*2 v1,
    s*2 v2
    FROM generate_series(1, 50000) s;
ALTER TABLE t_range_pk_500k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_500k AS SELECT * FROM t_range_pk_500k;

CREATE TABLE t_range_pk_200k as SELECT
    s*5 id,
    s*5 v1,
    s*5 v2
    FROM generate_series(1, 20000) s;
ALTER TABLE t_range_pk_200k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_200k AS SELECT * FROM t_range_pk_200k;

CREATE TABLE t_range_pk_100k as SELECT
    s*10 id,
    s*10 v1,
    s*10 v2
    FROM generate_series(1, 10000) s;
ALTER TABLE t_range_pk_100k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_100k AS SELECT * FROM t_range_pk_100k;

CREATE TABLE t_range_pk_1k as SELECT
    s*1000 id,
    s*1000 v1,
    s*1000 v2
    FROM generate_series(1, 100) s;
ALTER TABLE t_range_pk_1k ADD PRIMARY KEY (id);

CREATE VIEW t_hash_pk_1k AS SELECT * FROM t_range_pk_1k;
