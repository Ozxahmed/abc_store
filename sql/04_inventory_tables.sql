-- 04_inventory_tables.sql
-- Inventory: products, suppliers, and shipments


------------------------------
-- SUPPLIERS
------------------------------
CREATE TABLE inventory.suppliers (
    supplier_id   SERIAL,
    name          VARCHAR(100) NOT NULL,
    contact_info  TEXT,

    CONSTRAINT suppliers_pkey
        PRIMARY KEY (supplier_id)
);

CREATE UNIQUE INDEX inventory_suppliers_lower_unique
ON inventory.suppliers (LOWER(name));

COMMENT ON TABLE inventory.suppliers IS 'Suppliers name and ph number';


------------------------------
-- PRODUCTS
------------------------------
CREATE TABLE inventory.products (
    product_id      SERIAL,
    name            VARCHAR(100) NOT NULL,
    description     VARCHAR(500),
    price           NUMERIC(10, 2) NOT NULL,
    stock_quantity  INT NOT NULL,

    CONSTRAINT products_pkey
        PRIMARY KEY (product_id),

    CONSTRAINT price_positive_chk
        CHECK (price >= 0),

    CONSTRAINT stock_quantity_nonnegative_chk
        CHECK (stock_quantity >= 0)
);

COMMENT ON TABLE inventory.products IS 'Products available for sale, including price and current stock';


------------------------------
-- SHIPMENTS
------------------------------
CREATE TABLE inventory.shipments (
    shipment_id    SERIAL,
    supplier_id    INT NOT NULL,
    shipment_date  DATE NOT NULL,
    status         VARCHAR(20) NOT NULL,  -- e.g. 'Pending', 'Shipped', 'Delivered'

    CONSTRAINT shipments_pkey
        PRIMARY KEY (shipment_id),

    CONSTRAINT shipments_supplier_id_fk
        FOREIGN KEY (supplier_id)
        REFERENCES inventory.suppliers(supplier_id)
        ON DELETE CASCADE,

    CONSTRAINT shipment_status_chk
        CHECK (status IN ('Pending', 'Shipped', 'Delivered'))
);

COMMENT ON TABLE inventory.shipments IS 'Inbound shipments from suppliers, including status and date';
