create table t1 (id int primary key, r1 int);
create index i_t1_r1 on t1 (r1 asc);

create table t2 (id int primary key, r1 int, r2 int not null);
create index i_t2_r2 on t2 (r2 asc);
create unique index u_t2_r1_r2 on t2 (r1 asc, r2 asc);

create table t3 (id int primary key, parent_id int, v text);
create index on t3 (parent_id);


insert into t1 values (0, null);
insert into t1 select i, i / 2 from generate_series(1, 1000) i;

insert into t2 values (0, null, 1);
-- id: unique, r1: even numbers, r2: 4, 1, 2, 3, 4, 1, 2, 3, ...
insert into t2 select i, (i + 1) / 2 * 2, (i + 2) % 4 + 1 from generate_series(1, 24) i;

-- ternary tree
insert into t3
  select
    i,
    case when i > 0 then (i - 1) / 3 else null end,
    'node-'||i::text
  from generate_series(0, 81) i;
