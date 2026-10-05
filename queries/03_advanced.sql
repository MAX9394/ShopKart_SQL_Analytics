-- 03_advanced.sql : window functions + CTE + view (ShopKart)
-- Run: sqlite3 shopkart.db ".read queries/03_advanced.sql"

-- Q12: Rank products within each category (RANK window) -- proves window functions
SELECT category, name, revenue, rnk FROM (
  SELECT p.category, p.name,
    SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) DESC) AS rnk
  FROM products p
  JOIN order_items oi ON oi.product_id = p.product_id
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.status = 'Delivered'
  GROUP BY p.category, p.name
) WHERE rnk <= 3 ORDER BY category, rnk;

-- Q13: Monthly running total (SUM OVER) -- proves running totals
WITH monthly AS (
  SELECT strftime('%Y-%m', o.order_date) AS month,
    SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = 'Delivered'
  GROUP BY 1
)
SELECT month, ROUND(revenue, 2) AS revenue,
  ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly ORDER BY month;

-- Q14: High-value loyalists (CTE + HAVING) -- proves business filtering
WITH spend AS (
  SELECT c.customer_id, c.name, COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS total,
    AVG(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS avg_order
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = 'Delivered'
  GROUP BY 1, 2 HAVING COUNT(DISTINCT o.order_id) >= 3
)
SELECT * FROM spend WHERE total > 10000 ORDER BY total DESC LIMIT 20;

-- Q15: Reusable view
CREATE VIEW IF NOT EXISTS vw_monthly_revenue AS
SELECT strftime('%Y-%m', o.order_date) AS month,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered' GROUP BY 1;

-- Tuning note (EXPLAIN QUERY PLAN):
-- WITH index:    SEARCH orders USING INDEX idx_orders_date (order_date>?)
-- WITHOUT index: SCAN orders
-- idx_items_product similarly gives SEARCH order_items USING INDEX idx_items_product (product_id=?)
-- Q5 full GROUP BY still SCANs (no selective WHERE) + USE TEMP B-TREE FOR GROUP BY, as expected.
