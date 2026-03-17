-- 05_sales_tables.sql
-- Customer orders, their line items, and payments


------------------------------
-- ORDERS
------------------------------
CREATE TABLE sales.orders (
    order_id      SERIAL,
    customer_id   INT NOT NULL,
    order_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount  NUMERIC(10, 2) NOT NULL,

    CONSTRAINT orders_pkey
        PRIMARY KEY (order_id),

    CONSTRAINT orders_customer_id_fk
        FOREIGN KEY (customer_id)
        REFERENCES customers.customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT orders_total_amount_nonnegative_chk
        CHECK (total_amount >= 0)
);

COMMENT ON TABLE sales.orders IS 'High-level customer orders (one row per order)';


------------------------------
-- ORDER DETAILS
------------------------------
CREATE TABLE sales.order_details (
    order_detail_id  SERIAL,
    order_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity         INT NOT NULL,
    item_price       NUMERIC(10, 2) NOT NULL,
    line_item_total  NUMERIC(10, 2) NOT NULL,

    CONSTRAINT order_details_pkey
        PRIMARY KEY (order_detail_id),

    CONSTRAINT order_details_order_id_fk
        FOREIGN KEY (order_id)
        REFERENCES sales.orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT order_details_product_id_fk
        FOREIGN KEY (product_id)
        REFERENCES inventory.products(product_id),

    CONSTRAINT order_details_quantity_positive_chk
        CHECK (quantity > 0),

    CONSTRAINT order_details_item_price_nonnegative_chk
        CHECK (item_price >= 0),

    CONSTRAINT order_details_line_item_total_nonnegative_chk
        CHECK (line_item_total >= 0)
);

COMMENT ON TABLE sales.order_details IS 'Line items per order (product, quantity, and pricing)';


------------------------------
-- PAYMENTS
------------------------------
CREATE TABLE sales.payments (
    payment_id        SERIAL,
    order_id          INT NOT NULL,
    payment_date      DATE NOT NULL,
    amount            NUMERIC(10, 2) NOT NULL,
    payment_method_id INT NOT NULL,

    CONSTRAINT payments_pkey
        PRIMARY KEY (payment_id),

    CONSTRAINT payments_order_id_fk
        FOREIGN KEY (order_id)
        REFERENCES sales.orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT payments_payment_method_id_fk
        FOREIGN KEY (payment_method_id)
        REFERENCES "mapping".payment_methods(payment_method_id),

    CONSTRAINT payments_amount_nonnegative_chk
        CHECK (amount >= 0)
);

COMMENT ON TABLE sales.payments IS 'Payments applied to customer orders with method and amount';
