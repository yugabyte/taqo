SELECT * FROM t_hash_pk_1k th100k JOIN t_hash_pk_1m th1M ON
    th100K.id = th1M.id;

SELECT * FROM t_range_pk_100k tr100k JOIN t_hash_pk_1m th1M ON
    tr100K.id = th1M.id;

SELECT * FROM t_hash_pk_100k th100k JOIN t_range_pk_1m tr1M ON
    th100K.id = tr1M.id;

SELECT * FROM t_range_pk_100k tr100k JOIN t_range_pk_1m tr1M ON
    tr100k.id = tr1M.id;


SELECT * FROM t_hash_pk_1k th1k JOIN t_hash_pk_1m th1M ON
    th1K.id = th1M.id;

SELECT * FROM t_range_pk_1k tr1k JOIN t_hash_pk_1m th1M ON
    tr1K.id = th1M.id;

SELECT * FROM t_hash_pk_1k th1k JOIN t_range_pk_1m tr1M ON
    th1K.id = tr1M.id;

SELECT * FROM t_range_pk_1k tr1k JOIN t_range_pk_1m tr1M ON
    tr1k.id = tr1M.id;