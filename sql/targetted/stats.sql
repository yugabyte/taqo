select (select count(*) from t_range_pk_1M),
       (select count(*) from t_hash_pk_1M),
       (select count(*) from t_range_pk_500K),
       (select count(*) from t_hash_pk_500K),
       (select count(*) from t_range_pk_200K),
       (select count(*) from t_hash_pk_200K),
       (select count(*) from t_range_pk_100K),
       (select count(*) from t_hash_pk_100K),
       (select count(*) from t_range_pk_1K),
       (select count(*) from t_hash_pk_1K);