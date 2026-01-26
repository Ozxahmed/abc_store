-- 01_schemas.sql
-- Create all logical schemas for Dummy Company ABC

-- customers, addresses, etc.
CREATE SCHEMA IF NOT EXISTS customers;

-- Employee & department data
CREATE SCHEMA IF NOT EXISTS employees;

-- Products, suppliers, shipments, inventory-related entities
CREATE SCHEMA IF NOT EXISTS inventory;

-- Lookup / reference data (states, cities, payment methods, etc.)
CREATE SCHEMA IF NOT EXISTS "mapping";

-- Sales orders, order details, payments
CREATE SCHEMA IF NOT EXISTS sales;

-- Reporting / aggregated / analytics tables
CREATE SCHEMA IF NOT EXISTS analytics;
