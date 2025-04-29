CREATE TABLE t5m (id int, k1 int, k2 int, k3 int, v char(1536), PRIMARY KEY (id));

CREATE INDEX t5m_k1k2k3 ON t5m (k1 ASC, k2 ASC, k3 ASC);
