-- shopkart schema (SQLite, PostgreSQL-compatible)
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  city TEXT,
  tier TEXT NOT NULL CHECK (tier IN ('Silver','Gold','Platinum')) DEFAULT 'Silver',
  signup_date DATE NOT NULL
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price > 0),
  cost INTEGER NOT NULL CHECK (cost >= 0),
  CHECK (price >= cost)
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  order_date DATE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Delivered','Cancelled','Returned')) DEFAULT 'Delivered',
  payment_mode TEXT NOT NULL CHECK (payment_mode IN ('UPI','Card','COD','NetBanking'))
);

CREATE TABLE order_items (
  order_item_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  qty INTEGER NOT NULL CHECK (qty > 0),
  discount_pct INTEGER NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 90)
);

CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_items_product ON order_items(product_id);
