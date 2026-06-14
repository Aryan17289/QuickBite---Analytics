SELECT 
    r.cuisine_type,
    COUNT(o.order_id)             AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(AVG(o.final_amount), 2) AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC;