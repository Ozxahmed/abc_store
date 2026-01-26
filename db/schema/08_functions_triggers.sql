-- 08_functions_triggers.sql
-- Business logic: order_details pricing, stock management, order totals, and payment validation.
-- NOTE: Functions are kept in the public schema for simplicity in this project.
--       In a larger system, it is cleaner to place them into domain schemas
--       (e.g., inventory.*, sales.*).

-- ==============================
-- 1. FUNCTIONS
-- ==============================

------------------------------
-- 1.1 AUTOFILL ORDER DETAILS
------------------------------
-- Responsibility:
--  - For each row inserted/updated in sales.order_details:
--      * Look up the product price from inventory.products.price
--      * Set item_price
--      * Compute line_item_total = item_price * quantity
--  - This ensures line_item_total always matches price * quantity.
--  - If someone manually updates line_item_total, this trigger will
--    recompute it based on the current product price.

CREATE OR REPLACE FUNCTION public.autofill_order_details()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Get the current price from inventory.products for this product_id
    SELECT p.price INTO NEW.item_price
    FROM inventory.products AS p
    WHERE p.product_id = NEW.product_id;

    -- If no price was found, the product_id is invalid
    IF NEW.item_price IS NULL THEN
        RAISE EXCEPTION 'Invalid product_id: %', NEW.product_id;
    END IF;

    -- Compute line_item_total as price * quantity
    NEW.line_item_total := NEW.item_price * NEW.quantity;

    RETURN NEW;
END;
$function$;


--------------------------------------------
-- 1.2 MANAGE STOCK FOR ORDER DETAILS
--------------------------------------------
-- Responsibility:
--  - Keeps inventory.products.stock_quantity in sync with sales.order_details.
--  - Prevents stock from going negative.
--
-- Behavior:
--  - INSERT:
--      * Check if enough stock exists for NEW.quantity.
--      * Subtract NEW.quantity from inventory.products.stock_quantity.
--  - UPDATE:
--      * Assumes product_id is not changed on this row.
--      * Calculates delta = NEW.quantity - OLD.quantity.
--      * If delta > 0: check and subtract extra stock.
--      * If delta < 0: return the difference to stock.
--  - DELETE:
--      * Add OLD.quantity back to stock.

CREATE OR REPLACE FUNCTION public.manage_stock_for_order_details()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_current_stock integer;
    v_delta         integer;
BEGIN
    -- INSERT: subtract full NEW.quantity (if enough stock)
    IF TG_OP = 'INSERT' THEN
        SELECT stock_quantity INTO v_current_stock
        FROM inventory.products
        WHERE product_id = NEW.product_id
        FOR UPDATE;

        IF v_current_stock IS NULL THEN
            RAISE EXCEPTION 'Product % does not exist', NEW.product_id;
        END IF;

        IF v_current_stock < NEW.quantity THEN
            RAISE EXCEPTION
                'Not enough stock for product % (requested %, available %)',
                NEW.product_id, NEW.quantity, v_current_stock;
        END IF;

        UPDATE inventory.products
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE product_id = NEW.product_id;

        RETURN NEW;


    -- UPDATE: adjust stock based on the change in quantity
    ELSIF TG_OP = 'UPDATE' THEN
        -- Keep it simple: we do not support changing product_id in-place.
        IF NEW.product_id <> OLD.product_id THEN
            RAISE EXCEPTION
                'Changing product_id on sales.order_details is not supported by this trigger';
        END IF;

        v_delta := NEW.quantity - OLD.quantity;  -- positive = more, negative = less

        IF v_delta > 0 THEN
            -- Need extra stock for the increased quantity
            SELECT stock_quantity INTO v_current_stock
            FROM inventory.products
            WHERE product_id = NEW.product_id
            FOR UPDATE;

            IF v_current_stock < v_delta THEN
                RAISE EXCEPTION
                    'Not enough stock for product % (extra requested %, available %)',
                    NEW.product_id, v_delta, v_current_stock;
            END IF;

            UPDATE inventory.products
            SET stock_quantity = stock_quantity - v_delta
            WHERE product_id = NEW.product_id;

        ELSIF v_delta < 0 THEN
            -- Quantity decreased; return the difference to stock
            UPDATE inventory.products
            SET stock_quantity = stock_quantity + (OLD.quantity - NEW.quantity)
            WHERE product_id = NEW.product_id;
        END IF;

        RETURN NEW;


    -- DELETE: restore OLD.quantity back to stock
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE inventory.products
        SET stock_quantity = stock_quantity + OLD.quantity
        WHERE product_id = OLD.product_id;

        RETURN OLD;
    END IF;

    -- Should not hit this
    RETURN NULL;
END;
$function$;


-------------------------------------------------
-- 1.3 SYNC orders.total_amount FROM order_details
-------------------------------------------------
-- Responsibility:
--  - After any INSERT / UPDATE / DELETE on sales.order_details,
--    recompute sales.orders.total_amount as:
--        SUM(line_item_total) for that order_id.
--
-- Handles DELETE safely by using OLD.order_id.

CREATE OR REPLACE FUNCTION public.sync_order_total_from_details()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_order_id integer;
BEGIN
    -- Choose the correct order_id depending on the operation
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_order_id := NEW.order_id;
    ELSIF TG_OP = 'DELETE' THEN
        v_order_id := OLD.order_id;
    ELSE
        RETURN NULL;
    END IF;

    -- Recalculate the total_amount for this order
    UPDATE sales.orders AS o
    SET total_amount = COALESCE((
        SELECT SUM(od.line_item_total)
        FROM sales.order_details AS od
        WHERE od.order_id = v_order_id
    ), 0)
    WHERE o.order_id = v_order_id;

    -- Return the appropriate row for the trigger type
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;


------------------------------------------
-- 1.4 VALIDATE PAYMENTS AGAINST ORDERS
------------------------------------------
-- Responsibility:
--  - Enforce:
--      * sales.payment.order_id must exist in sales.orders
--      * payment_date >= order_date
--      * amount must match orders.total_amount exactly

CREATE OR REPLACE FUNCTION public.validate_payment_against_order()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_order_date   date;
    v_total_amount numeric(10, 2);
BEGIN
    -- Fetch order_date and total_amount for this order_id
    SELECT o.order_date::date, o.total_amount INTO v_order_date, v_total_amount
    FROM sales.orders AS o
    WHERE o.order_id = NEW.order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Order % does not exist for payment', NEW.order_id;
    END IF;

    -- Payment date must be on or after the order date
    IF NEW.payment_date < v_order_date THEN
        RAISE EXCEPTION
            'Payment date % cannot be before order date % for order %',
            NEW.payment_date, v_order_date, NEW.order_id;
    END IF;

    -- Payment amount must match the order total
    IF NEW.amount <> v_total_amount THEN
        RAISE EXCEPTION
            'Payment amount % must match order total % for order %',
            NEW.amount, v_total_amount, NEW.order_id;
    END IF;

    RETURN NEW;
END;
$function$;



-- ==============================
-- 2. TRIGGERS
-- ==============================

---------------------------------
-- 2.1 Triggers on sales.order_details
---------------------------------

-- 2.1.1 Autofill item_price and line_item_total
CREATE TRIGGER trg_autofill_order_details
BEFORE INSERT OR UPDATE ON sales.order_details
FOR EACH ROW
EXECUTE FUNCTION public.autofill_order_details();


-- 2.1.2 Manage stock for each change in order_details
CREATE TRIGGER trg_order_details_manage_stock
BEFORE INSERT OR UPDATE OR DELETE ON sales.order_details
FOR EACH ROW
EXECUTE FUNCTION public.manage_stock_for_order_details();


-- 2.1.3 Keep sales.orders.total_amount in sync
CREATE TRIGGER trg_order_details_sync_order_total
AFTER INSERT OR UPDATE OR DELETE ON sales.order_details
FOR EACH ROW
EXECUTE FUNCTION public.sync_order_total_from_details();


---------------------------------
-- 2.2 Triggers on sales.payments
---------------------------------

-- Validate each payment against the corresponding order
CREATE TRIGGER trg_payments_validate
BEFORE INSERT OR UPDATE ON sales.payments
FOR EACH ROW
EXECUTE FUNCTION public.validate_payment_against_order();
