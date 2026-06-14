SELECT
    city,
    ROUND(SUM(order_amount), 2)    AS gross_revenue,
    ROUND(SUM(discount_applied), 2) AS total_discounts,
    ROUND(SUM(final_amount), 2)    AS net_revenue,
    ROUND(SUM(discount_applied) / SUM(order_amount) * 100, 2) AS discount_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY discount_pct DESC;