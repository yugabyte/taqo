create table t1 (k1 int, PRIMARY KEY (k1));
insert into t1 (select s1 from generate_series(1, 20) s1);

create table t2 (k1 int, k2 int, PRIMARY KEY (k1, k2));
insert into t2 (select s1, s2 from generate_series(1, 20) s1, generate_series(1, 20) s2);

create table t3 (k1 int, k2 int, k3 int, PRIMARY KEY (k1, k2, k3));
insert into t3 (select s1, s2, s3 from generate_series(1, 20) s1, generate_series(1, 20) s2, generate_series(1, 20) s3);

create table t4 (k1 int, k2 int, k3 int, k4 int, PRIMARY KEY (k1, k2, k3, k4));
insert into t4 (select s1, s2, s3, s4 from generate_series(1, 20) s1, generate_series(1, 20) s2, generate_series(1, 20) s3, generate_series(1, 20) s4);

create table t5 (k1 int, k2 int, k3 int, k4 int, k5 int, PRIMARY KEY (k1, k2, k3, k4, k5));
insert into t5 (select s1, s2, s3, s4, s5 from generate_series(1, 20) s1, generate_series(1, 20) s2, generate_series(1, 20) s3, generate_series(1, 20) s4, generate_series(1, 20) s5);