-- Tests for seqscan cost model
-- Base table tuple width affects disk fetch costs
SELECT * FROM t_range_pk_100k;
SELECT * FROM t_range_wide_pk_100k;

-- Result tuple width affects network cost
SELECT id FROM t_range_wide_pk_100k;
SELECT v1 FROM t_range_wide_pk_100k;
SELECT v1, v2 FROM t_range_wide_pk_100k;
SELECT s1 FROM t_range_wide_pk_100k;
SELECT s2 FROM t_range_wide_pk_100k;

-- Remote filter execution reduces network cost
SELECT * FROM t_range_pk_100k where v2 > 20000;
SELECT * FROM t_range_pk_100k where v2 > 60000;
SELECT * FROM t_range_pk_100k where v2 > 80000;
SELECT * FROM t_range_pk_100k where v2 > 100000;