
UPDATE t_range_100k_2update SET v2 = v2 + 1;

INSERT INTO t_range_100k_3update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_3update SET v1 = v1 + 1;
UPDATE t_range_100k_3update SET v2 = v2 + 1;
UPDATE t_range_100k_3update SET v3 = v3 + 1;

INSERT INTO t_range_100k_4update (SELECT s, s, s, s, s FROM generate_series(1, 100000) s);
UPDATE t_range_100k_4update SET v1 = v1 + 1;
UPDATE t_range_100k_4update SET v2 = v2 + 1;
UPDATE t_range_100k_4update SET v3 = v3 + 1;
UPDATE t_range_100k_4update SET v4 = v4 + 1;

INSERT INTO t_range_100k_1column (SELECT s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_2column (SELECT s, s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_3column (SELECT s, s, s FROM generate_series(1, 100000) s);
INSERT INTO t_range_100k_4column (SELECT s, s, s, s FROM generate_series(1, 100000) s);