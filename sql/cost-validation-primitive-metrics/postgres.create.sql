------------------------------
-- decimal type test tables --
------------------------------
-- ndv=10000

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

create index t1000000d10_v on t1000000d10 (v asc);
create index t1000000d20_v on t1000000d20 (v asc);
create index t1000000d30_v on t1000000d30 (v asc);
create index t1000000d40_v on t1000000d40 (v asc);
create index t1000000d50_v on t1000000d50 (v asc);
create index t1000000d60_v on t1000000d60 (v asc);
create index t1000000d70_v on t1000000d70 (v asc);
create index t1000000d80_v on t1000000d80 (v asc);
create index t1000000d90_v on t1000000d90 (v asc);
create index t1000000d100_v on t1000000d100 (v asc);

insert into t1000000d10 select (power(10::decimal, 10) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d20 select (power(10::decimal, 20) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d30 select (power(10::decimal, 30) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d40 select (power(10::decimal, 40) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d50 select (power(10::decimal, 50) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d60 select (power(10::decimal, 60) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d70 select (power(10::decimal, 70) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d80 select (power(10::decimal, 80) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d90 select (power(10::decimal, 90) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;
insert into t1000000d100 select (power(10::decimal, 100) - (i % 100) - 1) / 10000 from generate_series(1, 1000000) i;


------------------------------------------------------
-- int/float tables for comparison against decimals --
------------------------------------------------------
-- ndv=10000

create table t1000000i (v integer);
create table t1000000bi (v bigint);
create table t1000000flt (v real);
create table t1000000dbl (v double precision);

create index t1000000i_v on t1000000i (v asc);
create index t1000000bi_v on t1000000bi (v asc);
create index t1000000flt_v on t1000000flt (v asc);
create index t1000000dbl_v on t1000000dbl (v asc);

insert into t1000000i select (i % 100) + 1 from generate_series(1, 1000000) i;
insert into t1000000bi select (i % 100) + 1 from generate_series(1, 1000000) i;
insert into t1000000flt select (i % 100) + 1 from generate_series(1, 1000000) i;
insert into t1000000dbl select (i % 100) + 1 from generate_series(1, 1000000) i;


--------------------------------------
-- column/value position test table --
--------------------------------------
-- c0 pk (unique & non-null)
-- c1..c9 (unique & non-null, unconstrained)
--   * all the columns have the same value in each row

create table t1000000c10 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int, c9 int, primary key (c0));
create index t1000000c10_c1_c0c2c3c4c5c6c7c8c9 on t1000000c10 (c1 asc) include (c0, c2, c3, c4, c5, c6, c7, c8, c9);
create index t1000000c10_c5_c0c2c3c4c1c6c7c8c9 on t1000000c10 (c5 asc) include (c0, c2, c3, c4, c1, c6, c7, c8, c9);

insert into t1000000c10
  select i, i, i, i, i, i, i, i, i, i from generate_series(1, 1000000) i;


------------------------------
-- column count test tables --
------------------------------

create table t1000000c01 (c0 int);
create table t1000000c02 (c0 int, c1 int);
create table t1000000c03 (c0 int, c1 int, c2 int);
create table t1000000c04 (c0 int, c1 int, c2 int, c3 int);
create table t1000000c05 (c0 int, c1 int, c2 int, c3 int, c4 int);
create table t1000000c06 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int);
create table t1000000c07 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int);
create table t1000000c08 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int);
create table t1000000c09 (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int);

insert into t1000000c01 select c0 from t1000000c10;
insert into t1000000c02 select c0, c1 from t1000000c10;
insert into t1000000c03 select c0, c1, c2 from t1000000c10;
insert into t1000000c04 select c0, c1, c2, c3 from t1000000c10;
insert into t1000000c05 select c0, c1, c2, c3, c4 from t1000000c10;
insert into t1000000c06 select c0, c1, c2, c3, c4, c5 from t1000000c10;
insert into t1000000c07 select c0, c1, c2, c3, c4, c5, c6 from t1000000c10;
insert into t1000000c08 select c0, c1, c2, c3, c4, c5, c6, c7 from t1000000c10;
insert into t1000000c09 select c0, c1, c2, c3, c4, c5, c6, c7, c8 from t1000000c10;


---------------------------
-- row width test tables --
---------------------------

create table t100000w125 (v varchar(8000));
create table t100000w250 (v varchar(8000));
create table t100000w500 (v varchar(8000));
create table t100000w1k (v varchar(8000));
create table t100000w2k (v varchar(8000));
create table t100000w3k (v varchar(8000));
create table t100000w4k (v varchar(8000));
create table t100000w5k (v varchar(8000));
create table t100000w6k (v varchar(8000));
create table t100000w7k (v varchar(8000));
create table t100000w8k (v varchar(8000));

insert into t100000w8k
    select
        repeat((power(10::decimal, 100) - (i % 100) - 1)::decimal(100,0)::text, 80)
    from generate_series(1, 100000) i;

insert into t100000w125 select substring(v, 1, 125) from t100000w8k;
insert into t100000w250 select substring(v, 1, 250) from t100000w8k;
insert into t100000w500 select substring(v, 1, 500) from t100000w8k;
insert into t100000w1k select substring(v, 1, 1000) from t100000w8k;
insert into t100000w2k select substring(v, 1, 2000) from t100000w8k;
insert into t100000w3k select substring(v, 1, 3000) from t100000w8k;
insert into t100000w4k select substring(v, 1, 4000) from t100000w8k;
insert into t100000w5k select substring(v, 1, 5000) from t100000w8k;
insert into t100000w6k select substring(v, 1, 6000) from t100000w8k;
insert into t100000w7k select substring(v, 1, 7000) from t100000w8k;
