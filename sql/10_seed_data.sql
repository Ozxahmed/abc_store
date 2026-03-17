-- ============================================
-- 10_seed_data.sql
-- Loads seed CSV files into ABC Store database
-- ============================================

\set ON_ERROR_STOP on

-- ============================================
-- MAPPING
-- ============================================

COPY mapping.states
FROM '/seed_data/mapping/states.csv'
DELIMITER ','
CSV HEADER;

COPY mapping.payment_methods
FROM '/seed_data/mapping/payment_methods.csv'
DELIMITER ','
CSV HEADER;

COPY mapping.cities
FROM '/seed_data/mapping/cities.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- CUSTOMERS
-- ============================================

COPY customers.customers
FROM '/seed_data/customers/customers.csv'
DELIMITER ','
CSV HEADER;

COPY customers.customer_addresses
FROM '/seed_data/customers/customer_addresses.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- INVENTORY
-- ============================================

COPY inventory.suppliers
FROM '/seed_data/inventory/suppliers.csv'
DELIMITER ','
CSV HEADER;

COPY inventory.products
FROM '/seed_data/inventory/products.csv'
DELIMITER ','
CSV HEADER;

COPY inventory.shipments
FROM '/seed_data/inventory/shipments.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- SALES
-- ============================================

COPY sales.orders
FROM '/seed_data/sales/orders.csv'
DELIMITER ','
CSV HEADER;

COPY sales.order_details
FROM '/seed_data/sales/order_details.csv'
DELIMITER ','
CSV HEADER;

COPY sales.payments
FROM '/seed_data/sales/payments.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- EMPLOYEES
-- departments loads before employees.
-- Circular FK is applied later in:
-- /sql/09_employees_cir_relationship.sql
-- ============================================

COPY employees.departments
FROM '/seed_data/employees/departments.csv'
DELIMITER ','
CSV HEADER;

COPY employees.employees
FROM '/seed_data/employees/employees.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- ANALYTICS
-- ============================================

COPY analytics.monthly_sales
FROM '/seed_data/analytics/monthly_sales.csv'
DELIMITER ','
CSV HEADER;

COPY analytics.product_performance
FROM '/seed_data/analytics/product_performance.csv'
DELIMITER ','
CSV HEADER;


-- ============================================
-- Reset sequences after explicit ID loads
-- Only for tables with SERIAL-backed PKs
-- ============================================

SELECT setval(
    pg_get_serial_sequence('mapping.states', 'state_id'),
    COALESCE((SELECT MAX(state_id) FROM mapping.states), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('mapping.payment_methods', 'payment_method_id'),
    COALESCE((SELECT MAX(payment_method_id) FROM mapping.payment_methods), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('mapping.cities', 'city_state_id'),
    COALESCE((SELECT MAX(city_state_id) FROM mapping.cities), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('customers.customers', 'customer_id'),
    COALESCE((SELECT MAX(customer_id) FROM customers.customers), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('customers.customer_addresses', 'address_id'),
    COALESCE((SELECT MAX(address_id) FROM customers.customer_addresses), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('inventory.suppliers', 'supplier_id'),
    COALESCE((SELECT MAX(supplier_id) FROM inventory.suppliers), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('inventory.products', 'product_id'),
    COALESCE((SELECT MAX(product_id) FROM inventory.products), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('inventory.shipments', 'shipment_id'),
    COALESCE((SELECT MAX(shipment_id) FROM inventory.shipments), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('sales.orders', 'order_id'),
    COALESCE((SELECT MAX(order_id) FROM sales.orders), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('sales.order_details', 'order_detail_id'),
    COALESCE((SELECT MAX(order_detail_id) FROM sales.order_details), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('sales.payments', 'payment_id'),
    COALESCE((SELECT MAX(payment_id) FROM sales.payments), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('employees.departments', 'department_id'),
    COALESCE((SELECT MAX(department_id) FROM employees.departments), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('employees.employees', 'employee_id'),
    COALESCE((SELECT MAX(employee_id) FROM employees.employees), 1),
    true
);