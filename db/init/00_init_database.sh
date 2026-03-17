#!/bin/bash
set -e

echo "========================================="
echo "Starting ABC Store database initialization..."
echo "========================================="

echo ""
echo "Step 1/4: Creating schemas and tables..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/01_schemas.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/02_mapping_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/03_customers_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/04_inventory_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/05_sales_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/06_employees_tables.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/07_analytics_tables.sql

echo ""
echo "Step 2/4: Loading seed data..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/10_seed_data.sql

echo ""
echo "Step 3/4: Creating functions and triggers..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/08_functions_triggers.sql

echo ""
echo "Step 4/4: Applying employees circular relationship fix..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /sql/09_employees_cir_relationship.sql

echo ""
echo "========================================="
echo "ABC Store initialization complete."
echo "========================================="