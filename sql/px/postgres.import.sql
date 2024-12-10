set client_min_messages=warning;
drop table if exists tmp1, tmp2, tmp3;

create temporary table tmp1 (id int, v int, primary key (id, v));
create temporary table tmp2 (id int, v int, primary key (id, v));
create temporary table tmp3 (id int, v int, primary key (id, v));

select setseed(0.777);

-- populate the tables with uniformly distributed column values randomly ordered.

-- 1m row table
insert into tmp1
  select row_number() over (order by random()) as id,
         i % (1000000 / 100) + 1 as v from generate_series(1, 1000000) i;

insert into tmp2
  select row_number() over (order by random()) as id,
         i % (1000000 / 10) + 1 as v from generate_series(1, 1000000) i;

insert into tmp3
  select row_number() over (order by random()) as id,
         i % (1000000 / 4) + 1 as v from generate_series(1, 1000000) i;

insert into t1m
  select row_number() over (), tmp1.v, tmp2.v, tmp3.v,
      lpad(sha512((tmp1.v#tmp2.v#tmp3.v)::bpchar::bytea)::bpchar, 1024, '-')
  from tmp1 join tmp2 using (id) join tmp3 using(id);


truncate table tmp1, tmp2, tmp3;

-- 10m row table
insert into tmp1
  select row_number() over (order by random()) as id,
         i % (10000000 / 100) + 1 as v from generate_series(1, 10000000) i;

insert into tmp2
  select row_number() over (order by random()) as id,
         i % (10000000 / 10) + 1 as v from generate_series(1, 10000000) i;

insert into tmp3
  select row_number() over (order by random()) as id,
         i % (10000000 / 4) + 1 as v from generate_series(1, 10000000) i;

insert into t10m
  select row_number() over (), tmp1.v, tmp2.v, tmp3.v,
      lpad(sha512((tmp1.v#tmp2.v#tmp3.v)::bpchar::bytea)::bpchar, 512, '-')
  from tmp1 join tmp2 using (id) join tmp3 using(id);

drop table tmp1, tmp2, tmp3;
