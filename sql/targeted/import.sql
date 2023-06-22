INSERT INTO t_composite_pk_10k 
    SELECT 
        s, s, s, s, s, s 
    FROM generate_series(1, 10000) s;