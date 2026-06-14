USE quickbite;

-- ============================================================
-- CATEGORY 2: CITY-WISE PERFORMANCE (5 queries)
-- ============================================================

-- Query 6: Order volume and cancellation rate by city
SELECT
    city,
    COUNT(order_id)                                                        AS total_orders,
    SUM(order_status = 'Delivered')                                        AS delivered,
    SUM(order_status = 'Cancelled')                                        AS cancelled,
    SUM(order_status = 'Refunded')                                         AS refunded,
    ROUND(SUM(order_status = 'Cancelled') / COUNT(order_id) * 100, 2)     AS cancellation_pct
FROM orders
GROUP BY city
ORDER BY cancellation_pct DESC;
-- What it tells you: Which city has the worst cancellation problem.
-- High cancellation = bad customer experience or restaurant reliability issues.


-- Query 7: Average delivery time by city
SELECT
    city,
    ROUND(AVG(delivery_time_mins), 1)  AS avg_delivery_mins,
    MIN(delivery_time_mins)            AS fastest_delivery,
    MAX(delivery_time_mins)            AS slowest_delivery
FROM orders
WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY avg_delivery_mins ASC;
-- What it tells you: Which city delivers fastest. Useful for setting SLA targets
-- and identifying cities that need more riders.


-- Query 8: Average customer rating by city
SELECT
    city,
    ROUND(AVG(customer_rating), 2)  AS avg_rating,
    COUNT(customer_rating)          AS total_ratings,
    SUM(customer_rating = 5)        AS five_star,
    SUM(customer_rating <= 2)       AS low_ratings
FROM orders
WHERE customer_rating IS NOT NULL
GROUP BY city
ORDER BY avg_rating DESC;
-- What it tells you: Customer satisfaction per city.
-- Cities with low ratings need operational improvement.


-- Query 9: Payment method preference by city
SELECT
    city,
    payment_method,
    COUNT(order_id)                                          AS total_orders,
    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER
         (PARTITION BY city) * 100, 2)                      AS pct_of_city_orders
FROM orders
GROUP BY city, payment_method
ORDER BY city, total_orders DESC;
-- What it tells you: How each city prefers to pay.
-- UPI dominant everywhere? Or cash still strong in certain cities?


-- Query 10: Revenue per km (delivery efficiency) by city
SELECT
    city,
    ROUND(AVG(distance_km), 2)                              AS avg_distance_km,
    ROUND(SUM(final_amount) / SUM(distance_km), 2)          AS revenue_per_km
FROM orders
WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY revenue_per_km DESC;
-- What it tells you: Which city generates the most revenue per km travelled.
-- Low revenue/km = riders travelling far for small orders = inefficient.


-- ============================================================
-- CATEGORY 3: DELIVERY & RIDER PERFORMANCE (5 queries)
-- ============================================================

-- Query 11: Top 10 best rated riders
SELECT
    r.rider_id,
    r.rider_name,
    r.city,
    r.vehicle_type,
    r.rating                        AS profile_rating,
    COUNT(o.order_id)               AS total_deliveries,
    ROUND(AVG(o.customer_rating), 2) AS avg_customer_rating
FROM riders r
JOIN orders o ON r.rider_id = o.rider_id
WHERE o.order_status = 'Delivered'
  AND o.customer_rating IS NOT NULL
GROUP BY r.rider_id, r.rider_name, r.city, r.vehicle_type, r.rating
ORDER BY avg_customer_rating DESC, total_deliveries DESC
LIMIT 10;
-- What it tells you: Your star riders. High deliveries + high rating = reliable asset.


-- Query 12: Rider performance by vehicle type
SELECT
    r.vehicle_type,
    COUNT(DISTINCT r.rider_id)       AS total_riders,
    COUNT(o.order_id)                AS total_deliveries,
    ROUND(AVG(o.delivery_time_mins), 1) AS avg_delivery_mins,
    ROUND(AVG(o.customer_rating), 2)    AS avg_rating
FROM riders r
JOIN orders o ON r.rider_id = o.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY r.vehicle_type
ORDER BY avg_delivery_mins ASC;
-- What it tells you: Do bikes deliver faster than scooters?
-- Helps decide which vehicle type to recruit more of.


-- Query 13: Riders with most complaints
SELECT
    r.rider_id,
    r.rider_name,
    r.city,
    COUNT(c.complaint_id)   AS total_complaints,
    SUM(c.complaint_type = 'Rude Rider') AS rude_complaints,
    SUM(c.complaint_type = 'Late Delivery') AS late_complaints
FROM riders r
JOIN orders o  ON r.rider_id   = o.rider_id
JOIN complaints c ON o.order_id = c.order_id
GROUP BY r.rider_id, r.rider_name, r.city
ORDER BY total_complaints DESC
LIMIT 10;
-- What it tells you: Problem riders who need retraining or removal.


-- Query 14: Delivery time vs distance correlation buckets
SELECT
    CASE
        WHEN distance_km < 3  THEN 'Short (< 3km)'
        WHEN distance_km < 7  THEN 'Medium (3–7km)'
        WHEN distance_km < 12 THEN 'Long (7–12km)'
        ELSE 'Very Long (12km+)'
    END                                    AS distance_bucket,
    COUNT(order_id)                        AS total_orders,
    ROUND(AVG(delivery_time_mins), 1)      AS avg_delivery_mins,
    ROUND(AVG(customer_rating), 2)         AS avg_rating
FROM orders
WHERE order_status = 'Delivered'
GROUP BY distance_bucket
ORDER BY avg_delivery_mins ASC;
-- What it tells you: Do longer distances hurt ratings?
-- Sets realistic delivery time expectations by distance.


-- Query 15: Orders delivered late (> 60 mins) by city
SELECT
    city,
    COUNT(order_id)                                              AS late_orders,
    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER
         (PARTITION BY city) * 100, 2)                          AS late_pct
FROM orders
WHERE order_status = 'Delivered'
  AND delivery_time_mins > 60
GROUP BY city
ORDER BY late_orders DESC;
-- What it tells you: Which city has the most late deliveries.
-- Direct input for operational SLA improvement.


-- ============================================================
-- CATEGORY 4: CUSTOMER BEHAVIOUR (5 queries)
-- ============================================================

-- Query 16: Repeat customers (ordered more than 5 times)
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.is_premium,
    COUNT(o.order_id)              AS total_orders,
    ROUND(SUM(o.final_amount), 2)  AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city, c.is_premium
HAVING total_orders > 5
ORDER BY lifetime_value DESC
LIMIT 20;
-- What it tells you: Your most loyal high-value customers.
-- These are the people to target with retention offers.


-- Query 17: Premium vs non-premium customer comparison
SELECT
    c.is_premium,
    COUNT(DISTINCT c.customer_id)   AS total_customers,
    COUNT(o.order_id)               AS total_orders,
    ROUND(AVG(o.final_amount), 2)   AS avg_order_value,
    ROUND(AVG(o.discount_applied), 2) AS avg_discount,
    ROUND(AVG(o.customer_rating), 2)  AS avg_rating_given
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.is_premium;
-- What it tells you: Are premium customers actually more valuable?
-- Do they order more, spend more, rate better?


-- Query 18: Peak ordering hours
SELECT
    HOUR(order_time)        AS hour_of_day,
    COUNT(order_id)         AS total_orders,
    ROUND(AVG(final_amount), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY hour_of_day
ORDER BY total_orders DESC;
-- What it tells you: When do people order the most?
-- Lunch (12–2pm) and dinner (7–10pm) peaks should show clearly.
-- Use this to schedule more riders during peak hours.


-- Query 19: Customer age group analysis
SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 25 THEN '18–25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26–35'
        WHEN c.age BETWEEN 36 AND 45 THEN '36–45'
        ELSE '46+'
    END                             AS age_group,
    COUNT(DISTINCT c.customer_id)   AS total_customers,
    COUNT(o.order_id)               AS total_orders,
    ROUND(AVG(o.final_amount), 2)   AS avg_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY age_group
ORDER BY total_orders DESC;
-- What it tells you: Which age group orders the most and spends the most.
-- Shapes marketing and UI decisions.


-- Query 20: Gender-wise ordering pattern
SELECT
    c.gender,
    COUNT(DISTINCT c.customer_id)    AS total_customers,
    COUNT(o.order_id)                AS total_orders,
    ROUND(AVG(o.final_amount), 2)    AS avg_order_value,
    ROUND(SUM(o.final_amount), 2)    AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.gender
ORDER BY total_revenue DESC;
-- What it tells you: Gender-based ordering behaviour.
-- Useful for targeted campaigns and product decisions.


-- ============================================================
-- CATEGORY 5: COMPLAINT & RESOLUTION ANALYSIS (5 queries)
-- ============================================================

-- Query 21: Complaint breakdown by type
SELECT
    complaint_type,
    COUNT(complaint_id)                                              AS total_complaints,
    ROUND(COUNT(complaint_id) / SUM(COUNT(complaint_id)) OVER()
         * 100, 2)                                                   AS pct_of_total,
    SUM(refund_issued)                                               AS refunds_issued
FROM complaints
GROUP BY complaint_type
ORDER BY total_complaints DESC;
-- What it tells you: What are customers complaining about the most?
-- Late delivery vs wrong item vs food quality — each needs a different fix.


-- Query 22: Complaint resolution performance
SELECT
    resolution_status,
    COUNT(complaint_id)                  AS total,
    ROUND(AVG(resolution_days), 1)       AS avg_resolution_days,
    SUM(refund_issued)                   AS refunds_issued
FROM complaints
GROUP BY resolution_status
ORDER BY total DESC;
-- What it tells you: How fast are complaints being resolved?
-- High 'Pending' count = customer support is overwhelmed.


-- Query 23: Complaints by city
SELECT
    o.city,
    COUNT(c.complaint_id)                                            AS total_complaints,
    ROUND(COUNT(c.complaint_id) / COUNT(DISTINCT o.order_id)
         * 100, 2)                                                   AS complaint_rate_pct,
    SUM(c.refund_issued)                                             AS refunds_issued
FROM orders o
LEFT JOIN complaints c ON o.order_id = c.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.city
ORDER BY complaint_rate_pct DESC;
-- What it tells you: Which city complains the most relative to orders.
-- High complaint rate = operational or quality problem in that city.


-- Query 24: Restaurants with most complaints
SELECT
    r.restaurant_name,
    r.city,
    r.cuisine_type,
    COUNT(c.complaint_id)            AS total_complaints,
    SUM(c.complaint_type = 'Wrong Item')   AS wrong_items,
    SUM(c.complaint_type = 'Food Quality') AS food_quality,
    SUM(c.refund_issued)             AS refunds
FROM restaurants r
JOIN orders o     ON r.restaurant_id  = o.restaurant_id
JOIN complaints c ON o.order_id       = c.order_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
ORDER BY total_complaints DESC
LIMIT 10;
-- What it tells you: Problem restaurants dragging down quality.
-- These need performance reviews or delisting.


-- Query 25: Monthly complaint trend vs order volume
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')   AS month,
    COUNT(DISTINCT o.order_id)           AS total_orders,
    COUNT(c.complaint_id)                AS total_complaints,
    ROUND(COUNT(c.complaint_id) /
          COUNT(DISTINCT o.order_id) * 100, 2) AS complaint_rate_pct
FROM orders o
LEFT JOIN complaints c ON o.order_id = c.order_id
WHERE o.order_status = 'Delivered'
GROUP BY month
ORDER BY month;
-- What it tells you: Is complaint rate going up or down over time?
-- If orders grow but complaints grow faster = quality is slipping.