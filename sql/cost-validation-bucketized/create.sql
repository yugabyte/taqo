--------------------------------------------- TABLE - I ---------------------------------------------
create table t100 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));

-- adding below normal indexes (not bucketized)
create index t100_simple_index_1 on t100 (c2 asc);
create index t100_simple_index_2 on t100 (c6);
create index t100_include_index_1 on t100 (c2 asc) include (c4, v);

-- adding bucketized index here
create index t100_bucketized_1 on t100 ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t100_bucketized_2 on t100 ((yb_hash_code(c2, c3) % 3), c2, c4, c3); -- have an extra column in index reversed
create index t100_bucketized_3 on t100 ((yb_hash_code(c2, c3) % 3), c2, c3, c4); -- have an extra column in index
create index t100_bucketized_4 on t100 ((yb_hash_code(c2, v) % 3), c2, v); -- have v (char) instead
create index t100_bucketized_5 on t100 ((yb_hash_code(c2, c3) % 3), c2, c3) SPLIT INTO 2 TABLETS; -- index split into tablets.
create index t100_bucketized_6 on t100 ((yb_hash_code(c2, c4) % 3), c2, c4); -- make one with c4 to alter c4 type to bigint later

-- some table alters to test
alter table t100 alter column c4 type bigint;

-- creating some complex bucketized index
CREATE UNIQUE INDEX t100_complex_index_1 ON t100 ((yb_hash_code(c2, c3) % 3), c2, c3, coalesce(c4, 0), c5, coalesce(c6, 0)) INCLUDE (v) WHERE c2 > 10;
CREATE INDEX t100_complex_index_2 ON t100 (bucketid, c1, c2, coalesce(c3, 0), c4) INCLUDE (c5, c6, v) WHERE c1 IS NOT NULL;
CREATE INDEX t100_complex_index_3 ON t100 ((yb_hash_code(lower(v::text), c2) % 3), lower(v::text), c2, c3) INCLUDE (c4, c5) WHERE v IS NOT NULL;
CREATE UNIQUE INDEX t100_complex_index_4 ON t100 ((yb_hash_code(c3, c2) % 3), bucketid, c3, c2, coalesce(c4, 0), c5) NULLS NOT DISTINCT WHERE c3 IS NOT NULL;
CREATE INDEX t100_complex_index_5 ON t100 ((yb_hash_code(c2, lower(v::text)) % 3), c2, v) INCLUDE (bucketid, c3, c4, c5, c6) WHERE v IS NOT NULL;




--------------------------------------------- TABLE - II ---------------------------------------------
-- for each table lets try to have different bucketids (and for one table, just bucketid and simpler indexes - to check performance in normal conditions)
-- simple table case below
create table t1000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024),  bucketid int generated always as ( yb_hash_code(c2, c4) % 3 ) STORED, primary key (bucketid asc, c2, c4));
create index t1000_bucketized_1 on t1000 ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t1000_bucketized_2 on t1000 ((yb_hash_code(c2, c4) % 3), c2, c4);




--------------------------------------------- TABLE - III ---------------------------------------------
-- partition table case below
create table t10000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) partition by range(c2);
create table t10000_partition_1 partition of t10000 for values from (0) to (25);
create table t10000_partition_2 partition of t10000 for values from (25) to (50);
create table t10000_partition_3 partition of t10000 for values from (50) to (75);
create table t10000_partition_4 partition of t10000 for values from (75) to (100);
create table t10000_partition_def partition of t10000 default;

-- adding below normal indexes (not bucketized)
create index t10000_simple_index_1 on t10000 (c2 asc);
create index t10000_simple_index_2 on t10000 (c6);
create index t10000_include_index_1 on t10000 (c2 asc) include (c4, v);

-- adding bucketized index here
create index t10000_bucketized_1 on t10000 ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t10000_bucketized_4 on t10000 ((yb_hash_code(c2, v) % 3), c2, v); -- have v (char) instead

-- adding bucketized index on the partitions directly
create index t10000_bucketized_partition_1 on t10000_partition_1 ((yb_hash_code(c2, c4) % 3), c2, c4);
create index t10000_bucketized_partition_2 on t10000_partition_2 ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t10000_bucketized_partition_3 on t10000_partition_3 ((yb_hash_code(c2, c1) % 3), c1, c2);
create index t10000_bucketized_partition_4 on t10000_partition_4 ((yb_hash_code(c1, v) % 3), c1, v);
create index t10000_bucketized_partition_def on t10000_partition_def ((yb_hash_code(c3, c4) % 3), c2, c4);




--------------------------------------------- TABLE - IV ---------------------------------------------
-- simple case (similar to one used in other models)
create table t100000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));
create unique index t100000_simple_index_1 on t100000 (c2 asc);
create index t100000_simple_index_2 on t100000 (c3 asc);
create index t100000_simple_index_3 on t100000 (c4 asc);
create index t100000_simple_index_4 on t100000 (c6 asc);
create index t100000_simple_index_5 on t100000 (c2 asc) include (c4);
create index t100000_simple_index_6 on t100000 (c2 asc) include (c4, v);
create index t100000_bucketized_1 on t100000 ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t100000_bucketized_2 on t100000 ((yb_hash_code(c2, c4) % 3), c2, c4);
create index t100000_bucketized_3 on t100000 ((yb_hash_code(c1, c2) % 3), c1, c2);





--------------------------------------------- TABLE - V ---------------------------------------------
create table t100000w (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(8192), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));
create unique index t100000w_simple_index_1 on t100000w (c2 asc);
create index t100000w_simple_index_2 on t100000w (c3 asc);
create index t100000w_simple_index_3 on t100000w (c4 asc);
create index t100000w_simple_index_4 on t100000w (c6 asc);
create index t100000w_simple_index_5 on t100000w (c2 asc) include (c4);
create index t100000w_simple_index_6 on t100000w (c2 asc) include (c4, v);
create index t100000w_bucketized_1 on t100000w ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t100000w_bucketized_2 on t100000w ((yb_hash_code(c2, c4) % 3), c2, c4);
create index t100000w_bucketized_3 on t100000w ((yb_hash_code(c1, c2) % 3), c1, c2);
create index t100000w_bucketized_4 on t100000w ((yb_hash_code(bucketid, v) % 3), bucketid, v); -- using bucketid here
create index t100000w_bucketized_5 on t100000w ((yb_hash_code(c2, v) % 3), c2, v);






--------------------------------------------- TABLE - VI ---------------------------------------------
create table t1000000m (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));
create index t1000000m_simple_index_1 on t1000000m (c1 asc, c2 asc, c3 asc, c4 asc);
create index t1000000m_simple_index_2_c4c2c3c1 on t1000000m (c4 asc, c2 asc, c3 asc, c1 asc);
create index t1000000m_simple_index_3_c5 on t1000000m (c5 asc);
create index t1000000m_simple_index_4_c6 on t1000000m (c6 asc);
create index t1000000m_simple_index_5_c3c4c5 on t1000000m (c3 asc, c4 asc, c5 asc);
create index t1000000m_simple_index_6_c5c4c3 on t1000000m (c5 asc, c4 asc, c3 asc);
create index t1000000m_bucketized_1 on t1000000m ((yb_hash_code(c2, c3) % 3), c2, c3);
create index t1000000m_bucketized_2 on t1000000m ((yb_hash_code(c2, c4) % 3), c2, c4);
create index t1000000m_bucketized_3 on t1000000m ((yb_hash_code(c1, c2) % 3), c1, c2);
create index t1000000m_bucketized_4 on t1000000m ((yb_hash_code(bucketid, c6) % 3), bucketid, c6); -- using bucketid here
create index t1000000m_bucketized_5 on t1000000m ((yb_hash_code(c2, c5) % 3), c2, c5);


------------------- custom tables here for checking behavior with and without ANY bucketized indexes -------------------
--------------------------------------------- below table will have only simple indexes ---------------------------------------------
create table table_simple (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));
create index table_simple_index_1 on table_simple (c2, c3);
create index table_simple_index_2 on table_simple(c2, c4);
create index table_simple_index_3 on table_simple (c4,c5);
create index table_simple_index_4 on table_simple (c6,v);
create index table_simple_index_5 on table_simple (c2 asc);
create index table_simple_index_6 on table_simple (c4 asc);
create index table_simple_index_7 on table_simple (c5 asc);



--------------------------------------------- below table will have only bucketized indexes ---------------------------------------------
create table table_bucketized (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2));
create index table_bucketized_only_index_1 on table_bucketized ((yb_hash_code(c2, c3) % 3), c2, c3);
create index table_bucketized_only_index_2 on table_bucketized ((yb_hash_code(c2, c4) % 3), c2, c4);
create index table_bucketized_only_index_3 on table_bucketized ((yb_hash_code(c4, c5) % 3), c4, c5);
create index table_bucketized_only_index_4 on table_bucketized ((yb_hash_code(c4, c5) % 3), c6, v);

