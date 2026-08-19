-- PostgreSQL variant of the cost-validation-bucketized-v2 schema, used with
-- --ddl-prefix=postgres or --db=postgres so the same queries can be run
-- against upstream for comparison.
--
-- Two differences from create.sql, both unavoidable.  yb_hash_code does not
-- exist upstream, so buckets come from mod(c2, B) instead.  c2 is a
-- permutation of 1..N, so that is uniform and every bucket holds the same
-- share, but a given row lands in a different bucket than it does on YB.  And
-- SPLIT AT VALUES has no meaning here, so there is no tablet layout to
-- control: upstream reads one B-tree per index and has no streams, so it is
-- the merge-free reference the whole model is measured against rather than a
-- second implementation of it.
--
-- Everything else is kept identical on purpose, including the indexes that
-- exist only to be a rival and the expression keys that exist only to be
-- redundantly derived, so a query's row count and selectivity match on both
-- systems.


-- =====================================================================
-- Bucket count sweep and its control
-- =====================================================================

create table mb2 (
  c0 int generated always as (mod(c2, 2)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create table mb4 (
  c0 int generated always as (mod(c2, 4)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create table mb16 (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create table mb64 (
  c0 int generated always as (mod(c2, 64)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create table mplain (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c1)
);


-- =====================================================================
-- Row width pair
-- =====================================================================

create table mn16 (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create table mw16 (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(4096),
  primary key (c0, c1, c2)
);


-- =====================================================================
-- Stream product
-- =====================================================================

create table ms16 (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c6, c1)
);


-- =====================================================================
-- User-written IN lists, no bucketization
-- =====================================================================

create table sa (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2)
);

create index sa_c6c1 on sa (c6 asc, c1 asc);
create index sa_c4c1 on sa (c4 asc, c1 asc);
create index sa_c3c1 on sa (c3 asc, c1 asc);


-- =====================================================================
-- Estimate error against a selective rival path
-- =====================================================================

create table sel (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create index sel_c3c1 on sel (c3 asc, c1 asc);
create index sel_c7c1 on sel (c7 asc, c1 asc);
create index sel_vc1 on sel (v asc, c1 asc);


-- =====================================================================
-- Partitioning
-- =====================================================================

create table pt (
  c0 int generated always as (mod(c2, 8)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
) partition by range (c1);

create table pt_p1 partition of pt for values from (1) to (50001);
create table pt_p2 partition of pt for values from (50001) to (100001);
create table pt_p3 partition of pt for values from (100001) to (150001);
create table pt_p4 partition of pt for values from (150001) to (200001);


-- =====================================================================
-- Join partner
-- =====================================================================

create table dj (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2)
);

create index dj_c1c2 on dj (c1 asc, c2 asc);


-- =====================================================================
-- Derived equalities
-- =====================================================================

create table de16 (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c2, c1)
);

create index de16_c3c1 on de16 (c3 asc, c1 asc);
create index de16_c4c1 on de16 (c4 asc, (c4 % 20), (c4 + 1), (c4 * 2), c1 asc);

create table de2c (
  c0 int generated always as (mod(c2 + c6, 8)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c2, c6, c1)
);

create table dex (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2)
);

create index dex_c1c2 on dex ((mod(c2, 8)), c1 asc, c2 asc);
create index dex_c3c1 on dex ((mod(c3, 8)), c3 asc, c1 asc);


-- =====================================================================
-- Rival index suite
-- =====================================================================

create table riv (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2)
);

create index riv_c6c1 on riv (c6 asc, c1 asc);
create index riv_c4c1 on riv (c4 asc, c1 asc);
create index riv_c3c1 on riv (c3 asc, c1 asc);
create index riv_c1 on riv (c1 asc);
create index riv_c1c6 on riv (c1 asc, c6 asc);

create table rivb (
  c0 int generated always as (mod(c2, 16)) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0, c1, c2)
);

create index rivb_c1c2 on rivb (c1 asc, c2 asc);
