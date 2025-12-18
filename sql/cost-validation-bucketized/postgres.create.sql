--------------------------------
-- row count variation series --
--------------------------------

create table t100 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1));
create unique index t100_c2 on t100 (c2 asc);
create index t100_c3 on t100 (c3 asc);
create index t100_c4 on t100 (c4 asc);
create index t100_c6 on t100 (c6 asc);
create index t100_c2_c4 on t100 (c2 asc) include (c4);
create index t100_c2_c4v on t100 (c2 asc) include (c4, v);

create table t1000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1));
create unique index t1000_c2 on t1000 (c2 asc);
create index t1000_c3 on t1000 (c3 asc);
create index t1000_c4 on t1000 (c4 asc);
create index t1000_c6 on t1000 (c6 asc);
create index t1000_c2_c4 on t1000 (c2 asc) include (c4);
create index t1000_c2_c4v on t1000 (c2 asc) include (c4, v);

create table t10000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1));
create unique index t10000_c2 on t10000 (c2 asc);
create index t10000_c3 on t10000 (c3 asc);
create index t10000_c4 on t10000 (c4 asc);
create index t10000_c6 on t10000 (c6 asc);
create index t10000_c2_c4 on t10000 (c2 asc) include (c4);
create index t10000_c2_c4v on t10000 (c2 asc) include (c4, v);

create table t100000 (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(1024), primary key (c1));
create unique index t100000_c2 on t100000 (c2 asc);
create index t100000_c3 on t100000 (c3 asc);
create index t100000_c4 on t100000 (c4 asc);
create index t100000_c6 on t100000 (c6 asc);
create index t100000_c2_c4 on t100000 (c2 asc) include (c4);
create index t100000_c2_c4v on t100000 (c2 asc) include (c4, v);

create table t100000w (c1 int, c2 int not null, c3 int, c4 int, c5 int, c6 int, v char(8192), primary key (c1));
create unique index t100000w_c2 on t100000w (c2 asc);
create index t100000w_c3 on t100000w (c3 asc);
create index t100000w_c4 on t100000w (c4 asc);
create index t100000w_c6 on t100000w (c6 asc);
create index t100000w_c2_c4 on t100000w (c2 asc) include (c4);
create index t100000w_c2_c4v on t100000w (c2 asc) include (c4, v);


------------------------------
-- composite key test table --
------------------------------

create table t1000000m (c0 int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, primary key (c0));
create index t1000000m_c1c2c3c4 on t1000000m (c1 asc, c2 asc, c3 asc, c4 asc);
create index t1000000m_c4c2c3c1 on t1000000m (c4 asc, c2 asc, c3 asc, c1 asc);
create index t1000000m_c5 on t1000000m (c5 asc);
create index t1000000m_c6 on t1000000m (c6 asc);
create index t1000000m_c3c4c5 on t1000000m (c3 asc, c4 asc, c5 asc);
create index t1000000m_c5c4c3 on t1000000m (c5 asc, c4 asc, c3 asc);
