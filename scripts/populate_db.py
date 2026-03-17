"""
Populate the ABC Store database with dummy data.
"""

from abc_store.db_utils import get_connection
from abc_store.db_reset import (
    clear_db_schema,
    drop_business_trigger_functions,
    drop_user_triggers,
)
from abc_store.data_generators.customers import (
    generate_customers,
    generate_customer_addresses,
)
from abc_store.data_generators.employees import (
    generate_departments,
    generate_employees,
)
from abc_store.data_generators.inventory import (
    generate_products,
    generate_suppliers,
    generate_inventory_shipments,
)
from abc_store.data_generators.mapping import (
    generate_mapping_US_states,
    generate_mapping_payment_methods,
    generate_mapping_cities,
)
from abc_store.data_generators.sales import (
    generate_sales_orders,
    generate_sales_order_details,
    generate_payments,
)


def run_data_generation(dotenv_path: str | None = None, reset_first: bool = True) -> None:
    """
    Populate all tables with dummy data.

    Args:
        dotenv_path: Optional path to a .env file with DB connection vars.
        reset_first: If True, drop user triggers/functions and truncate tables first.
    """
    connection = get_connection(dotenv_path=dotenv_path, verbose=True)
    if not connection:
        return

    try:
        with connection:
            with connection.cursor() as cursor:

                if reset_first:
                    print("\n--- MAINTENANCE ---")
                    drop_user_triggers(cursor)
                    drop_business_trigger_functions(cursor)
                    clear_db_schema(cursor)

                print("\n--- INSERTING data into tables ---")

                # primary tables
                generate_customers(cursor)
                generate_products(cursor)
                generate_suppliers(cursor)
                generate_mapping_US_states(cursor)
                generate_departments(cursor)
                generate_mapping_payment_methods(cursor)

                # secondary tables
                generate_mapping_cities(cursor)
                generate_customer_addresses(cursor)
                generate_inventory_shipments(cursor)
                generate_employees(cursor)
                generate_sales_orders(cursor)
                generate_sales_order_details(cursor)
                generate_payments(cursor)

        print("\n--- SUCCESS! ---\nData inserted and committed.")

    except Exception as e:
        print("\n--- ERROR ---")
        print(f"CRITICAL ERROR: {e}")
        print("--- UNROLLING changes or commits ---")
        raise
    finally:
        connection.close()
        print("\n--- CONNECTION ---\nConnection closed safely.")


def main() -> None:
    run_data_generation(dotenv_path=None, reset_first=True)


if __name__ == "__main__":
    main()