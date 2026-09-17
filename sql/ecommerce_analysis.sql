-- E-COMMERCE ANALYTICS
-- Basic Business KPIs


-- Total Customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total Products
SELECT COUNT(*) AS total_products
FROM products;

-- Total Sellers
SELECT COUNT(*) AS total_sellers
FROM sellers;

-- Total Revenue
SELECT ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- Average Order Value
SELECT ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM payments
    GROUP BY order_id
) AS order_values;

-- Orders by Status

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Revenue by Payment Type

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Monthly Revenue

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- ============================================
-- PRODUCT CATEGORY PERFORMANCE
-- ============================================

SELECT
    COALESCE(ct.product_category_name_english,
             p.product_category_name,
             'unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY product_revenue DESC
LIMIT 10;

-- ============================================
-- CUSTOMER LOCATION & SALES PERFORMANCE
-- ============================================

SELECT
    c.customer_state AS state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ============================================
-- CUSTOMER REPEAT PURCHASE ANALYSIS
-- ============================================

-- ============================================
-- CUSTOMER REPEAT PURCHASE ANALYSIS
-- ============================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_segments AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN '1 Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count = 3 THEN '3 Orders'
            ELSE '4+ Orders'
        END AS customer_segment,
        COUNT(*) AS customers
    FROM customer_orders
    GROUP BY
        CASE
            WHEN order_count = 1 THEN '1 Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count = 3 THEN '3 Orders'
            ELSE '4+ Orders'
        END
)

SELECT
    customer_segment,
    customers
FROM customer_segments
ORDER BY
    CASE customer_segment
        WHEN '1 Order' THEN 1
        WHEN '2 Orders' THEN 2
        WHEN '3 Orders' THEN 3
        WHEN '4+ Orders' THEN 4
    END;
-- ============================================
-- DELIVERY PERFORMANCE
-- ============================================

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- ============================================
-- ON-TIME VS LATE DELIVERY
-- ============================================

SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- ============================================
-- CUSTOMER REVIEW ANALYSIS
-- ============================================

-- Review Score Distribution

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================
-- DELIVERY VS CUSTOMER SATISFACTION
-- ============================================

SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(r.review_id) AS reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- ============================================
-- SELLER PERFORMANCE
-- ============================================

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY revenue DESC
LIMIT 10;