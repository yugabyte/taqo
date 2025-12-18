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
