SELECT 
    r.restaurant_name,
    r.city,
    r.cuisine_type,
    COUNT(o.order_id)             AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
ORDER BY total_revenue DESC
LIMIT 10;