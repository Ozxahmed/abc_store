-- 03_customers_tables.sql
-- Customers and their addresses

------------------------------
-- CUSTOMERS
------------------------------
CREATE TABLE customers.customers (
    customer_id   SERIAL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    phone         VARCHAR(15) NOT NULL,
    date_created  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT customers_pkey
        PRIMARY KEY (customer_id),

    CONSTRAINT email_unique 
        UNIQUE (email)
);

COMMENT ON TABLE customers.customers IS 'Customer name and contact info';


------------------------------
-- CUSTOMER ADDRESSES
------------------------------
CREATE TABLE customers.customer_addresses (
    address_id          SERIAL,
    customer_id         INT NOT NULL,
    street              VARCHAR(200),
    city_state_id       INT NOT NULL,
    zip_code            VARCHAR(10) NOT NULL,
    address_type        VARCHAR(10) NOT NULL,

    CONSTRAINT customer_addresses_pkey
        PRIMARY KEY (address_id),
    
    CONSTRAINT customer_addresses_customer_id_fk
        FOREIGN KEY (customer_id)
        REFERENCES customers.customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT customer_addresses_city_state_id_fk
        FOREIGN KEY (city_state_id)
        REFERENCES "mapping".cities(city_state_id),

    CONSTRAINT address_type_chk
        CHECK (address_type IN ('billing', 'shipping'))
);

COMMENT ON TABLE customers.customer_addresses IS 'Customer addresses (billing/shipping)';
