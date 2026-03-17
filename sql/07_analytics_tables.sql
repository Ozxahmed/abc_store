-- 07_analytics_tables.sql
-- Reporting / analytics-ready tables


------------------------------
-- MONTHLY SALES
------------------------------
CREATE TABLE analytics.monthly_sales (
    month           INT NOT NULL,   -- 1–12
    year            INT NOT NULL,   -- 4-digit year
    total_sales     NUMERIC(10, 2) NOT NULL,
    avg_order_value NUMERIC(10, 2) NOT NULL,

    CONSTRAINT monthly_sales_pkey
        PRIMARY KEY (month, year),

    CONSTRAINT monthly_sales_total_nonnegative_chk
        CHECK (total_sales >= 0),

    CONSTRAINT monthly_sales_aov_nonnegative_chk
        CHECK (avg_order_value >= 0)
);

COMMENT ON TABLE analytics.monthly_sales IS 'Aggregated revenue and average order value per month';


------------------------------
-- PRODUCT PERFORMANCE
------------------------------
CREATE TABLE analytics.product_performance (
    product_id   INT NOT NULL,
    total_sales  INT NOT NULL,        -- number of orders containing the product
    units_sold   INT NOT NULL,        -- total quantity across all orders
    avg_rating   NUMERIC(3, 1) NOT NULL,

    CONSTRAINT product_performance_pkey
        PRIMARY KEY (product_id),

    CONSTRAINT product_performance_product_id_fk
        FOREIGN KEY (product_id)
        REFERENCES inventory.products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT product_performance_total_sales_nonnegative_chk
        CHECK (total_sales >= 0),

    CONSTRAINT product_performance_units_sold_nonnegative_chk
        CHECK (units_sold >= 0),

    CONSTRAINT product_performance_avg_rating_range_chk
        CHECK (avg_rating BETWEEN 0 AND 5)
);

COMMENT ON TABLE analytics.product_performance IS 'Per-product performance metrics (volume & rating)';
