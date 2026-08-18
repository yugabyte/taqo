# cost-validation-bucketized-v2

A part of the cost-validation-xxx model series, covering merge scan and the
two derived-clause GUCs that sit alongside it.  It replaces
`cost-validation-bucketized`, which treated all three as one feature.

## What this model is for

Three planner GUCs drive what people call the bucketized-index feature, they
default to on, and they fail in different ways.  The old model mixed them into
the same tables and query files, so a finding could not be attributed to one
of them.  Here each query file targets exactly one, and the file name says
which:

| prefix | GUC under test |
|---|---|
| `merge-*` | `yb_max_merge_scan_streams` |
| `saop-*` | `yb_enable_derived_saops` |
| `eq-*` | `yb_enable_derived_equalities` |
| `rival-*` | the deliberately thin alternative-index suite, see below |

**Merge scan** is the main effort.  The cost model's only merge-specific
behavior today is multiplying the plain scan cost by 1.02 as a tie-breaker
placeholder (yugabyte/yugabyte-db#29078), so it charges the same for 2 streams
as for 64 while the executor's work grows with the count.  The instrument for
that is a controlled bucket-count sweep, which the old model had no equivalent
of.

**Derived SAOPs** can no longer regress a plan with no merge in it, since they
only attach to merge scan index paths, and the planner keeps the path without
the derivation alongside the one with it.  What is left to test is that cost
comparison.  Findings from it may not be merge-scan-specific at all: an index
scan preferred on the strength of a condition that passes every row is the
general symptom in #32317.

**Derived equalities** have open defects: no path without the derivation is
generated, so the CBO never gets a choice (#31164), and the derived expression
is never const-folded, so it becomes a runtime key and puts a spurious recheck
on bitmap scans (#31354).

## Design rules

1. **Hot-shard rule.**  A bucketized index exists because the plain range
   index on the same leading columns would concentrate every insert on one
   shard.  A deployment that has taken that trouble does not also keep the hot
   index.  So where a bucketized entity orders by `c1`, no plain index leading
   with `c1` exists on that table.  Plain indexes on non-monotone columns are
   allowed and used, because they are what a real schema has and they give the
   CBO a genuine rival.  `riv` and `rivb` break the rule on purpose and are
   the only tables that do.
2. **Bucketize what would actually be hot.**  `c1` is a monotone "event time"
   and is what every bucketized entity orders by.
3. **GUC-neutral query files.**  There is not a single `SET` in `queries/`.
   Comparison is done by running `collect` more than once with different
   database-level settings, per the matrix below.  This also avoids the leak
   the old model has, where `set enable_seqscan to false` in
   `bucketized-simple.sql` silently applies to every later query in that file.
4. **No user-written full-domain IN on a bucket column** except in
   `saop-02`, which exists to document that it is unstable (#33251).  Everywhere
   else the derivation is left to the planner.
5. **Every bucketized entity is pre-split at bucket boundaries**, the intended
   one-tablet-per-bucket layout, so measurements are not dominated by #33247.
   A base table whose primary key is not bucketized gets 4 tablets so a
   sequential scan is not artificially serialized.  Plain secondary indexes
   are left at the YB default of one tablet, which is what a user gets, and
   the files say where that makes a query #33247-exposed.
6. **Controlled pairs everywhere.**  Tables of the same row count hold
   identical data, so a difference between two results is a schema difference
   and never a data difference.

## Prerequisites

Merge scan requires the cost-based optimizer.  The database must have
`yb_enable_cbo = on` before any query runs, and the model does not set it,
because the GUC has been renamed once already and pinning it in a query file
would break on older and newer builds alike.  Set it on the database or
through `ysql_pg_conf_csv` on the tservers.  `ALTER DATABASE ... SET` takes
effect for new connections only.

## How to run

Load once, then run `collect` for each GUC setting with `--ddls=none` so the
data is untouched between legs:

```
python3 src/runner.py collect --model=cost-validation-bucketized-v2 \
  --config=config/default.conf --database=taqo --output=bktv2_on
# then, per leg: ALTER DATABASE taqo SET <guc> = <value>;
python3 src/runner.py collect --model=cost-validation-bucketized-v2 \
  --config=config/default.conf --database=taqo --ddls=none --output=bktv2_off
python3 src/runner.py report --type=regression --config=config/default.conf \
  --v1-results=report/bktv2_off.json --v2-results=report/bktv2_on.json
```

The legs worth taking, in order of value:

| leg | settings |
|---|---|
| everything on | defaults |
| merge scan off | `yb_max_merge_scan_streams = 0` (this also disables derived SAOPs) |
| derived SAOPs off | `yb_enable_derived_saops = off` |
| derived equalities off | `yb_enable_derived_equalities = off` |
| stream cap below the bucket count | `yb_max_merge_scan_streams = 15`, which removes merge scan from every 16-bucket table without touching the 2, 4 and 8 bucket ones |

For the cost report rather than a regression comparison, use
`--type=cost`.  Note that its index-key extraction assumes an index named
`<table>_<packed key columns>`, which this model follows, but it maps any
`_pkey` to a single key column `c1`, so column-position metrics on the
bucketized primary keys are not meaningful.

## Schema

Column roles are the same in every table:

| col | role |
|---|---|
| `c0` | bucket, `generated always as (yb_hash_code(...) % B) stored` |
| `c1` | monotone 1..N, the "event time", what bucketized entities order by |
| `c2` | unique permutation of 1..N, the "entity id", the hash input |
| `c3` | ndv 1000 |
| `c4` | ndv 100 |
| `c5` | unique permutation, never indexed |
| `c6` | ndv 10 |
| `c7` | ndv 100 |
| `c8` | `c7` in every row but the first, where it is `c7 + 1` |
| `v` | `char(64)`, or `char(4096)` on `mw16` |

| table | rows | tablets | why it exists |
|---|---|---|---|
| `mb2` `mb4` `mb16` `mb64` | 500 K each | 2 / 4 / 16 / 64 | the sweep: identical data, PK `(c0, c1, c2)`, no other index |
| `mplain` | 500 K | 16 | the sweep's control: same rows, PK `(c1)`, no streams |
| `mn16` `mw16` | 50 K each | 16 | the width pair, `char(64)` against `char(4096)` |
| `ms16` | 300 K | 16 | PK `(c0, c6, c1)`: streams are 16 x the IN list, crossing the 64 cap |
| `sa` | 500 K | 4 | no bucketization at all, indexes on `(c6,c1)`, `(c4,c1)`, `(c3,c1)`: merge scan on user IN lists, isolated from both derived GUCs |
| `sel` | 500 K | 16 | bucketized PK plus selective plain indexes on `c3`, `c7`, `v`: the LIMIT bet against a real rival |
| `pt` | 200 K | 4 x 8 | range partitioned by `c1` over a bucketized PK |
| `dj` | 20 K | 4 | join partner, `c1` and `c2` both cover 1..20000 |
| `de16` | 500 K | 16 | derived equalities, one-column generation expression |
| `de2c` | 300 K | 8 | two-column generation expression: partial against full derivation |
| `dex` | 300 K | 4 | expression indexes, no generated column |
| `riv` | 500 K | 4 | `sa` plus a plain `(c1)` and a covering `(c1, c6)` |
| `rivb` | 500 K | 16 | `mb16` plus a covering plain `(c1, c2)` |

6.22 M rows, measured at 1954 MB of logical size including indexes on a
freshly loaded cluster.  The old model loads about a third fewer rows but
most of them carry a 1 KB or 8 KB payload, so it is several times heavier.
`analyze.sql` creates no extended statistics on purpose: a statistics object
over `c7` and `c8` would remove the estimate error the model is built to
sweep.

## Query suites

665 queries in 17 files.

**Merge scan.**
`merge-01-bucket-sweep` repeats one query grid across all four bucket counts
and the control.  `merge-02-limit-and-aggregates` sweeps LIMIT across the
1024-row fetch page and then removes the LIMIT from the scan's reach.
`merge-03-width` is the width pair.  `merge-04-user-inlist` is merge scan on
user-written IN lists with no bucketization anywhere, each paired with a
`BETWEEN` twin that selects the same rows and cannot merge.
`merge-05-stream-product` multiplies the derived bucket SAOP by a user IN
list, across the cap.  `merge-06-order-shapes` varies who is buying the
ordering.  `merge-07-limit-bets` is described below.  `merge-08-joins` puts
the merge inside joins, and `merge-09-partitioned` under an Append.

**Derived SAOPs.**  `saop-01-arbitration` pairs queries where the derivation
earns its cost with queries where nothing above the scan wants an order.
`saop-02-user-vs-derived` writes out the condition the planner would derive,
documenting #33251.  `saop-03-join-order-flip` reproduces #32317: with the GUC
on the plan is a batched nested loop whose outer is a 16-stream merge over
`mw16` with the filter attached, and with it off the plan drives from `dj`.

**Derived equalities.**  `eq-01-point-and-range` is the lookup that only works
if the bucket is derived.  `eq-02-joins` is the same on the inner side of a
nested loop, which is where the derivation is not an optimization but the
thing that makes the schema usable.  `eq-03-or-and-bitmap` covers the separate
OR-arm derivation path and the #31354 runtime key.  `eq-04-derivation-overhead`
is #31164: derivations that add binds without narrowing anything, and streams
planned that bind-time pruning removes.

**Rival index.**  `rival-01-alt-index` is the one file where a plain ordered
index on the sort column coexists with the bucketized entity.  It is thin on
purpose: a deployment that bucketized to escape a hot shard does not keep the
hot index, and an honest per-stream cost model handles this case as a
byproduct of getting the streams right.  It is here because the configuration
does occur in half-migrated schemas and in benchmark models, and because the
right answer is unambiguous.

### About `merge-07-limit-bets`

The largest regression the old model finds is `v LIKE 'zz%' ORDER BY c1, c2
LIMIT 10`, at 1349x: a 3-stream merge with the LIKE as a storage filter costed
at 124 against 2851 for a selective index scan plus a sort, then scanning all
1000000 rows to return nothing.

It is tempting to read that as a bug about empty results.  It is not.  In that
run the regression rate is flat across output sizes, 29 % of queries returning
no rows, 31 % returning one, 30 % returning 11 to 100, 29 % returning 101 to
10000, falling away only above 10000 rows.  Returning nothing does not cause
the wrong plan, it removes the early exit that would have hidden it.  So this
file sweeps the estimate error rather than camping on the corner.  `c8` equals
`c7` in every row but the first, and with no extended statistics the estimator
predicts about 50 rows for all three of these:

| predicate | actual rows | estimate is |
|---|---|---|
| `c7 = 2 AND c8 = 2` | 4999 | about 100x too low |
| `c7 = 2 AND c8 = 3` | 1 | about 50x too high |
| `c7 = 50 AND c8 = 51` | 0 | infinitely too high |

Each runs against `sel`, where a selective rival path exists and the question
is whether the CBO picks it, against `mb16`, where the merge is the only path
and the question is what the bad bet costs, and against `mplain`, the floor.

## Writing queries for this model

Three constraints come from the framework's parser in `src/models/sql.py`:

- Queries are split on `;` before comments are stripped, so a semicolon must
  never appear inside a comment.
- `sqlparse.format(..., strip_comments=True)` removes `/*+ ... */`, so
  pg_hint_plan hints cannot be embedded in a query file.
- A bare `SET` becomes a debug query applied to every later query in the same
  file, with no way to scope it.  This model has none.

A join query must use aliases for every table or for none.

## Issue index

| issue | what it is | where it shows |
|---|---|---|
| #29078 | merge scan costing is a 1.02 placeholder | `merge-01`, `merge-02`, `merge-03`, `merge-05` |
| #31163 | decouple derived SAOPs from merge scan | widens `saop-01` when it lands |
| #31164 | no non-derived path is generated | `eq-04` |
| #31354 | derived expressions are not const-folded | `eq-03`, visible in every `eq-*` plan |
| #32317 | index scan preferred on a 100 %-passing condition | `saop-01`, `saop-03` |
| #33247 | streams sharing a tablet split one response budget | flagged in `merge-04` and `merge-05` |
| #33251 | full-domain IN estimate flips across ANALYZE runs | `saop-02` |

## Verified

Against a single-node RF1 cluster on release binaries, version string
`PostgreSQL 15.12-YB-2.31.0.0-b0`, build revision
`5eae1e456c2198a7a50b6db33cb225bee674e17b`, with `yb_enable_cbo = on`:

- `create.sql`, `import.sql` and `analyze.sql` apply with no errors, and every
  pre-split entity reports the intended tablet count through
  `yb_table_properties`: 2, 4, 16 and 64 across the sweep, 16 for the other
  16-bucket tables and for the `mplain` control, 8 for `de2c`, for each `pt`
  partition and for both bucketized indexes on `dex`, 4 for the base tables
  whose primary key is not bucketized, and 1 for every plain secondary index.
- `postgres.create.sql` applies without error as a syntax check, though on YB
  rather than on upstream.
- All 665 queries pass `EXPLAIN (VERBOSE, COSTS OFF)` with no errors.  336 of
  them produce a merge scan, 70 produce a derived-equality index condition,
  and 26 produce a bitmap plan.  No query mixes aliased and unaliased tables.
- All 665 also pass `EXPLAIN (ANALYZE, DIST)` with no errors, one pass costing
  74 seconds of wall time and 30.6 seconds of measured execution.  The slowest
  single query is 1.1 seconds.  At the framework's default of one warmup plus
  five retries, a `collect` run should be well inside 15 minutes of query time.
- Every data fact this README and the query comments assert was checked
  against the loaded data: the `c7`/`c8` ladder at 4999, 1 and 0 rows,
  `length(v)` constant at 64 with `LIKE 'zz%'` matching nothing and
  `LIKE '--%'` matching all 500000, ndv of 1000, 100 and 10 on `c3`, `c4` and
  `c6`, bucket occupancy even to within 2.5 % at 64 buckets, `mb16` and
  `mplain` holding byte-identical rows, and `dj` matching 20000 rows on both
  `c1` and `c2`.

Three findings the instrument produced on that build, recorded because they
show it is measuring what it was built to measure rather than because they are
conclusions:

- `SELECT c1, c2 FROM mb64 ORDER BY c1 LIMIT 1000` scans 64000 rows against
  `mplain`'s 1000 for the same result, because every stream is handed the full
  LIMIT.  The cost model prices the two within 2 % of each other.
- On `rivb`, whose covering plain `(c1, c2)` index answers `ORDER BY c1 LIMIT
  10` by scanning 10 rows, the CBO prefers the 16-stream merge over the
  bucketized primary key at cost 22.34 against 51.13, and that plan scans 160.
- The #32317 join-order flip reproduces exactly: with derived SAOPs on, the
  plan is a batched nested loop whose outer is a 16-stream merge over `mw16`
  with the opaque filter attached, estimated at 3499, and with them off it
  drives from `dj` and reaches `mw16` through a derived-equality index
  condition, estimated at 5946.
