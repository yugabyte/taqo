# cost-validation

## Overview

This TAQO model contains sets of workloads for validating the query optimizer cost models. The queries are specifically designed to obtain the data points showing how the costs and the execution time change for each influencing factor such as the table row count, predicate selectivity, etc.

## TAQO Configuration
* By default, the framework stops executing the queries that takes longer than the best known plan while enumerating the plan choices. Set `look-near-best-plan` to `false` to disable this cutoff and collect the costs & the timing for all the plans. `test-query-timeout` may also have to be increased to capture the plans slower by absolute measure.

## Focus Areas and Query Patterns
# Table Access Paths (scans-xxx.sql)
* Single table queries
* Search condition placements:
  * No search condition: Seq Scan, Index Only Scan
  * Search condition on primary key: Seq Scan, Index Scan (PK)
  * Search condition on secondary index key: Seq Scan, Index Scan, Index Only Scan
  * The choices above + search condition on non-index key: relevant Scan + Remote Filter (YB specific)
* Selectivity variations: 0 row, 1 distinct value, 1/64, 1/8, 1/4, 1/2, 3/4, 1 (the entire table)
* Specific output row count variations: 0, 1, 10, 100, 1000, 10000, 100000 rows
* The scans-xxx-select0.sql variants have "select 0 from ..." pattern to minimize data volume related influences.
* Index choices:
  * Select a key column vs. non-key
  * Select a column at different positions
  * Missing search condition on the first key colum + equality on the second
  * Range search condition on the first key colum + equality on the second, different range condition variations
  * Search condition combinations with equalities/range/missing condition on the key prefix, middle key item
  * IN-list selecting the values in lower end/upper end/spread across the range, equality/range/IN-list x IN-list combinations
# Join Methods (xxxjoins.sql):
* Two table queries on a single equality predicate
* Only join key column(s) in the SELECT list to allow Index Only Scans whenever applicable
* Join types:
  * Inner join
  * Left join
  * Semijoin (via equality predicate correlated EXISTS subquery)
  * Antijoin (via equality predicate correlated NOT EXISTS subquery)
* Join fanout variations: 1:1, 1:5, 1:10
* Some or all non-matching row scenarios

# Explicit Sort vs. Ordered-row producing node
* Single table and two table inner join queries with ORDER BY on index key
* SELECT list item variations affect the sort buffer size

# HashAggregate vs. GroupAggregate (sort aggregate)
* Single table and two table inner join queries with GROUP BY and ORDER BY on index key
* SELECT list item variations affect the sort buffer/hash table size

# Index Only Scan + min/max optimizations
* min(k)/max(k) can be computed quickly using an index on (k ASC/DESC), however, Seq Scan may be faster with more aggregates to compute + when the table is fairly small.

# Bitmap Scans
* Bitmap Scans with nested conditions
* Bitmap Index Scans on multi-column indexes
* Bitmap Scans with index conditions and other pushable conditions
* Aggregates with Bitmap Scans. Only count(*) has an optimization for bitmap scans, so other aggregates may make more sense to use a sequential scan with aggregate pushdown. As the proportion of rows selected to the table size increases, sequential scan makes more and more sense.
* Bitmap Scans on primary keys
