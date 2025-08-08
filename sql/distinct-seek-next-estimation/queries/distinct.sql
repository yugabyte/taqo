-- No filters
SELECT DISTINCT k1 FROM tbl;
SELECT DISTINCT k2 FROM tbl;
SELECT DISTINCT k3 FROM tbl;

SELECT DISTINCT k1 FROM tbl2;
SELECT DISTINCT k2 FROM tbl2;
SELECT DISTINCT k3 FROM tbl2;
SELECT DISTINCT k4 FROM tbl2;

-- IN filter on the suffix columns
SELECT DISTINCT k1 FROM tbl WHERE k2 IN (2, 10, 18) AND k3 IN (11, 14, 17) AND k4 IN (3, 6, 9);
SELECT DISTINCT k1 FROM tbl WHERE k2 IN (2, 10, 18) AND k4 IN (3, 6, 9); -- seek forward optimization can help us land on k4 = 3
SELECT DISTINCT k1 FROM tbl WHERE k2 IN (2, 10, 18) AND k4 IN (4, 6, 9);
SELECT DISTINCT k2 FROM tbl WHERE k3 IN (11, 14, 17) AND k4 IN (3, 6, 9);
SELECT DISTINCT k3 FROM tbl WHERE k4 IN (4, 7, 10); -- Seq Scan is chosen, but the best plan is distinct index scan.

-- IN filter on the distinct column
SELECT DISTINCT k1 FROM tbl WHERE k1 IN (4, 7, 10);
SELECT DISTINCT k2 FROM tbl WHERE k2 IN (4, 7, 10);
SELECT DISTINCT k3 FROM tbl WHERE k3 IN (4, 7, 10);

-- IN filter on the prefix columns
SELECT DISTINCT k2 FROM tbl WHERE k1 IN (4, 7, 10);
SELECT DISTINCT k3 FROM tbl WHERE k1 IN (4, 7, 10) AND k2 IN (11, 14, 17);

-- Mix IN filters
SELECT DISTINCT k1 FROM tbl WHERE k1 IN (4, 7, 10) AND k2 IN (11, 14, 17) AND k3 IN (2, 10, 18) AND k4 IN (3, 9, 19);
SELECT DISTINCT k2 FROM tbl WHERE k1 IN (4, 7, 10) AND k2 IN (11, 14, 17) AND k3 IN (2, 10, 18) AND k4 IN (3, 9, 19);
SELECT DISTINCT k3 FROM tbl WHERE k1 IN (4, 7, 10) AND k2 IN (11, 14, 17) AND k3 IN (2, 10, 18) AND k4 IN (3, 9, 19);

-- Range filter on the suffix columns
SELECT DISTINCT k1 from tbl WHERE k4 >= 2 AND k4 <= 4 AND k3 >= 4 AND k3 <= 7 AND k2 >= 2 AND k2 <= 4;
SELECT DISTINCT k2 FROM tbl WHERE k4 >= 3 AND k4 <= 4 AND k3 >= 5 AND k3 <= 7;
SELECT DISTINCT k3 FROM tbl WHERE k4 >= 4 AND k4 <= 6;

-- Range filter on the distinct column
SELECT DISTINCT k1 FROM tbl WHERE k1 >= 3 AND k1 <= 7;
SELECT DISTINCT k2 FROM tbl WHERE k2 >= 3 AND k2 <= 7;
SELECT DISTINCT k3 FROM tbl WHERE k3 >= 3 AND k3 <= 7;

-- Range filter on the prefix columns
SELECT DISTINCT k2 FROM tbl WHERE k1 >= 2 AND k1 <= 4;
SELECT DISTINCT k3 FROM tbl WHERE k1 >= 2 AND k1 <= 4 AND k2 >= 4 AND k2 <= 7;

-- Mix Range filtrs
SELECT DISTINCT k3 FROM tbl WHERE k1 >= 2 AND k1 <= 4 AND k2 >= 4 AND k2 <= 7 AND k3 >= 2 AND k3 <= 10 AND k4 >= 3 AND k4 <= 13;
SELECT DISTINCT k3 FROM tbl WHERE k1 >= 2 AND k1 <= 4 AND k2 >= 4 AND k2 <= 7 AND k3 >= 2 AND k3 <= 10 AND k4 >= 4 AND k4 <= 13;

-- Equality filter on the suffix columns
SELECT DISTINCT k1 FROM tbl WHERE k2 = 10 AND k3 = 10;
SELECT DISTINCT k1 FROM tbl WHERE k2 = 10 AND k4 = 10;
SELECT DISTINCT k1 FROM tbl WHERE k4 = 10;
SELECT DISTINCT k2 FROM tbl WHERE k4 = 10;
SELECT DISTINCT k2 FROM tbl WHERE k3 = 10 AND k4 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k4 = 10; -- Seq Scan is chosen, but the best plan is distinct index scan.

-- Equality filter on the distinct column
SELECT DISTINCT k1 FROM tbl WHERE k1 = 10;
SELECT DISTINCT k2 FROM tbl WHERE k2 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k3 = 10;

-- Equality filter on the prefix columns
SELECT DISTINCT k2 FROM tbl WHERE k1 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k1 = 10 AND k2 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k2 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k1 = 10;

-- Mix Equality filters
SELECT DISTINCT k1 FROM tbl WHERE k1 = 10 AND k2 = 10;
SELECT DISTINCT k2 FROM tbl WHERE k1 = 10 AND k2 = 10 AND k3 = 10 AND k4 = 10;
SELECT DISTINCT k3 FROM tbl WHERE k1 = 10 AND k2 = 10 AND k3 = 10 AND k4 = 10;

-- Mix filter types
SELECT DISTINCT k2 FROM tbl WHERE k1 >= 1 AND k1 <= 4 AND k2 IN (4, 8, 10, 12) AND k3 >= 2 AND k3 <= 10 AND k4 >= 3 AND k4 <= 13;
SELECT DISTINCT k1 FROM tbl WHERE k2 IN (4, 7, 10) AND k3 >= 3 AND k3 <= 10 AND k4 IN (4, 8, 12);
SELECT DISTINCT k2 FROM tbl WHERE k3 >= 3 AND k3 <= 10 AND k4 IN (4, 8, 12);
SELECT DISTINCT k3 FROM tbl WHERE k1 IN (1, 4, 7) AND k2 >= 3 AND k2 <= 12;
SELECT DISTINCT k1 FROM tbl WHERE k1 = 4 and k2 IN (4, 8, 12, 16);
SELECT DISTINCT k2 FROM tbl WHERE k1 IN (4, 8, 12, 16) and k2 = 4;
SELECT DISTINCT k3 FROM tbl WHERE k3 IN (4, 8, 12, 16) and k4 = 4;
SELECT DISTINCT k2 FROM tbl WHERE k1 IN (4, 8, 12, 16) and k3 = 4;
