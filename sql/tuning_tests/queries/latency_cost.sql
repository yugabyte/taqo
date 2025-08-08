/*+ SET(yb_fetch_row_limit 128) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 256) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 512) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 1024) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 2048) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 4096) */ SELECT 0 FROM t_int_100k;
/*+ SET(yb_fetch_row_limit 8192) */ SELECT 0 FROM t_int_100k;