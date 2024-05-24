SELECT o_year,
       SUM(CASE
               WHEN nation = 'India' THEN volume
               ELSE 0
           END) / SUM(volume) AS mkt_share
FROM (SELECT EXTRACT(YEAR FROM o_orderdate)     AS o_year,
             l_extendedprice * (1 - l_discount) AS volume,
             n2.n_name                          AS nation
      FROM part,
           supplier,
           lineitem,
           orders,
           customer,
           nation n1,
           nation n2,
           region
      WHERE p_partkey = l_partkey
        AND s_suppkey = l_suppkey
        AND l_orderkey = o_orderkey
        AND o_custkey = c_custkey
        AND c_nationkey = n1.n_nationkey
        AND n1.n_regionkey = r_regionkey
        AND r_name = 'Asia'
        AND s_nationkey = n2.n_nationkey
        AND p_type = 'Extra Large Part'
        AND o_orderdate BETWEEN DATE '2023-01-01' AND DATE '2023-12-31') AS all_nations
GROUP BY o_year
ORDER BY o_year;