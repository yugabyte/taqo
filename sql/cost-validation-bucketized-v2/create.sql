-- Schema for the cost-validation-bucketized-v2 model.  See README.md for the
-- design rules this file follows.  The two that shape every statement below:
--
-- 1. Hot-shard rule.  A bucketized index exists because the plain range index
--    on the same leading columns would concentrate writes on one shard.  So
--    where a bucketized entity orders by c1, no plain index leading with c1
--    exists on the same table.  The rival-suite tables (riv, rivb) break this
--    on purpose and are the only ones that do.
--
-- 2. Layout rule.  Every bucketized entity is pre-split at bucket boundaries,
--    which is the feature's intended one-tablet-per-bucket layout and keeps
--    measurements off yugabyte/yugabyte-db#33247.  A base table whose primary
--    key is not bucketized is pre-split into 4 tablets so a sequential scan
--    is not artificially serialized against merge scan.  Plain secondary
--    indexes are left at the YB default of one tablet, which is what a user
--    actually gets.
--
-- Column roles are the same in every table:
--   c0  bucket, generated always as (yb_hash_code(...) % B) stored
--   c1  monotone 1..N, the "event time", what bucketized entities order by
--   c2  unique permutation of 1..N, the "entity id", the hash input
--   c3  ndv 1000, independent permutation
--   c4  ndv 100, independent permutation
--   c5  unique permutation, never indexed
--   c6  ndv 10, independent permutation
--   c7  ndv 100
--   c8  equal to c7 in every row but the first, where it is c7 + 1, giving
--       predicate pairs that match 4999 rows, exactly 1 row, or nothing while
--       the estimator predicts about 50 for all three
--   v   char(64), or char(4096) on the one wide table


-- =====================================================================
-- Merge scan: bucket count sweep
-- =====================================================================
-- mb2, mb4, mb16 and mb64 hold identical data and differ only in the
-- modulus, so the stream count is the only variable across them.  Each has
-- no index besides its bucketized primary key, so an ORDER BY c1 query has
-- merge scan or a sort over a full scan and nothing else.

create table mb2 (
  c0 int generated always as (yb_hash_code(c2) % 2) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1));

create table mb4 (
  c0 int generated always as (yb_hash_code(c2) % 4) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3));

create table mb16 (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));

create table mb64 (
  c0 int generated always as (yb_hash_code(c2) % 64) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),(61),(62),(63));

-- Control for the sweep: the same rows in the layout a user would have if c1
-- were not hot enough to need bucketing.  One ordered scan, no streams.  It
-- gets 16 tablets to match mb16, the reference point of the sweep.
create table mplain (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c1 asc)
) split at values ((31250),(62500),(93750),(125000),(156250),(187500),(218750),(250000),(281250),(312500),(343750),(375000),(406250),(437500),(468750));


-- =====================================================================
-- Merge scan: row width
-- =====================================================================
-- mn16 and mw16 are the same table at two row widths, 64 characters against
-- 4096, with the same 50000 rows.  Per-stream fetches are what row width
-- makes expensive, and the pair isolates width with nothing else moving.
-- mn16 is also the same schema as mb16 at a tenth of the rows, so the two
-- pairs together separate width from row count.

create table mn16 (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));

create table mw16 (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(4096),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));


-- =====================================================================
-- Merge scan: stream cardinality as a product
-- =====================================================================
-- The stream count is the cartesian product of every merge-eligible SAOP, so
-- a user IN list on c6 multiplies the 16 derived bucket streams.  ndv(c6) is
-- 10, giving products of 16, 32, ... 160 across the 64 cap.

create table ms16 (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c6 asc, c1 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));


-- =====================================================================
-- Merge scan: user-written IN lists, no bucketization anywhere
-- =====================================================================
-- Merge scan is not a bucketized-index feature.  Any range index plus a user
-- IN list on its leading column engages it, and that is the majority of the
-- exposure in existing workloads.  sa has no bucket column and no derived
-- clause of any kind can apply to it, so it isolates merge scan from both
-- derived-clause GUCs.  Its secondary indexes are deliberately left unsplit
-- because that is the YB default a user gets, which also makes the large IN
-- lists on sa_c4c1 the model's #33247 exposure.

create table sa (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2 asc)
) split at values ((125000),(250000),(375000));

-- Three lead columns of different cardinality, so a user IN list can produce
-- anything from 2 streams to more than the 64 cap, at selectivities from a
-- tenth of the table per element down to a thousandth.
create index sa_c6c1 on sa (c6 asc, c1 asc);
create index sa_c4c1 on sa (c4 asc, c1 asc);
create index sa_c3c1 on sa (c3 asc, c1 asc);


-- =====================================================================
-- Merge scan: estimate error against a selective rival path
-- =====================================================================
-- The same rows as mb16 with three plain indexes on columns a filter can
-- actually seek on.  None of the three leads with c1, so the hot-shard rule
-- holds: c3, c7 and v are all non-monotone and a plain index on them is what
-- a real schema would have.  What that buys is a genuine competitor for every
-- query here, an index condition that removes most of the table, against the
-- bucketized primary key's derived condition that removes none of it.
--
-- This is the configuration behind the largest regressions the old model
-- finds.  A merge scan ordered by c1 with the filter pushed down as a storage
-- filter is priced on the assumption that the LIMIT stops it early, and it
-- wins against a selective index scan plus a sort.  Whether that assumption
-- holds depends entirely on how wrong the row estimate is, which is the axis
-- merge-07 sweeps.
--
-- c7 and c8 are the instrument for that sweep.  c8 equals c7 in every row but
-- one, so with no extended statistics the estimator predicts about 50 rows
-- for any c7 = j AND c8 = k pair while the truth is 4999, 1 or 0 depending on
-- which pair is asked for.
create table sel (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));

create index sel_c3c1 on sel (c3 asc, c1 asc);
create index sel_c7c1 on sel (c7 asc, c1 asc);
create index sel_vc1 on sel (v asc, c1 asc);


-- =====================================================================
-- Merge scan: partitioning
-- =====================================================================
-- Time-range partitioning on top of a bucketized primary key is a realistic
-- combination, and it puts a merge scan under each Append/MergeAppend child.
-- The primary key must contain the partition key, which c1 satisfies.

create table pt (
  c0 int generated always as (yb_hash_code(c2) % 8) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) partition by range (c1);

create table pt_p1 partition of pt for values from (1) to (50001) split at values ((1),(2),(3),(4),(5),(6),(7));
create table pt_p2 partition of pt for values from (50001) to (100001) split at values ((1),(2),(3),(4),(5),(6),(7));
create table pt_p3 partition of pt for values from (100001) to (150001) split at values ((1),(2),(3),(4),(5),(6),(7));
create table pt_p4 partition of pt for values from (150001) to (200001) split at values ((1),(2),(3),(4),(5),(6),(7));


-- =====================================================================
-- Join partner
-- =====================================================================
-- Small enough to be an obvious build or outer side, indexed on the join keys
-- so the planner has a real choice of join order.  No bucket column: this
-- table is the other side of the join, not a subject of the feature.

create table dj (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2 asc)
) split at values ((5000),(10000),(15000));

create index dj_c1c2 on dj (c1 asc, c2 asc);


-- =====================================================================
-- Derived equalities
-- =====================================================================
-- de16 is the flagship shape: the bucket is generated from the entity id, so
-- a lookup by entity id can seek the primary key directly only if the planner
-- derives the bucket.  Verified on a build with skip scan, WHERE c2 = k still
-- reaches de16_pkey with the derivation off, but with only c2 as the index
-- condition, so the pair measures the seek the derivation buys rather than an
-- index scan against a full scan.  de16_c3c1 is a plain index on a column
-- with ndv 1000, which is not hot, so it coexists legitimately and gives the
-- CBO a real rival for OR and multi-predicate queries.

create table de16 (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c2 asc, c1 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));

create index de16_c3c1 on de16 (c3 asc, c1 asc);

-- Redundant derivations, in the spirit of the index in
-- yugabyte/yugabyte-db#31164 and as synthetic as that one.  c4 leads the key,
-- so an equality on c4 already seeks as far as the index can, and the three
-- expression keys after it are functions of c4 alone.  Each therefore gets a
-- derived equality that narrows nothing, and no path without those binds is
-- generated for the CBO to compare against.
create index de16_c4c1 on de16 (c4 asc, (c4 % 20) asc, (c4 + 1) asc, (c4 * 2) asc, c1 asc);

-- Two-column generation expression.  An equality on c2 alone cannot derive
-- the bucket, only the SAOP over all 8 of them, while equalities on both c2
-- and c6 derive a single bucket.  The key order puts c2 before c6 so the
-- partial case still has a usable index condition and the two cases differ
-- only in stream count.

create table de2c (
  c0 int generated always as (yb_hash_code(c2, c6) % 8) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c2 asc, c6 asc, c1 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7));

-- Expression index rather than a generated column.  Both derivations have a
-- separate code path for this form (ybDeriveSaopFromOpExpr reached directly
-- instead of through the generation expression), so it needs its own table.
-- The primary key is on the unique entity id, which is not monotone and so
-- not hot.

create table dex (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2 asc)
) split at values ((75000),(150000),(225000));

-- Two access patterns, each bucketized on the column that spreads its writes,
-- and neither replaceable by a plain index that would not be hot.
--
-- dex_c1c2 answers "the latest events overall": a plain (c1 asc) index would
-- put every insert on one shard, so the bucket comes first and a query with
-- no bucket predicate needs a derived SAOP and a merge to get c1 order.
create index dex_c1c2 on dex ((yb_hash_code(c2) % 8) asc, c1 asc, c2 asc) split at values ((1),(2),(3),(4),(5),(6),(7));

-- dex_c3c1 answers "one entity's events in time order", with c3 as the entity
-- (ndv 1000, so 300 rows each).  Here the derived equality is the whole
-- point: without it a lookup by entity cannot pin the bucket and has to visit
-- all eight, and with it the scan is one seek.
create index dex_c3c1 on dex ((yb_hash_code(c3) % 8) asc, c3 asc, c1 asc) split at values ((1),(2),(3),(4),(5),(6),(7));


-- =====================================================================
-- Rival index suite
-- =====================================================================
-- These two tables exist only to hold the configuration the rest of the
-- model refuses: a plain index on the very column the bucketized entity
-- orders by.  A user who bucketizes to escape a hot shard does not keep the
-- hot index, so this is not what the feature is for, and the coverage is
-- deliberately thin.  Each is a copy of a table elsewhere in the model with
-- exactly one index added, so the pairs (sa, riv) and (mb16, rivb) isolate
-- the rival index as the only variable.

create table riv (
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c2 asc)
) split at values ((125000),(250000),(375000));

create index riv_c6c1 on riv (c6 asc, c1 asc);
create index riv_c4c1 on riv (c4 asc, c1 asc);
create index riv_c3c1 on riv (c3 asc, c1 asc);

-- The rivals.  These two indexes are the only difference between riv and sa.
-- riv_c1 is the bare ordered index a deployment keeps for "the latest rows",
-- which answers an ORDER BY c1 with one seek but has to reach the table for
-- any filter column.  riv_c1c6 covers the c6-filtered listing as well, so the
-- merge has to beat a rival with no weakness at all.  Both are the hot index
-- that bucketing exists to remove, and both are here on purpose.
create index riv_c1 on riv (c1 asc);
create index riv_c1c6 on riv (c1 asc, c6 asc);

create table rivb (
  c0 int generated always as (yb_hash_code(c2) % 16) stored,
  c1 int not null, c2 int not null,
  c3 int, c4 int, c5 int, c6 int, c7 int, c8 int,
  v char(64),
  primary key (c0 asc, c1 asc, c2 asc)
) split at values ((1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15));

-- The rival, covering exactly what the bucketized primary key covers for an
-- ORDER BY c1 query, so neither side pays a table lookup the other avoids and
-- the comparison is streams against no streams and nothing else.  This is
-- literally the index the bucketized key replaced.
create index rivb_c1c2 on rivb (c1 asc, c2 asc);
