INSERT INTO t_composite_pk_10k 
    SELECT 
        floor(random() * 10 + 1)::int,
        floor(random() * 100 + 1)::int, 
        floor(random() * 1000 + 1)::int, 
        floor(random() * 10000 + 1)::int, 
        floor(random() * 10000 + 1)::int, 
        floor(random() * 10000 + 1)::int 
    FROM generate_series(1, 10000) s;