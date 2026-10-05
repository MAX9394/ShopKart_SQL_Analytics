-- 02_business_insights.sql : 7 core business questions (ShopKart)
-- Revenue always filters status='Delivered'. Run: sqlite3 shopkart.db ".read queries/02_business_insights.sql"

-- Q5: Monthly revenue + order trend (business health)
SELECT strftime('%Y-%m', o.order_date) AS month,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY 1 ORDER BY 1;

-- Q6: Top 5 products by revenue
SELECT p.name, p.category,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY 1, 2 ORDER BY revenue DESC LIMIT 5;

-- Q7: Category revenue + AOV
SELECT p.category,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue,
  ROUND(SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY 1 ORDER BY revenue DESC;

-- Q8: Top 10 customers by spend
SELECT c.customer_id, c.name, c.city,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS total_spend,
  COUNT(DISTINCT o.order_id) AS orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY 1, 2, 3 ORDER BY total_spend DESC LIMIT 10;

-- Q9: Repeat purchase rate
WITH cust_orders AS (
  SELECT customer_id, COUNT(*) AS n FROM orders
  WHERE status = 'Delivered' GROUP BY 1
)
SELECT ROUND(100.0 * SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM cust_orders;

-- Q10: Cancel/return rate by payment mode (operational insight)
SELECT payment_mode,
  COUNT(*) AS total,
  SUM(CASE WHEN status IN ('Cancelled','Returned') THEN 1 ELSE 0 END) AS failed,
  ROUND(100.0 * SUM(CASE WHEN status IN ('Cancelled','Returned') THEN 1 ELSE 0 END) / COUNT(*), 1) AS fail_pct
FROM orders GROUP BY 1 ORDER BY fail_pct DESC;

-- Q11: City-wise revenue (Top 8)
SELECT c.city,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(oi.qty * p.price * (1 - oi.discount_pct/100.0)) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY 1 ORDER BY revenue DESC LIMIT 8;
