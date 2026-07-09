CREATE TABLE t5m (id int, k1 int, k2 int, k3 int, v char(1536), PRIMARY KEY (id ASC));

CREATE INDEX NONCONCURRENTLY t5m_k1k2k3 ON t5m (k1 ASC, k2 ASC, k3 ASC);


-- ord table
CREATE TABLE ord (
  id      bigint,
  k1      int,
  k2      int,
  ts      timestamptz,
  status  text,
  amt     numeric(12,2),
  payload text,
  PRIMARY KEY (id ASC)
) SPLIT AT VALUES ((1000000), (2000000));

CREATE INDEX ord_k1_idx ON ord (k1 ASC) INCLUDE (k2);
CREATE INDEX ord_ts_idx ON ord (ts ASC);
CREATE INDEX ord_status_amt_idx ON ord (status ASC, amt DESC);


-- events table
CREATE TABLE events (
  id  bigint,
  grp int,
  ts  timestamptz,
  amt numeric(12,2),
  note text,
  PRIMARY KEY (id ASC)
) PARTITION BY RANGE (id);

CREATE TABLE events_p0 PARTITION OF events FOR VALUES FROM (0)      TO (100000);
CREATE TABLE events_p1 PARTITION OF events FOR VALUES FROM (100000) TO (200000);
CREATE TABLE events_p2 PARTITION OF events FOR VALUES FROM (200000) TO (300000);
CREATE TABLE events_p3 PARTITION OF events FOR VALUES FROM (300000) TO (400000);
CREATE TABLE events_p4 PARTITION OF events FOR VALUES FROM (400000) TO (500000);
CREATE TABLE events_p5 PARTITION OF events FOR VALUES FROM (500000) TO (600000);
CREATE TABLE events_p6 PARTITION OF events FOR VALUES FROM (600000) TO (700000);
CREATE TABLE events_p7 PARTITION OF events FOR VALUES FROM (700000) TO (800000);

CREATE INDEX events_grp_ts_idx ON events (grp, ts DESC);
CREATE INDEX events_ts_idx ON events (ts DESC) INCLUDE (amt);

-- events_h table
CREATE TABLE events_h (
  id  bigint,
  grp int,
  ts  timestamptz,
  amt numeric(12,2),
  note text,
  PRIMARY KEY (id HASH)
) PARTITION BY HASH (id);

CREATE TABLE events_h_p0 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 0);
CREATE TABLE events_h_p1 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 1);
CREATE TABLE events_h_p2 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 2);
CREATE TABLE events_h_p3 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 3);
CREATE TABLE events_h_p4 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 4);
CREATE TABLE events_h_p5 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 5);
CREATE TABLE events_h_p6 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 6);
CREATE TABLE events_h_p7 PARTITION OF events_h FOR VALUES WITH (modulus 8, remainder 7);

CREATE INDEX events_h_grp_ts_idx ON events_h (grp, ts DESC);
CREATE INDEX events_h_ts_idx    ON events_h (ts DESC) INCLUDE (amt);
