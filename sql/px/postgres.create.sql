create table t1m (id int, k1 int, k2 int, k3 int, v char(8192), primary key (id));
create index t1m_k1k2k3 on t1m (k1 asc, k2 asc, k3 asc);

create table t10m (id int, k1 int, k2 int, k3 int, v char(8192), primary key (id));
create index t10m_k1k2k3 on t10m (k1 asc, k2 asc, k3 asc);
