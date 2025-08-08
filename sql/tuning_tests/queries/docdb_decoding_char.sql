/*+ SET(yb_fetch_row_limit 4096) */ SELECT v1 FROM t_char4_100k limit 40960;
/*+ SET(yb_fetch_row_limit 2048) */ SELECT v1, v2 FROM t_char4_100k limit 20480;
/*+ SET(yb_fetch_row_limit 1024) */ SELECT v1, v2, v3, v4 FROM t_char4_100k limit 10240;
/*+ SET(yb_fetch_row_limit 512) */ SELECT v1, v2, v3, v4, v5, v6, v7, v8 FROM t_char4_100k limit 5120;

/*+ SET(yb_fetch_row_limit 4096) */ SELECT v1 FROM t_char8_100k limit 40960;
/*+ SET(yb_fetch_row_limit 2048) */ SELECT v1, v2 FROM t_char8_100k limit 20480;
/*+ SET(yb_fetch_row_limit 1024) */ SELECT v1, v2, v3, v4 FROM t_char8_100k limit 10240;
/*+ SET(yb_fetch_row_limit 512) */ SELECT v1, v2, v3, v4, v5, v6, v7, v8 FROM t_char8_100k limit 5120;

/*+ SET(yb_fetch_row_limit 4096) */ SELECT v1 FROM t_char16_100k limit 40960;
/*+ SET(yb_fetch_row_limit 2048) */ SELECT v1, v2 FROM t_char16_100k limit 20480;
/*+ SET(yb_fetch_row_limit 1024) */ SELECT v1, v2, v3, v4 FROM t_char16_100k limit 10240;
/*+ SET(yb_fetch_row_limit 512) */ SELECT v1, v2, v3, v4, v5, v6, v7, v8 FROM t_char16_100k limit 5120;
