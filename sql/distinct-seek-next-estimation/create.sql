CREATE TABLE tbl (k1 INT, k2 INT, k3 INT, k4 INT, PRIMARY KEY (k1 ASC, k2 ASC, k3 ASC, k4 ASC));
INSERT INTO tbl (SELECT s1, s2, s3, s4 FROM generate_series(1, 20) s1, generate_series(1, 20) s2, generate_series(1, 20) s3, generate_series(1, 20) s4);

CREATE TABLE tbl2 (k1 INT, k2 INT, k3 INT, k4 INT, k5 INT, PRIMARY KEY (k1 ASC, k2 ASC, k3 ASC, k4 ASC, k5 ASC));
INSERT INTO tbl2 (SELECT s1, s2, s3, s4, s5 FROM generate_series(1, 10) s1, generate_series(1, 10) s2, generate_series(1, 10) s3, generate_series(1, 10) s4, generate_series(1, 10) s5);
