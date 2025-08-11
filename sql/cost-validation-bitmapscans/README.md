# bitmapscans

## Overview

This TAQO model contains sets of workloads for validating the query optimizer cost models for bitmap scans. The queries are specifically designed to obtain the data points showing how the costs and the execution time change for each influencing factor on bitmap scans such as the table row count, predicate selectivity, etc.

## TAQO Configuration
* By default, the framework stops executing the queries that takes longer than the best known plan while enumerating the plan choices. Set `look-near-best-plan` to `false` to disable this cutoff and collect the costs & the timing for all the plans. `test-query-timeout` may also have to be increased to capture the plans slower by absolute measure.

## Focus Areas and Query Patterns
# Bitmap Scan vs Index Scan (bitmap-vs-index.sql)
* Varying selectivity with AND conditions
* Varying selectivity with AND conditions and a pushable OR condition
* Aggregates
* Limits

# Bitmap Scan vs Index Only Scan (bitmap-vs-index-only.sql)
* Varying selectivity with AND conditions
* Varying selectivity with AND conditions and a pushable OR condition
* Aggregates
* Limits

# Bitmap Scan vs Sequential Scan (bitmap-vs-sequential.sql)
* Varying selectivity with AND conditions
* Varying selectivity with OR conditions
* Aggregates
* Limits

# Bitmap Scan approaching work_mem (bitmap-work-mem.sql)
* Simple bitmap scans just below/around/above work_mem

# Bitmap Scans with remote filters
* Bitmap scans where additional filters may be pushed down to the Bitmap Index Scans
