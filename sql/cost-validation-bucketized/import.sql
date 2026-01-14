--------------------------------
-- row count variation series --
--------------------------------
-- c1 pk (unique & non-null)
-- c2 unique & non-null
-- c3 value frequency=5 with nulls
-- c4 value frequency=10 with nulls
-- c5 unique & non-null, unconstrained, unindexed
-- c6 value frequency=100 with nulls
--   * the column values do not correlate one another

-- randomly order each column values using window functions.  vary
-- the window spec by adding an arbitrary constant so PG doesn't
-- reuse the frames for each column.

select setseed(0.222);
insert into t100
  select i, i2,
         nullif((i3+4)/5, (100+4)/5),
         nullif((i4+9)/10, (100+9)/10),
         i5,
         nullif((i6+99)/100, (100+99)/100),
         lpad(sha512(i5::text::bytea)||sha512(i::text::bytea)::text, 1024, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 100) i
    ) v order by 1;

-- might need to change the number of rows for the above case considering it has many different keys for the first table

select setseed(0.222);
insert into t1000
  select i, i2,
         nullif((i3+4)/5, (1000+4)/5),
         coalesce(nullif((i4+9)/10, (1000+9)/10), 0),
         i5,
         nullif((i6+99)/100, (1000+99)/100),
         lpad(sha512(i5::text::bytea)||sha512(i::text::bytea)::text, 1024, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 1000) i
    ) v order by 1;

select setseed(0.222);
insert into t10000
  select i, i2,
         nullif((i3+4)/5, (10000+4)/5),
         nullif((i4+9)/10, (10000+9)/10),
         i5,
         nullif((i6+99)/100, (10000+99)/100),
         lpad(sha512(i5::text::bytea)||sha512(i::text::bytea)::text, 1024, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 10000) i
    ) v order by 1;

select setseed(0.222);
insert into t100000
  select i, i2,
         nullif((i3+4)/5, (100000+4)/5),
         nullif((i4+9)/10, (100000+9)/10),
         i5,
         nullif((i6+99)/100, (100000+99)/100),
         lpad(sha512(i5::text::bytea)||sha512(i::text::bytea)::text, 1024, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 100000) i
    ) v order by 1;

select setseed(0.222);
insert into t100000w
  select i, i2,
         nullif((i3+4)/5, (100000+4)/5),
         nullif((i4+9)/10, (100000+9)/10),
         i5,
         nullif((i6+99)/100, (100000+99)/100),
         lpad(sha512(i5::text::bytea)||sha512(i::text::bytea)::text, 8192, '-')
    from (
      select i,
          row_number() over (order by random()) i2,
          row_number() over (order by random() + 1) i3,
          row_number() over (order by random() + 2) i4,
          row_number() over (order by random() + 3) i5,
          row_number() over (order by random() + 4) i6
        from generate_series(1, 100000) i
    ) v order by 1;


------------------------------
-- composite key test table --
------------------------------
-- c0: unique
-- c1: ndv=2 [50, 100]
-- c2: ndv=4 [25, 50, 75, 100]
-- c3: ndv=10 [10, 20, 30, .., 100]
-- c4: ndv=50 [2, 4, 6, .., 100]
-- c5: ndv=100000 [1, 2, 3, .., 100000]
-- c6: ndv=10000 [1, 2, 3, .., 10000]
--   * the column values do not correlate one another

select setseed(0.222);
insert into t1000000m
  select i, i1, i2, i3, i4, i5, i6
    from (
      select i,
          (row_number() over (order by random() + 1) % 2 + 1) * 50 i1,
          i + 1000000 i2,
          (row_number() over (order by random() + 3) % 10 + 1) * 10 i3,
          (row_number() over (order by random() + 4) % 50 + 1) * 2 i4,
          (row_number() over (order by random() + 5) % 100000 + 1) i5,
          (row_number() over (order by random() + 5) % 10000 + 1) i6
        from generate_series(1, 1000000) i
    ) v order by 1;
