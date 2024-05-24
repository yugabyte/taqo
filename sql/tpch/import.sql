INSERT INTO region (r_regionkey, r_name, r_comment)
SELECT r_regionkey,
       r_name,
       'Comment for ' || r_name
FROM (VALUES (0, 'Africa'),
             (1, 'America'),
             (2, 'Asia'),
             (3, 'Europe'),
             (4, 'Middle East'),
             (5, 'Oceania')) AS regions(r_regionkey, r_name);

INSERT INTO nation (n_nationkey, n_name, n_regionkey, n_comment)
SELECT n_nationkey,
       n_name,
       n_regionkey,
       'Comment for ' || n_name
FROM (VALUES (0, 'Algeria', 0),
             (1, 'Argentina', 1),
             (2, 'Brazil', 1),
             (3, 'Canada', 1),
             (4, 'Egypt', 0),
             (5, 'Ethiopia', 0),
             (6, 'France', 3),
             (7, 'Germany', 3),
             (8, 'India', 2),
             (9, 'Indonesia', 2),
             (10, 'Iran', 4),
             (11, 'Iraq', 4),
             (12, 'Japan', 2),
             (13, 'Jordan', 4),
             (14, 'Kenya', 0),
             (15, 'Morocco', 0),
             (16, 'Mozambique', 0),
             (17, 'Peru', 1),
             (18, 'China', 2),
             (19, 'Saudi Arabia', 4),
             (20, 'Vietnam', 2),
             (21, 'Russia', 3),
             (22, 'United Kingdom', 3),
             (23, 'United States', 1),
             (24, 'Pakistan', 2),
             (25, 'Bangladesh', 2)) AS nations(n_nationkey, n_name, n_regionkey);

INSERT INTO part (p_partkey, p_name, p_mfgr, p_brand, p_type, p_size, p_container, p_retailprice, p_comment)
SELECT i,
       'Part ' || i,
       'Manufacturer ' || (i % 5),
       'Brand#' || (i % 50),
       p_type,
       (i % 50) + 1,
       'Cntr ' || (i % 10),
       (i * 10) % 1000 + 0.99,
       'Comment for part ' || i
FROM (SELECT i,
             CASE
                 WHEN i % 5 = 0 THEN 'Standard Part'
                 WHEN i % 5 = 1 THEN 'Small Part'
                 WHEN i % 5 = 2 THEN 'Medium Part'
                 WHEN i % 5 = 3 THEN 'Large Part'
                 WHEN i % 5 = 4 THEN 'Extra Large Part'
                 END AS p_type
      FROM generate_series(1, 200) AS s(i)) AS parts;

INSERT INTO supplier (s_suppkey, s_name, s_address, s_nationkey, s_phone, s_acctbal, s_comment)
SELECT i,
       'Supplier ' || i,
       'Address ' || i,
       i % 25,
       'Phone ' || i,
       (i * 100) % 2000 + 0.99,
       'Comment for supplier ' || i
FROM generate_series(1, 1000) AS s(i);

INSERT INTO partsupp (ps_partkey, ps_suppkey, ps_availqty, ps_supplycost, ps_comment)
SELECT p, s, (p + s) % 1000, (p * s) % 100 + 0.99, 'Comment for partsupp ' || p || ', ' || s
FROM generate_series(1, 200) AS p,
     generate_series(1, 100) AS s;

INSERT INTO customer (c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment)
SELECT i,
       'Customer ' || i,
       'Address ' || i,
       i % 25,
       'Phone ' || (i % 50),
       (i * 500) % 10000 + 0.99,
       'Segment ' || (i % 5),
       'Comment for customer ' || i
FROM generate_series(1, 15000) AS s(i);

INSERT INTO orders (o_orderkey, o_custkey, o_orderstatus, o_totalprice, o_orderdate, o_orderpriority, o_clerk,
                    o_shippriority, o_comment)
SELECT i,
       (i % 150) + 1,
       CASE (i % 2)
           WHEN 0 THEN 'P'
           ELSE 'O'
           END,
       (i * 1000) % 100000 + 0.99,
       '2024-01-01'::date + ((i % 365) * interval '1 day'),
       CASE (i % 5)
           WHEN 0 THEN '1-URGENT'
           WHEN 1 THEN '2-HIGH'
           WHEN 2 THEN '3-MEDIUM'
           WHEN 3 THEN '5-NORMAL'
           WHEN 4 THEN '6-RUSH'
           ELSE '7-IMMEDIATE'
           END,
       'Clerk ' || (i % 10),
       (i % 5),
       'Comment for order ' || i
FROM generate_series(1, 10000) AS s(i);

INSERT INTO lineitem (l_orderkey, l_partkey, l_suppkey, l_linenumber, l_quantity, l_extendedprice,
                      l_discount, l_tax, l_returnflag, l_linestatus, l_shipdate, l_commitdate,
                      l_receiptdate, l_shipinstruct, l_shipmode, l_comment)
SELECT o.o_orderkey,
       p.p_partkey,
       s.s_suppkey,
       l.l_linenumber,
       (l.l_linenumber % 50) + 1,
       (p.p_partkey * 1000) % 10000 + 0.99,
       (l.l_linenumber % 10) * 0.01,
       (l.l_linenumber % 5) * 0.01,
       CASE (l.l_linenumber % 2)
           WHEN 0 THEN 'R'
           ELSE 'N'
           END,
       CASE (l.l_linenumber % 2)
           WHEN 0 THEN 'P'
           ELSE 'O'
           END,
       '2024-01-01'::date + ((o.o_orderkey + p.p_partkey + l.l_linenumber) % 365 * interval '1 day'),
       '2024-01-01'::date + ((o.o_orderkey + p.p_partkey + l.l_linenumber + 7) % 365 * interval '1 day'),
       '2024-01-01'::date + ((o.o_orderkey + p.p_partkey + l.l_linenumber + 14) % 365 * interval '1 day'),
       'Instructions ' || (l.l_linenumber % 5),
       CASE (l.l_linenumber % 4)
           WHEN 0 THEN 'AIR'
           WHEN 1 THEN 'AIR REG'
           WHEN 2 THEN 'SHIP'
           ELSE 'MAIL'
           END,
       'Comment for lineitem ' || o.o_orderkey || ', ' || p.p_partkey || ', ' || l.l_linenumber
FROM orders o
         JOIN
         (SELECT p_partkey FROM part) p ON true
         JOIN
         (SELECT s_suppkey FROM supplier) s ON true
         JOIN
         (SELECT generate_series(1, 10) AS l_linenumber) l ON true
WHERE NOT EXISTS (SELECT 1
                  FROM lineitem li
                  WHERE li.l_orderkey = o.o_orderkey
                    AND li.l_partkey = p.p_partkey
                    AND li.l_suppkey = s.s_suppkey
                    AND li.l_linenumber = l.l_linenumber)
LIMIT 10000;