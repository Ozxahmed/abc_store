# Practice SQL Questions

## Common Queries

  ```sql
  -- Get table COLUMNS
  SELECT column_name
  FROM information_schema.columns
  WHERE table_schema = 'your_schema_name'
    AND table_name = 'your_table_name'
  ORDER BY ordinal_position;


  -- Check index
  SELECT indexname, indexdef 
  FROM pg_indexes 
  WHERE tablename = 'table_name';


  -- Check triggers
  SELECT
    trigger_schema AS "schema",
    event_object_table AS table_name, 
    trigger_name, 
    action_statement AS FUNCTIONS
  FROM information_schema.triggers;
  ```

## Intermediate SQL Practice Question 1

- Basic INNER JOIN Retrieve a list of orders, including the order ID, customer name, and order date, by joining the sales.orders and customers.customers tables.

```sql
-- sales.orders cols:
SELECT column_name
FROM information_schema."columns"
WHERE table_schema = 'sales'
  AND table_name = 'orders'
ORDER BY ordinal_position;
  --order_id
  --customer_id
  --order_date
  --total_amount


-- customers.cusomters cols:
SELECT column_name
FROM information_schema."columns"
WHERE table_schema = 'customers'
  AND table_name = 'customers'
ORDER BY ordinal_position;
  --customer_id
  --first_name
  --last_name
  --email
  --phone
  --date_created


-- checking index
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'customers';
  --customers_pkey      CREATE UNIQUE INDEX customers_pkey ON customers.customers USING btree (customer_id)
  --customers_email_key CREATE UNIQUE INDEX customers_email_key ON customers.customers USING btree (email)

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders'
  --orders_pkey         CREATE UNIQUE INDEX orders_pkey ON sales.orders USING btree (order_id)
  -- [x] Create index on customer_id


-- FINAL QUERY
-- order_id -> sales.orders o
-- order_date -> sales.orders
-- customer name -> customers.customers c, join on customer_id
  -- get last_name, first_name
SELECT 
  o.order_id,
  c.last_name || ', ' || c.first_name AS full_name,
  o.order_date
FROM sales.orders o
  INNER JOIN customers.customers c ON o.customer_id = c.customer_id
ORDER BY 2;
```

## Intermediate SQL Practice Question #2

- Retrieve the top 5 products that have been ordered the most (by total quantity) from the sales.order_details table. Include:

  - The product name (from inventory.products)
  - The total quantity ordered
  - Order the results from highest to lowest quantity

```sql
SELECT od.product_id, p.name, sum(od.quantity) AS total_qty
FROM sales.order_details od 
INNER JOIN inventory.products p 
  ON p.product_id = od.product_id
GROUP BY od.product_id, p.name
ORDER BY 3 DESC
LIMIT 5;
```

- 🔥 Stretch Goal: Instead of the top 5, return all products that have been ordered more than 50 times.

## problem 3: find repeat customers

Retrieve a list of customers who have placed more than 3 orders. Include their customer_id, first_name, last_name, and the total number of orders they’ve placed. Sort the results in descending order of total orders.

```sql
SELECT 
    o.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(*) AS order_count
FROM sales.orders o
INNER JOIN customers.customers c
    ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.first_name, c.last_name
HAVING count(*) >= 3
ORDER BY order_count DESC;
```

## 4

Find the top 5 products that generated the highest total revenue.

- You’ll need to calculate total revenue = SUM(quantity * item_price).
- Join the necessary tables to get product names.
- Order by total revenue in descending order.

```sql
--Find the top 5 products that generated the highest total revenue.

-- product id --> group by
-- line_item_total --> sum --> order desc --> limit 5

SELECT
  od.product_id,
  p."name", 
  sum(line_item_total) AS total_revenue
FROM sales.order_details od
INNER JOIN inventory.products p 
  ON od.product_id = p.product_id
GROUP BY od.product_id, p."name"
ORDER BY total_revenue DESC
LIMIT 5;
```

## 5

Find the names of customers who have spent more than the average total order amount.

```sql
SELECT 
    c.first_name,
    c.last_name,
    o.customer_id,
    o.total_amount 
FROM sales.orders o
INNER JOIN customers.customers c ON
    o.customer_id = c.customer_id
WHERE total_amount > (
    SELECT round(AVG(total_amount), 2) AS avg_total
    FROM sales.orders
    );
```

## 6

Find customers who have placed at least 2 orders where each order was over $500.
Show:

- customer_id, first_name, last_name
- number_of_big_orders

```sql
-- order total > 500 --> sales.orders
SELECT customer_id, total_amount
FROM sales.orders o 
WHERE total_amount > 500

-- number of orders per customer --> group by customer_id, count(*)?
SELECT
  o.customer_id,
  c.first_name,
  c.last_name,
  count(*) AS big_orders
FROM (
  SELECT customer_id, total_amount
  FROM sales.orders
  WHERE total_amount > 500
) o
INNER JOIN customers.customers c ON
  o.customer_id = c.customer_id
GROUP BY 1, 2, 3
HAVING count(*) >= 2
ORDER BY big_orders DESC;
```

## 7

Find the top 5 products that have been purchased by the highest number of distinct customers. Show:

- product_id, product_name, number_of_customers
- Sort by number_of_customers descending.

```sql
-- products --> inventory.products --> fkey sales.order_details
-- distinct customers --> sales.orders
-- > group by customer_id, product_id, count(distinct)?
SELECT
    cpl.product_id,
    p."name",
    count(DISTINCT cpl.customer_id) AS distinct_customers
FROM (
    SELECT
        product_id,
        customer_id
    FROM sales.order_details od 
    INNER JOIN sales.orders o ON
        od.order_id = o.order_id
    GROUP BY product_id, customer_id
) cpl
INNER JOIN inventory.products p ON
    cpl.product_id = p.product_id
GROUP BY cpl.product_id, p."name"
ORDER BY distinct_customers DESC
LIMIT 5;
```

## 8

Show a list of products that do not appear in any order (i.e., no row in sales.order_details has their product_id). Include:

- product_id
- name

```sql
-- so does not appear in sales.order_details...
-- does not exist in list of product_ids in inventory.products..
SELECT
    product_id,
    "name"
FROM inventory.products p
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.order_details od
    WHERE p.product_id = od.product_id
);
```
