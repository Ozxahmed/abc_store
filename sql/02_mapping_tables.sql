-- 02_mapping_tables.sql
-- Lookup / reference data

------------------------------
-- STATES
------------------------------
CREATE TABLE "mapping".states (
    state_id      SERIAL,
    state_name    VARCHAR(100) NOT NULL,
    state_abbr    VARCHAR(10)  NOT NULL,

    CONSTRAINT states_pkey
        PRIMARY KEY (state_id),

    CONSTRAINT state_abbr_upper_chk
        CHECK (state_abbr = UPPER(state_abbr)),
    
    CONSTRAINT state_abbr_unique
        UNIQUE (state_abbr)
);

CREATE UNIQUE INDEX states_state_name_lower_unique
ON "mapping".states (LOWER(state_name));

COMMENT ON TABLE "mapping".states IS 'U.S. states lookup table';


------------------------------
-- CITIES
------------------------------
CREATE TABLE "mapping".cities (
    city_state_id       SERIAL,
    city_name           VARCHAR(100) NOT NULL,
    state_id            INT NOT NULL,
    
    CONSTRAINT cities_pkey
        PRIMARY KEY (city_state_id),
    
    CONSTRAINT cities_state_id_fk
        FOREIGN KEY (state_id)
        REFERENCES "mapping".states(state_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX cities_city_state_lower_unique
ON "mapping".cities (LOWER(city_name), state_id);

COMMENT ON TABLE "mapping".cities IS 'Cities linked to their respective U.S. states';


------------------------------
-- PAYMENT METHODS
------------------------------
CREATE TABLE "mapping".payment_methods (
    payment_method_id  SERIAL,
    method_name        VARCHAR(50) NOT NULL,

    CONSTRAINT payment_methods_pkey
        PRIMARY KEY (payment_method_id)
);

CREATE UNIQUE INDEX payment_methods_method_name_lower_unique
ON "mapping".payment_methods (LOWER(method_name));

COMMENT ON TABLE "mapping".payment_methods IS 'Accepted payment methods (credit card, cash, check, etc.)';
