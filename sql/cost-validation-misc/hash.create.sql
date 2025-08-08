--------------------------------
-- row count variation series --
--------------------------------

create table t100 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1 hash));
create unique index t100_c2 on t100 (c2 hash);
create index t100_c3 on t100 (c3 hash);
create index t100_c4 on t100 (c4 hash);
create index t100_c6 on t100 (c6 hash);
create index t100_c2_c4 on t100 (c2 hash) include (c4);
create index t100_c2_c4v on t100 (c2 hash) include (c4, v);

create table t1000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1 hash));
create unique index t1000_c2 on t1000 (c2 hash);
create index t1000_c3 on t1000 (c3 hash);
create index t1000_c4 on t1000 (c4 hash);
create index t1000_c6 on t1000 (c6 hash);
create index t1000_c2_c4 on t1000 (c2 hash) include (c4);
create index t1000_c2_c4v on t1000 (c2 hash) include (c4, v);

create table t10000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1 hash));
create unique index t10000_c2 on t10000 (c2 hash);
create index t10000_c3 on t10000 (c3 hash);
create index t10000_c4 on t10000 (c4 hash);
create index t10000_c6 on t10000 (c6 hash);
create index t10000_c2_c4 on t10000 (c2 hash) include (c4);
create index t10000_c2_c4v on t10000 (c2 hash) include (c4, v);

create table t100000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1 hash));
create unique index t100000_c2 on t100000 (c2 hash);
create index t100000_c3 on t100000 (c3 hash);
create index t100000_c4 on t100000 (c4 hash);
create index t100000_c6 on t100000 (c6 hash);
create index t100000_c2_c4 on t100000 (c2 hash) include (c4);
create index t100000_c2_c4v on t100000 (c2 hash) include (c4, v);

create table t100000w (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(8192), primary key (c1 hash));
create unique index t100000w_c2 on t100000w (c2 hash);
create index t100000w_c3 on t100000w (c3 hash);
create index t100000w_c4 on t100000w (c4 hash);
create index t100000w_c6 on t100000w (c6 hash);
create index t100000w_c2_c4 on t100000w (c2 hash) include (c4);
create index t100000w_c2_c4v on t100000w (c2 hash) include (c4, v);


------------------------------
-- composite key test table --
------------------------------

create table t1000000m (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, primary key (c0 hash));
create index t1000000m_c1c2c3c4_ch on t1000000m ((c1, c2, c3, c4) hash);
create index t1000000m_c4c2c3c1_ch on t1000000m ((c4, c2, c3, c1) hash);
create index t1000000m_c5 on t1000000m (c5 hash);
create index t1000000m_c3c4c5_ch on t1000000m ((c3, c4, c5) hash);
create index t1000000m_c5c4c3_ch on t1000000m ((c5, c4, c3) hash);

-- create another set of indexes distributed only on the first key item
-- because composite hash key indexes above can be used only for the queries
-- with equality predicate on every key column.
create index t1000000m_c1c2c3c4 on t1000000m (c1 hash, c2, c3, c4);
create index t1000000m_c4c2c3c1 on t1000000m (c4 hash, c2, c3, c1);
create index t1000000m_c3c4c5 on t1000000m (c3 hash, c4, c5);
create index t1000000m_c5c4c3 on t1000000m (c5 hash, c4, c3);


------------------------------
-- decimal type test tables --
------------------------------

create table t1000000d10 (v decimal(1000, 6));
create table t1000000d20 (v decimal(1000, 6));
create table t1000000d30 (v decimal(1000, 6));
create table t1000000d40 (v decimal(1000, 6));
create table t1000000d50 (v decimal(1000, 6));
create table t1000000d60 (v decimal(1000, 6));
create table t1000000d70 (v decimal(1000, 6));
create table t1000000d80 (v decimal(1000, 6));
create table t1000000d90 (v decimal(1000, 6));
create table t1000000d100 (v decimal(1000, 6));

create index t1000000d10_v on t1000000d10 (v hash);
create index t1000000d20_v on t1000000d20 (v hash);
create index t1000000d30_v on t1000000d30 (v hash);
create index t1000000d40_v on t1000000d40 (v hash);
create index t1000000d50_v on t1000000d50 (v hash);
create index t1000000d60_v on t1000000d60 (v hash);
create index t1000000d70_v on t1000000d70 (v hash);
create index t1000000d80_v on t1000000d80 (v hash);
create index t1000000d90_v on t1000000d90 (v hash);
create index t1000000d100_v on t1000000d100 (v hash);


------------------------------------------------------
-- int/float tables for comparison against decimals --
------------------------------------------------------

create table t1000000i (v integer);
create table t1000000bi (v bigint);
create table t1000000flt (v real);
create table t1000000dbl (v double precision);

create index t1000000i_v on t1000000i (v hash);
create index t1000000bi_v on t1000000bi (v hash);
create index t1000000flt_v on t1000000flt (v hash);
create index t1000000dbl_v on t1000000dbl (v hash);


--------------------------------------
-- column/value position test table --
--------------------------------------

create table t1000000c10 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int, c9 int, primary key (c0 hash));
create index t1000000c10_c1_c0c2c3c4c5c6c7c8c9 on t1000000c10 (c1 hash) include (c0, c2, c3, c4, c5, c6, c7, c8, c9);
create index t1000000c10_c5_c0c2c3c4c1c6c7c8c9 on t1000000c10 (c5 hash) include (c0, c2, c3, c4, c1, c6, c7, c8, c9);
