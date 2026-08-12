-- Every bucketized primary key and index in this model is range sharded, and
-- under automatic tablet splitting (the default), a range-sharded entity
-- starts as a single tablet that data of this size may never split.  On a
-- single tablet, all merge streams share one response-size budget
-- (yugabyte/yugabyte-db#33247), so an unsplit layout measures that defect
-- rather than the feature.  Every bucketized primary key, bucketized index,
-- and t10000 partition is therefore pre-split at bucket boundaries with SPLIT
-- AT VALUES, matching the feature's intended one-tablet-per-bucket layout (a
-- split on a partitioned parent's index propagates to the child indexes).  One
-- canary site is deliberately left unsplit, so single-tablet coverage of the
-- defect layout is retained on purpose: the two bkt64 indexes on table_hm.

--------------------------------------------- TABLE - I ---------------------------------------------
create table t100 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2));

-- adding below normal indexes (not bucketized)
create index t100_simple_index_1 on t100 (c2 asc);
create index t100_simple_index_2 on t100 (c6);
create index t100_include_index_1 on t100 (c2 asc) include (c4, v);

-- adding bucketized index here
create index t100_bucketized_1 on t100 ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t100_bucketized_2 on t100 ((yb_hash_code(c2, c3) % 5) asc, c2, c4, c3) split at values ((1),(2),(3),(4)); -- have an extra column in index reversed
create index t100_bucketized_3 on t100 ((yb_hash_code(c2, c3) % 7) asc, c2, c3, c4) split at values ((1),(2),(3),(4),(5),(6)); -- have an extra column in index
create index t100_bucketized_4 on t100 ((yb_hash_code(c2, v) % 9) asc, c2, v) split at values ((1),(2),(3),(4),(5),(6),(7),(8)); -- have v (char) instead
create index t100_bucketized_5 on t100 ((yb_hash_code(c2, c3) % 11) asc, c2, c3) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10));
create index t100_bucketized_6 on t100 ((yb_hash_code(c2, c4) % 3) asc, c2, c4) split at values ((1),(2)); -- make one with c4 to alter c4 type to bigint later

-- some table alters to test
alter table t100 alter column c4 type bigint;

-- creating some complex bucketized index
CREATE UNIQUE INDEX t100_complex_index_1 ON t100 ((yb_hash_code(c2, c3) % 3) asc, c2, c3, coalesce(c4, 0), c5, coalesce(c6, 0)) INCLUDE (v) split at values ((1),(2)) WHERE c2 > 10;
CREATE INDEX t100_complex_index_2 ON t100 (bucketid asc, c1, c2, coalesce(c3, 0), c4) INCLUDE (c5, c6, v) split at values ((1),(2)) WHERE c1 IS NOT NULL;
CREATE INDEX t100_complex_index_3 ON t100 ((yb_hash_code(lower(v::text), c2) % 3) asc, lower(v::text), c2, c3) INCLUDE (c4, c5) split at values ((1),(2)) WHERE v IS NOT NULL;
CREATE UNIQUE INDEX t100_complex_index_4 ON t100 ((yb_hash_code(c3, c2) % 3) asc, bucketid, c3, c2, coalesce(c4, 0), c5) NULLS NOT DISTINCT split at values ((1),(2)) WHERE c3 IS NOT NULL;
CREATE INDEX t100_complex_index_5 ON t100 ((yb_hash_code(c2, lower(v::text)) % 3) asc, c2, v) INCLUDE (bucketid, c3, c4, c5, c6) split at values ((1),(2)) WHERE v IS NOT NULL;




--------------------------------------------- TABLE - II ---------------------------------------------
-- for each table lets try to have different bucketids (and for one table, just bucketid and simpler indexes - to check performance in normal conditions)
-- simple table case below
create table t1000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024),  bucketid int generated always as ( yb_hash_code(c2, c4) % 5 ) STORED, primary key (bucketid asc, c2, c4)) split at values ((1),(2),(3),(4));
create index t1000_bucketized_1 on t1000 ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t1000_bucketized_2 on t1000 ((yb_hash_code(c2, c4) % 5) asc, c2, c4) split at values ((1),(2),(3),(4));




--------------------------------------------- TABLE - III ---------------------------------------------
-- partition table case below
create table t10000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) partition by range(c2);
create table t10000_partition_1 partition of t10000 for values from (0) to (25) split at values ((1),(2));
create table t10000_partition_2 partition of t10000 for values from (25) to (50) split at values ((1),(2));
create table t10000_partition_3 partition of t10000 for values from (50) to (75) split at values ((1),(2));
create table t10000_partition_4 partition of t10000 for values from (75) to (100) split at values ((1),(2));
create table t10000_partition_def partition of t10000 default split at values ((1),(2));

-- adding below normal indexes (not bucketized)
create index t10000_simple_index_1 on t10000 (c2 asc);
create index t10000_simple_index_2 on t10000 (c6);
create index t10000_include_index_1 on t10000 (c2 asc) include (c4, v);

-- adding bucketized index here
create index t10000_bucketized_1 on t10000 ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t10000_bucketized_4 on t10000 ((yb_hash_code(c2, v) % 3) asc, c2, v) split at values ((1),(2)); -- have v (char) instead

-- adding bucketized index on the partitions directly
create index t10000_bucketized_partition_1 on t10000_partition_1 ((yb_hash_code(c2, c4) % 3) asc, c2, c4) split at values ((1),(2));
create index t10000_bucketized_partition_2 on t10000_partition_2 ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t10000_bucketized_partition_3 on t10000_partition_3 ((yb_hash_code(c2, c1) % 7) asc, c1, c2) split at values ((1),(2),(3),(4),(5),(6));
create index t10000_bucketized_partition_4 on t10000_partition_4 ((yb_hash_code(c1, v) % 11) asc, c1, v) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10));
create index t10000_bucketized_partition_def on t10000_partition_def ((yb_hash_code(c3, c4) % 3) asc, c2, c4) split at values ((1),(2));




--------------------------------------------- TABLE - IV ---------------------------------------------
-- simple case (similar to one used in other models)
create table t100000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 7 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2),(3),(4),(5),(6));
create unique index t100000_simple_index_1 on t100000 (c2 asc);
create index t100000_simple_index_2 on t100000 (c3 asc);
create index t100000_simple_index_3 on t100000 (c4 asc);
create index t100000_simple_index_4 on t100000 (c6 asc);
create index t100000_simple_index_5 on t100000 (c2 asc) include (c4);
create index t100000_simple_index_6 on t100000 (c2 asc) include (c4, v);
create index t100000_bucketized_1 on t100000 ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t100000_bucketized_2 on t100000 ((yb_hash_code(c2, c4) % 3) asc, c2, c4) split at values ((1),(2));
create index t100000_bucketized_3 on t100000 ((yb_hash_code(c1, c2) % 7) asc, c1, c2) split at values ((1),(2),(3),(4),(5),(6));





--------------------------------------------- TABLE - V ---------------------------------------------
create table t100000w (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(8192), bucketid int generated always as ( yb_hash_code(c1, c2) % 11 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10));
create unique index t100000w_simple_index_1 on t100000w (c2 asc);
create index t100000w_simple_index_2 on t100000w (c3 asc);
create index t100000w_simple_index_3 on t100000w (c4 asc);
create index t100000w_simple_index_4 on t100000w (c6 asc);
create index t100000w_simple_index_5 on t100000w (c2 asc) include (c4);
create index t100000w_simple_index_6 on t100000w (c2 asc) include (c4, v);
create index t100000w_bucketized_1 on t100000w ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t100000w_bucketized_2 on t100000w ((yb_hash_code(c2, c4) % 5) asc, c2, c4) split at values ((1),(2),(3),(4));
create index t100000w_bucketized_3 on t100000w ((yb_hash_code(c1, c2) % 7) asc, c1, c2) split at values ((1),(2),(3),(4),(5),(6));
create index t100000w_bucketized_4 on t100000w ((yb_hash_code(bucketid, v) % 3) asc, bucketid, v) split at values ((1),(2)); -- using bucketid here
create index t100000w_bucketized_5 on t100000w ((yb_hash_code(c2, v) % 3) asc, c2, v) split at values ((1),(2));






--------------------------------------------- TABLE - VI ---------------------------------------------
create table t1000000m (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2));
create index t1000000m_simple_index_1 on t1000000m (c1 asc, c2 asc, c3 asc, c4 asc);
create index t1000000m_simple_index_2_c4c2c3c1 on t1000000m (c4 asc, c2 asc, c3 asc, c1 asc);
create index t1000000m_simple_index_3_c5 on t1000000m (c5 asc);
create index t1000000m_simple_index_4_c6 on t1000000m (c6 asc);
create index t1000000m_simple_index_5_c3c4c5 on t1000000m (c3 asc, c4 asc, c5 asc);
create index t1000000m_simple_index_6_c5c4c3 on t1000000m (c5 asc, c4 asc, c3 asc);
create index t1000000m_bucketized_1 on t1000000m ((yb_hash_code(c2, c3) % 3) asc, c2, c3) split at values ((1),(2));
create index t1000000m_bucketized_2 on t1000000m ((yb_hash_code(c2, c4) % 3) asc, c2, c4) split at values ((1),(2));
create index t1000000m_bucketized_3 on t1000000m ((yb_hash_code(c1, c2) % 5) asc, c1, c2) split at values ((1),(2),(3),(4));
create index t1000000m_bucketized_4 on t1000000m ((yb_hash_code(bucketid, c6) % 3) asc, bucketid, c6) split at values ((1),(2)); -- using bucketid here
create index t1000000m_bucketized_5 on t1000000m ((yb_hash_code(c2, c5) % 3) asc, c2, c5) split at values ((1),(2));


------------------- custom tables here for checking behavior with and without ANY bucketized indexes -------------------
--------------------------------------------- below table will have only simple indexes ---------------------------------------------
create table table_simple (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2));
create index table_simple_index_1 on table_simple (c2 asc, c3 asc);
create index table_simple_index_2 on table_simple (c2 asc, c4 asc);
create index table_simple_index_3 on table_simple (c4 asc, c5 asc);
create index table_simple_index_4 on table_simple (c6 asc, v asc);

--------------------------------------------- below table will have only bucketized indexes ---------------------------------------------
create table table_bucketized (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), bucketid int generated always as ( yb_hash_code(c1, c2) % 3 ) STORED, primary key (bucketid asc, c1, c2)) split at values ((1),(2));
create index table_bucketized_only_index_1 on table_bucketized ((yb_hash_code(c2, c3) % 3) asc, c2 asc, c3 asc) split at values ((1),(2));
create index table_bucketized_only_index_2 on table_bucketized ((yb_hash_code(c2, c4) % 3) asc, c2 asc, c4 asc) split at values ((1),(2));
create index table_bucketized_only_index_3 on table_bucketized ((yb_hash_code(c4, c5) % 7) asc, c4 asc, c5 asc) split at values ((1),(2),(3),(4),(5),(6));
create index table_bucketized_only_index_4 on table_bucketized ((yb_hash_code(c6, v) % 15) asc, c6 asc, v asc) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14));


CREATE TABLE table_hm (
    c1 int,
    c2 int not null,
    c3 int,
    c4 int,
    c5 int,
    c6 int,
    v  text,
    c7 int,
    c8 int,
    ts timestamptz not null default now(),
    bucketid int generated always as (yb_hash_code(c1, c2) % 64) stored,
    primary key (bucketid asc, c1 asc, c2 asc)
) split at values ((8),(16),(24),(32),(40),(48),(56));

-- The two bkt64 indexes below are deliberately left unsplit: 64 streams on a
-- single tablet is the strongest yugabyte/yugabyte-db#33247 canary in the
-- model.  Automatic tablet splitting would defeat this above the low-phase
-- threshold (tablet_split_low_phase_size_threshold_bytes, 128 MB of
-- post-compaction SST), but at 1M table_hm rows, each index measures about
-- 42 MB, a 3x margin.  Re-check the margin if table_hm grows.
CREATE INDEX table_hm_bkt64_c2c3_desc ON table_hm ((yb_hash_code(c2, c3) % 64) asc, c2 desc, c3 desc);
CREATE INDEX table_hm_bkt64_c4c5_desc ON table_hm ((yb_hash_code(c4, c5) % 64) asc, c4 desc, c5 desc);
CREATE INDEX table_hm_simple_c2 ON table_hm (c2 asc);


CREATE TABLE table_split (
    c1 int,
    c2 int not null,
    c3 int,
    c4 int,
    c5 int,
    c6 int,
    v  text,
    c7 int,
    c8 int,
    ts timestamptz not null default now(),
    bucketid int generated always as (yb_hash_code(c1, c2) % 4) stored,
    primary key (bucketid asc, c1 asc, c2 asc)
) split at values ((1),(2),(3));

CREATE INDEX table_split_simple_c2 ON table_split (c2 asc);
CREATE INDEX table_split_include_c2 ON table_split (c2 asc) include (c4);
CREATE INDEX table_split_ts ON table_split (ts asc);
CREATE INDEX table_split_bucketized_asc ON table_split ((yb_hash_code(c2, c3) % 4) asc, c2 asc, c3 asc) split at values ((1),(2),(3));
CREATE INDEX table_split_bucketized_desc ON table_split ((yb_hash_code(c2, c3) % 4) asc, c2 desc, c3 desc) split at values ((1),(2),(3));
CREATE INDEX ts_bkt64_c2c3 ON table_split ((yb_hash_code(c2, c3) % 64) asc, c2 asc, c3 asc) split at values ((8),(16),(24),(32),(40),(48),(56));
