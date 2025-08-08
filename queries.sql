-- Orders by status
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Total revenue by payment type
SELECT payment_type, SUM(payment_value) AS total_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Join orders with customers
SELECT o.order_id, c.customer_unique_id, o.order_status, o.order_purchase_timestamp
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;

-- Average revenue per customer
SELECT AVG(customer_revenue) AS avg_revenue_per_customer
FROM (
    SELECT o.customer_id, SUM(p.payment_value) AS customer_revenue
    FROM orders o
    JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY o.customer_id
);

-- Create view for high-value customers
CREATE VIEW high_value_customers AS
SELECT o.customer_id, SUM(p.payment_value) AS total_spent
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
HAVING total_spent > 1000;

-- Index optimization
CREATE INDEX idx_order_id ON order_payments(order_id);
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Handle NULLs in delivery dates
SELECT order_id,
       COALESCE(order_delivered_customer_date, 'Not Delivered') AS delivery_date
FROM orders
WHERE order_status = 'delivered'
LIMIT 10;

-- Subquery: customers above average spend
SELECT o.customer_id, SUM(p.payment_value) AS total_spent
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
HAVING total_spent > (
    SELECT AVG(payment_value) FROM order_payments
);
-- Drop view if it exists
DROP VIEW IF EXISTS high_value_customers;

-- Create view
CREATE VIEW high_value_customers AS
SELECT o.customer_id, SUM(p.payment_value) AS total_spent
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
HAVING total_spent > 1000;

-- Drop indexes if they exist
DROP INDEX IF EXISTS idx_order_id;
DROP INDEX IF EXISTS idx_customer_id;

-- Create indexes
CREATE INDEX idx_order_id ON order_payments(order_id);
CREATE INDEX idx_customer_id ON orders(customer_id);
