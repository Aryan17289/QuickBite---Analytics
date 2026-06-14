SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(final_amount), 2)       AS monthly_revenue,
    COUNT(order_id)                   AS total_orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY month
ORDER BY month;