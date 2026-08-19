-- Data load for cost-validation-bucketized-v2.
--
-- Every table uses the same generator, so tables of the same row count hold
-- identical data.  That is what makes the model's controlled pairs work:
-- mb2/mb4/mb16/mb64/mplain/rivb/sa/riv all hold the same 500000 rows and
-- differ only in schema, so any difference in a result is a schema
-- difference, never a data difference.
--
-- Column values, for a table of N rows:
--   c1 = i, the monotone 1..N "event time"
--   c2 = a permutation of 1..N, unique, the hash input
--   c3 = ndv 1000, an independent permutation folded mod 1000
--   c4 = ndv 100, likewise
--   c5 = a permutation of 1..N, unique, never indexed
--   c6 = ndv 10, likewise
--   c7 = i % 100 + 1, ndv 100
--   c8 = c7 in every row except i = 1, where it is c7 + 1.  With no extended
--        statistics the estimator multiplies two independent 1/100
--        selectivities and predicts about N/10000 rows for any c7 = j AND
--        c8 = k pair, while the truth is N/100 - 1 rows when j = k, exactly
--        one row for the single pair (2, 3), and nothing for every other
--        pair.  Three points of estimate error under one estimate, which is
--        the axis merge-07 sweeps.
--   v  = exactly 64 characters (4096 on mw16), left-padded with '-', so
--        length(v) = 64 matches every row and any other length matches none.
--
-- The permutations come from window functions over random() after setseed,
-- which is reproducible for a given row count.  Each insert reseeds so the
-- statements are order independent.


-- ---------------------------------------------------------------------
-- Bucket count sweep, plus its control and its rival-suite copy.
-- Identical data, 500000 rows.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into mb2 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into mb4 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into mb16 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into mb64 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into mplain (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into rivb (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- User-written IN list tables, and the rival-suite copy of sa.
-- Identical data to the sweep, 500000 rows.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into sa (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into riv (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- Estimate-error table, 500000 rows, identical to the sweep tables.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into sel (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- Derived equality tables.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into de16 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 500000) i
    ) s order by 1;

select setseed(0.222);
insert into de2c (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 300000) i
    ) s order by 1;

select setseed(0.222);
insert into dex (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 300000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- Stream product table, 300000 rows.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into ms16 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 300000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- Partitioned table, 200000 rows spread evenly over the four partitions.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into pt (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 200000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- The width pair, 50000 rows each, identical apart from the width of v.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into mn16 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 50000) i
    ) s order by 1;

select setseed(0.222);
insert into mw16 (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 4096, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 50000) i
    ) s order by 1;


-- ---------------------------------------------------------------------
-- Join partner, 20000 rows.  Its c1 covers 1..20000, so joining it to any
-- other table on c1 matches the first 20000 rows of that table exactly once.
-- ---------------------------------------------------------------------

select setseed(0.222);
insert into dj (c1, c2, c3, c4, c5, c6, c7, c8, v)
  select i, i2, i3 % 1000 + 1, i4 % 100 + 1, i5, i6 % 10 + 1,
         i % 100 + 1, case when i = 1 then i % 100 + 2 else i % 100 + 1 end,
         lpad(md5(i::text), 64, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 20000) i
    ) s order by 1;
