# Dummy DB Project

Using chatgpt to help build a dummy db to practice SQL queries and database management

## Outline

Here’s an outline for what we can build:

1. **Number of Schemas**:
    - Let's start with **3-5 schemas** (e.g., `sales`, `inventory`, `customers`, `employees`, `orders`).

2. **Number of Tables per Schema**:
    - Each schema could have around **5-8 tables**, creating about **15-40 tables** in total.
    - We’ll ensure that the tables are linked logically via foreign keys.

3. **Tables and Fields**:
    - Each table could have **10-15 fields** (mix of integers, strings, dates, etc.).
    - We’ll include fields that let you practice joins, aggregations, subqueries, and more.

4. **Data Volume**:
    - We can generate **thousands to hundreds of thousands of rows** per table depending on your system’s capacity.
    - Example: `customers` table could have 50,000 rows, `orders` 200,000 rows, etc.

5. **Relations and Complexity**:
    - We can implement **1-to-many, many-to-many, and 1-to-1** relationships between tables, letting you practice various types of joins.
    - We can add triggers, views, and functions to simulate a real-world environment.

## What I can practice

Absolutely! Building this database will help you get hands-on experience with:

1. **Relationships**:
   - **1-to-Many**: Linking a `customers` table to an `orders` table, where one customer can have many orders.
   - **Many-to-Many**: You could have something like `products` and `orders`, where a single product can appear in many orders, and an order can contain many products. This will require a **junction table** (e.g., `order_details`).
   - **1-to-1**: Linking tables such as `employees` and `employee_details` to create a one-to-one relationship.

2. **Database Management**:
   - **Schema Management**: You’ll learn how to organize tables into schemas (think of them as folders within your database).
   - **Constraints**: We'll add **foreign keys** to enforce relationships, **unique constraints**, and **indexes** to optimize queries.
   - **Normalization**: We'll make sure tables are well-structured, following **normal forms** to reduce redundancy.
   - **Views**: You’ll create **views** to simplify complex queries for reporting purposes.

3. **SQL Query Practice**:
   - **Joins**: Practice inner, left, right, and full joins across multiple schemas and tables.
   - **Aggregations**: Use `GROUP BY`, `HAVING`, and window functions to summarize data.
   - **Subqueries**: Learn how to nest queries for complex data retrieval.
   - **Indexes**: Explore how to speed up queries with indexing strategies.

4. **Database Operations**:
   - **Inserting and Updating**: Practice inserting and updating large amounts of data efficiently.
   - **Backup and Restore**: Learn how to back up the database and restore it, ensuring data management skills.
   - **User Roles and Permissions**: You could even create different **user roles** to practice security and permissions within PostgreSQL.

5. **Indexing**:
   - When you're ready, chatgpt can help with a focused session on indexing that covers:
     - How indexing works.
     - When to use it (e.g., columns in WHERE, JOIN, ORDER BY clauses).
     - How to create different types of indexes in PostgreSQL (B-tree, hash, etc.).

## Database Structure

### Schema 1: **customers**

- Tables:
  - `customers`: Stores customer info like `customer_id`, `first_name`, `last_name`, `email`, `phone`, etc.
  - `customer_addresses`: Stores multiple addresses for each customer (`address_id`, `customer_id`, `street`, `city`, `state`, `zip_code`, etc.).
  - `customer_preferences`: Optional preferences or settings for each customer (`preference_id`, `customer_id`, `preference_type`, `value`).

### Schema 2: **sales**

- Tables:
  - `orders`: Stores order details (`order_id`, `customer_id` (foreign key from customers.customers), `order_date`, `total_amount`). 500 records
  - `order_details`: Tracks items in each order (`order_item_id`, `order_id` (foreign key), `product_id` (foreign key), `quantity`, `price`).
    - **Logic for Populating `sales.order_details`**
      - **Each order should have 1-5 items**
        - Randomly decide the number of items per order using `random.randint(1, 5)`.
        - Since there are 500 orders, this results in approximately **600-1000 total records**.

      - **Each item should have a valid `product_id`**
        - Select `product_id` randomly from `inventory.products`.

      - **Quantity per item should be realistic**
        - Assign quantity randomly (e.g., 1-10 items per order item).

      - **Price should match the product’s price**
        - Query the `inventory.products` table to fetch the price for each `product_id`.
        - Alternatively, allow minor price variations (e.g., simulating discounts).

  - `payments`: Information on payments (`payment_id`, `order_id` (foreign key), `payment_date`, `amount`, `method`).

### Schema 3: **inventory**

- Tables:
  - `products`: Product info like `product_id`, `name`, `description`, `price`, `stock_quantity`.
  - `suppliers`: Supplier details (`supplier_id`, `name`, `contact_info`).
  - `shipments`: Tracks shipments (`shipment_id`, `supplier_id`, `shipment_date`, `status`).

### Schema 4: **employees**

- Tables:
  - `employees`: Employee details like `employee_id`, `first_name`, `last_name`, `hire_date`, `salary`.
  - `departments`: Department info (`department_id`, `name`, `manager_id`).

### Schema 5: **analytics**

- Tables:
  - `monthly_sales`: Aggregated sales data (`month`, `total_sales`, `avg_order_value`).
  - `product_performance`: Tracks product metrics (`product_id`, `total_sales`, `units_sold`, `avg_rating`).

### Schema 6: **mapping**

- Tables:
  - `states`
  - `cities`

## SQL To Create Schema and Tables

```SQL

------ `mapping` schema and tables ------

CREATE SCHEMA IF NOT EXISTS mapping;

-- states
CREATE TABLE MAPPING.states (
    state_id serial PRIMARY KEY,
    state_name varchar(100) NOT NULL,
    state_abbr varchar(10) NOT NULL unique
);

-- cities
CREATE TABLE MAPPING.cities (
    city_id serial PRIMARY KEY,
    city_name varchar(100) NOT NULL,
    state_id int NOT NULL REFERENCES MAPPING.states(state_id) ON DELETE cascade
);


------ customers table ------

-- customer_addresses
CREATE TABLE customers.customer_addresses(
    address_id serial PRIMARY KEY,
    customer_id int NOT NULL REFERENCES customers.customers(customer_id) ON DELETE CASCADE,
    street varchar(200),
    city_id int NOT NULL REFERENCES mapping.cities(city_id),
    state_id int NOT NULL REFERENCES mapping.states(state_id),
    zip_code varchar(10),
    address_type varchar(10) NOT NULL
);

ALTER TABLE customers.customer_addresses
ADD CONSTRAINT check_address_type_constraint
CHECK (address_type IN ('billing', 'shipping'));


-------- `sales` schema and tables ------

CREATE SCHEMA IF NOT EXISTS sales;

-- orders
CREATE TABLE sales.orders (
    order_id serial PRIMARY KEY,
    customer_id int NOT NULL REFERENCES customers.customers(customer_id) ON DELETE cascade,
    order_date timestamp DEFAULT current_timestamp,
    total_amount numeric(10,2) NOT NULL
);

-- order_details
CREATE TABLE sales.order_details (
    order_item_id serial PRIMARY KEY,
    order_id int NOT NULL,
    product_id int NOT NULL,
    quantity int NOT NULL,
    price decimal(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES inventory.products(product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE sales.order_details IS 'Tracks items in each order'

-- payments
CREATE TABLE sales.payments (
    payment_id serial PRIMARY KEY,
    order_id int NOT NULL,
    payment_date date NOT NULL,
    amount decimal(10,2) NOT NULL,
    method varchar(50) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE
);

comment ON TABLE sales.payments IS 'Information on payments';


------ `inventory` schema and tables ------

CREATE SCHEMA IF NOT EXISTS inventory;

-- products
CREATE TABLE inventory.products (
    product_id serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    description varchar(500),
    price numeric(10,2) NOT NULL,
    stock_quantity int NOT NULL
);

-- suppliers
CREATE TABLE inventory.suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

COMMENT ON TABLE inventory.suppliers IS 'Supplier details';

-- shipments
CREATE TABLE inventory.shipments (
    shipment_id INT PRIMARY KEY,
    supplier_id INT NOT NULL,
    shipment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES inventory.suppliers (supplier_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- comments
COMMENT ON COLUMN inventory.shipments.status IS 'shipped, delayed, etc';

COMMENT ON TABLE inventory.shipments IS 'Track shipments';


------ `employees` schema and table ------

CREATE SCHEMA IF NOT EXISTS employees;

-- departments (created this 1st to use dept_id as fkey employees table)
CREATE TABLE employees.departments (
    department_id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manager_id INT
);

comment ON TABLE employees.departments IS 'Department info';

-- employees
CREATE TABLE employees.employees (
    employee_id serial PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email varchar(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date date NULL,
    department_id int NULL,
    salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES employees.departments(department_id) ON UPDATE CASCADE ON DELETE SET NULL
);

COMMENT ON TABLE employees.employees IS 'Employee details';

-- add foreign key to departments.manager_id
ALTER TABLE employees.departments
ADD CONSTRAINT fkey_manager_id
FOREIGN KEY (manager_id) REFERENCES employees.employees(employee_id) ON UPDATE CASCADE ON DELETE SET NULL;


------ analytics schema and table ------

CREATE SCHEMA IF NOT EXISTS analytics;

-- monthly_sales
CREATE TABLE analytics.monthly_sales (
    month INT NOT NULL,
    year int NOT NULL,
    total_sales DECIMAL(10,2) NOT NULL,
    avg_order_value DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (month, year)
);

COMMENT ON TABLE analytics.monthly_sales IS 'Aggregated sales data';

-- product_performance
CREATE TABLE analytics.product_performance (
    product_id INT NOT NULL,
    total_sales INT NOT NULL,
    units_sold INT NOT NULL,
    avg_rating DECIMAL(3,1) NOT NULL,
    PRIMARY KEY (product_id),
    FOREIGN KEY (product_id) REFERENCES inventory.products (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE analytics.product_performance IS 'Tracks product metric';
```

## Plan to Fill DB

**Recommended Process to Fill Data:**
We can use random generators (like Faker or Python’s random library) to generate realistic but dummy data. Here’s the approach:

Step 1: Populate Independent Tables:

- mapping.states: 50 records (US states).
- mapping.cities: Create multiple cities per state, so let's aim for 200 cities.
- inventory.suppliers: 10 suppliers.
- employees.departments: 5-10 departments.

Step 2: Populate Key Tables:

- customers.customers: 200 customers.
- inventory.products: 50 products.

Step 3: Dependent Tables:

- customers.customer_addresses: 1-3 addresses per customer (let’s say ~400 records total).
- sales.orders: Each customer could have multiple orders (200-300 records).
- sales.order_details: 1-5 items per order (~600-1000 records).
- sales.payments: 1 payment per order (~300 records).
- inventory.shipments: 50-100 records.

Step 4: Analytics:

- analytics.monthly_sales: Generate data based on the orders.
- analytics.product_performance: Based on the sales data.

## 2/7/25 update

### Summary of What Was Planned

1. **Build a PostgreSQL Database** with multiple schemas and tables for SQL practice.
2. **Host the database on AWS RDS** (user will handle this later after working locally).
3. **Create and populate tables** across six schemas:
   - `customers`
   - `employees`
   - `inventory`
   - `mapping`
   - `sales`
   - `analytics`
4. **Generate dummy data using Python (Faker & Random libraries).**
5. **Ensure realistic relationships between tables.**

---

### Completed So Far

✅ **Database and schemas were created** with all required tables.
✅ **Customers table populated** (200 records).
✅ **Inventory tables populated** (`products`, `suppliers`, `shipments`).
✅ **Mapping schema populated** (`states` and `cities`).
✅ **Customer addresses table populated** (two addresses per customer, billing & shipping logic implemented).
✅ **Employees schema populated** (5 departments, 50 employees, managers assigned).
✅ **Sales schema started** with the `sales.sales` table (500 records inserted).

---

### Remaining Tasks Before Practicing SQL Queries

#### **1️⃣ Populate the `sales.order_details` table** (Next Step)

- This table links `sales.orders` (orders) and `inventory.products`, representing items purchased in each order.
- We need to decide:
  - How many items per order (randomized? 1-5 items per order?).
  - How to determine product IDs (randomly selected from `inventory.products`).
  - Quantity constraints per item.
  - Price consistency (matching `inventory.products.price` or allowing variations).
- [x] Populate the `sales.order_details` table

#### **2️⃣ Populate the `sales.payments` table**

- Links to `sales.orders` to track payments for orders.
- We need to decide:
  - Does every order have a payment? (Yes, unless handling unpaid orders).
  - Payment methods (credit card, PayPal, etc.).
  - Payment amounts (should match `sales.sales.total_amount` exactly).
  - Payment date (same as or after `sales.sales.order_date`).
- [x] Populate the `sales.payments` table

#### **3️⃣ `analytics` schema tables**

- `analytics.monthly_sales`: Aggregated sales data per month/year.
- `analytics.product_performance`: Sales performance per product.
- We are going to populate this using SQL during the advanced section of practice.
- We need to decide:
  - Should we derive this data from `sales.orders`? (Likely via SQL queries after data insertion).
  - If we prefill them manually or generate them dynamically.

## SQL Practice Study Plan

### 🟢 Step 1: Intermediate SQL Practice

- Basic `SELECT` queries on your existing tables.
- Filtering with `WHERE`, `BETWEEN`, `IN`, `LIKE`.
- Sorting with `ORDER BY`.
- Basic `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN` across schemas.
- Grouping & Aggregation: `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`.
- Basic subqueries (e.g., find customers who placed more than 5 orders).

### 🔵 Step 2: Advanced SQL Queries

- Window functions (`ROW_NUMBER`, `RANK`, `SUM() OVER()`).
- Common Table Expressions (CTEs) for modular queries.
- Advanced joins (e.g., self joins, multi-table joins).
- Correlated subqueries for dynamic filtering.
- Recursive queries if needed (probably not for this dataset).
- `CASE WHEN` for conditional logic in queries.

### 🔥 Step 3: Analytics Schema & Staging Tables

- Define staging tables for transforming raw data.
- Precompute key metrics (e.g., total revenue by month, top customers).
- Use `INSERT INTO … SELECT` for large-scale transformations.
- Explore Materialized Views for performance optimization.

## DB improvements made while practicing

Practice questions and answers are in a separate markdown

### Index

```sql
-- create index sales.orders.customer_id
  -- speed up query
  CREATE INDEX idx_orders_customer_id 
  ON sales.orders (customer_id);
```

### Triggers + Checks + Constraints

```sql
-- Reduce stock quantity when new order is placed

-- First create the function -> COMMIT -> create trigger -> COMMIT

-- create function to reduce stock quantity when a new order item is inserted
CREATE OR REPLACE FUNCTION update_stock_quantity()
RETURNS TRIGGER AS $$
BEGIN
    -- Reduce stock quantity when a new order item is inserted
    UPDATE inventory.products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- create trigger
CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON sales.order_details
FOR EACH ROW
EXECUTE FUNCTION update_stock_quantity();


-- test trigger
-- check stock before order
SELECT * FROM inventory.products WHERE product_id = 100
-- 75

-- insert order
-- First sales.orders (sales.order_details.order_id is fkey)
INSERT INTO sales.orders (order_id, customer_id, total_amount)
VALUES (501, 400, 3 * 929.83);

-- Then enter order into sales.order_details
INSERT INTO sales.order_details (order_id, product_id, quantity, item_price, line_item_total)
VALUES (501, 100, 3, 929.83, 3 * 929.83);
-- Questions:
  -- shouldn't the order_id auto increment?
  -- check that price matches product_id
  -- check qty doesn't go negative
  -- make sure order_id exists in sales.orders, total_amount matches sum of the line_item_total for that order...
-- I addressed this in SQL block below

-- check stock after order
SELECT * FROM inventory.products WHERE product_id = 100
-- 72 -> WORKED!


-- Clean up
--This is options, I did not implement it.
--DROP TRIGGER reduce_stock_after_order ON sales.order_details;
--DROP FUNCTION update_stock_quantity();
```

```sql
-- Questions:
  -- 1. shouldn't the order_id auto increment? --> YES but only for sales.orders. 
  -- 2. check that price matches product_id --> Do this manually
  -- 3. check qty doesn't go negative --> Trigger
  -- 4. make sure order_id exists in sales.orders, total_amount matches sum of the line_item_total for that order...

-- 3
-- check existing triggers --> Delete trigger and function
SELECT
  trigger_schema AS "schema",
  event_object_table AS table_name, 
  trigger_name, 
  action_statement -- functions
FROM information_schema.triggers;
-- sales  order_details reduce_stock_after_order  EXECUTE FUNCTION update_stock_quantity()

-- drop existing trigger
DROP TRIGGER reduce_stock_after_order ON sales.order_details;

-- drop existing function
DROP FUNCTION update_stock_quantity();


-- create function to check and update stock based on sales.order_details
CREATE OR REPLACE FUNCTION check_and_update_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there is enough stock before inserting or updating
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        IF (SELECT stock_quantity FROM inventory.products WHERE product_id = NEW.product_id) < NEW.quantity THEN
            RAISE EXCEPTION 'Not enough stock available for product_id %', NEW.product_id;
        END IF;

        -- Reduce stock only if enough quantity is available
        UPDATE inventory.products
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- create trigger
CREATE TRIGGER trg_check_stock
BEFORE INSERT OR UPDATE ON sales.order_details
FOR EACH ROW EXECUTE FUNCTION check_and_update_stock();


-- create function to update stock upon deletion of order(s)
CREATE OR REPLACE FUNCTION reduce_stock_upon_order_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE inventory.products
        SET stock_quantity = stock_quantity + OLD.quantity
        WHERE product_id = OLD.product_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


-- create trigger
CREATE TRIGGER trg_reduce_stock
AFTER DELETE ON sales.order_details
FOR EACH ROW 
EXECUTE FUNCTION reduce_stock_upon_order_deletion();
```

## Trigger: autofill_order_details

```sql
CREATE OR REPLACE FUNCTION autofill_order_details()
RETURNS TRIGGER AS $$
BEGIN
    -- fetch item_price from inventory.products
    SELECT price INTO NEW.item_price
    FROM inventory.products p
    WHERE p.product_id = NEW.product_id;
    
    -- ensure item_price was found (product exists)
    IF NEW.item_price IS NULL THEN
        RAISE EXCEPTION 'invalid product_id: %', NEW.product_id;
    END IF;
    
    -- calculate line_item_total
    NEW.line_item_total := NEW.item_price * NEW.quantity;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trg_autofill_order_details
BEFORE INSERT OR UPDATE ON sales.order_details
FOR EACH ROW EXECUTE FUNCTION autofill_order_details();
```

## Trigger: update_order_total_amount

```sql

-- trigger to auto fill total_amount in sales.orders using info from sales.order_details

-- create function
CREATE OR REPLACE FUNCTION update_order_total_amount()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE sales.orders
  SET total_amount = (
    SELECT COALESCE(sum(line_item_total), 0)
    FROM sales.order_details
    WHERE order_id = NEW.order_id
  )
  WHERE order_id = NEW.order_id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- create trigger
CREATE OR REPLACE TRIGGER trg_update_order_total_amount
AFTER INSERT OR UPDATE OR DELETE ON sales.order_details
FOR EACH ROW EXECUTE FUNCTION update_order_total_amount();
```
