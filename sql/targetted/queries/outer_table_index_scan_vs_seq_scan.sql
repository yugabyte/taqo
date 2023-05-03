SELECT * FROM t_hash_pk_500K th500k JOIN t_hash_pk_1M th1M ON
    th500K.id = th1M.id;

SELECT * FROM t_range_pk_500K tr500k JOIN t_hash_pk_1M th1M ON
    tr500K.id = th1M.id;

SELECT * FROM t_hash_pk_500K th500k JOIN t_range_pk_1M tr1M ON
    th500K.id = tr1M.id;

SELECT * FROM t_range_pk_500K tr500k JOIN t_range_pk_1M tr1M ON
    tr500k.id = tr1M.id;


SELECT * FROM t_hash_pk_200K th200k JOIN t_hash_pk_1M th1M ON
    th200K.id = th1M.id;

SELECT * FROM t_range_pk_200K tr200k JOIN t_hash_pk_1M th1M ON
    tr200K.id = th1M.id;

SELECT * FROM t_hash_pk_200K th200k JOIN t_range_pk_1M tr1M ON
    th200K.id = tr1M.id;

SELECT * FROM t_range_pk_200K tr200k JOIN t_range_pk_1M tr1M ON
    tr200k.id = tr1M.id;


SELECT * FROM t_hash_pk_1K th100k JOIN t_hash_pk_1M th1M ON
    th100K.id = th1M.id;

SELECT * FROM t_range_pk_100K tr100k JOIN t_hash_pk_1M th1M ON
    tr100K.id = th1M.id;

SELECT * FROM t_hash_pk_100K th100k JOIN t_range_pk_1M tr1M ON
    th100K.id = tr1M.id;

SELECT * FROM t_range_pk_100K tr100k JOIN t_range_pk_1M tr1M ON
    tr100k.id = tr1M.id;


SELECT * FROM t_hash_pk_1K th1k JOIN t_hash_pk_1M th1M ON
    th1K.id = th1M.id;

SELECT * FROM t_range_pk_1K tr1k JOIN t_hash_pk_1M th1M ON
    tr1K.id = th1M.id;

SELECT * FROM t_hash_pk_1K th1k JOIN t_range_pk_1M tr1M ON
    th1K.id = tr1M.id;

SELECT * FROM t_range_pk_1K tr1k JOIN t_range_pk_1M tr1M ON
    tr1k.id = tr1M.id;