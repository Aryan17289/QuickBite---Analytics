USE quickbite;

SELECT 
    city,
    COUNT(order_id)            AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(AVG(final_amount), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY total_revenue DESC;