-- 1. Monthly Revenue Trends per Category
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    p.category,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month, p.category
ORDER BY month, total_revenue DESC;

-- 2. Top 10 Customers by Lifetime Value
SELECT 
    c.customer_id,
    c.name,
    SUM(oi.quantity * oi.price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC
LIMIT 10;

-- 3. Repeat Purchase Rate
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT 
    ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_purchase_rate
FROM customer_orders;

-- 4. Rank Products by Profit Margin
SELECT 
    p.product_id,
    p.category,
    p.selling_price,
    p.cost_price,
    (p.selling_price - p.cost_price) AS profit_per_unit,
    RANK() OVER (PARTITION BY p.category ORDER BY (p.selling_price - p.cost_price) DESC) AS profit_rank
FROM products p;
