USE quickbite;

SELECT 'customers'   AS tbl, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'restaurants', COUNT(*) FROM restaurants
UNION ALL
SELECT 'riders',      COUNT(*) FROM riders
UNION ALL
SELECT 'orders',      COUNT(*) FROM orders
UNION ALL
SELECT 'complaints',  COUNT(*) FROM complaints;