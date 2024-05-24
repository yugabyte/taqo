SELECT SUM(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= DATE '2024-01-01'
  AND l_shipdate < DATE '2024-04-01'
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_quantity < 24;