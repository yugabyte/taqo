-- For tuning the remote filter overhead
-- Apply remote filter on tables with increasing number of rows
-- Result size should remain same, filter selects 50k rows in each case
SELECT * FROM t_range_100k WHERE v2 > 50000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_200k WHERE v2 > 150000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_300k WHERE v2 > 250000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_400k WHERE v2 > 350000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_500k WHERE v2 > 450000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_600k WHERE v2 > 550000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_700k WHERE v2 > 650000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_800k WHERE v2 > 750000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_900k WHERE v2 > 850000 AND v3 < 1000000 AND v4 > 0;
SELECT * FROM t_range_1m WHERE v2 > 950000 AND v3 < 1000000 AND v4 > 0;