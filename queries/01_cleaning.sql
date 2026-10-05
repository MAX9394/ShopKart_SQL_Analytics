-- 01_cleaning.sql : data quality checks + fixes (ShopKart)
-- Run top-to-bottom: sqlite3 shopkart.db < queries/01_cleaning.sql
-- Or: sqlite3 shopkart.db ".read queries/01_cleaning.sql"

-- Q1: NULL / empty cities (expect ~28, ~5% from generator)
SELECT COUNT(*) AS null_city_customers FROM customers WHERE city IS NULL OR city = '';
-- Fix: normalize to 'Unknown' (keeps GROUP BY clean later)
UPDATE customers SET city = 'Unknown' WHERE city IS NULL OR city = '';
-- Verify fix
SELECT COUNT(*) AS still_missing_city FROM customers WHERE city IS NULL OR city = '';

-- Q2: Duplicate emails (should be 0 due to UNIQUE, proves you checked)
SELECT email, COUNT(*) AS c FROM customers GROUP BY email HAVING c > 1;

-- Q3: Invalid business rows (should be 0 due to CHECK + generator)
SELECT * FROM order_items WHERE qty <= 0 OR discount_pct < 0 OR discount_pct > 90 LIMIT 10;

-- Q4: Order status split (business baseline)
SELECT status, COUNT(*) AS cnt,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct
FROM orders GROUP BY status;
