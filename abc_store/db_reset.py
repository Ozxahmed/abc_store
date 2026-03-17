"""Local development database reset helpers"""


def clear_db_schema(cursor) -> None:
    """Dynamically truncates all user-defined tables."""
    print("Clearing all user tables")

    dynamic_truncate_query = """
    SELECT 'TRUNCATE TABLE ' ||
            string_agg(quote_ident(schemaname) || '.' || quote_ident(tablename), ', ') ||
            ' RESTART IDENTITY CASCADE;'
    FROM pg_catalog.pg_tables
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        AND schemaname NOT LIKE 'pg_toast%'
        AND schemaname NOT LIKE 'pg_temp%';
    """

    cursor.execute(dynamic_truncate_query)
    row = cursor.fetchone()

    if row and row[0]:
        cursor.execute(row[0])
        print("Success: Database is now a clean slate.")
    else:
        print("Notice: No tables found to clear.")


def drop_user_triggers(cursor) -> None:
    """Drops all user-defined (non-internal) triggers across user schemas."""
    print("Dropping user-defined triggers...")

    dynamic_drop_triggers_query = """
    SELECT string_agg(
        format(
            'DROP TRIGGER IF EXISTS %I ON %I.%I;',
            t.tgname,
            n.nspname,
            c.relname
        ),
        E'\n'
    ) AS drop_sql
    FROM pg_trigger t
    JOIN pg_class c
      ON c.oid = t.tgrelid
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE NOT t.tgisinternal
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname NOT LIKE 'pg_toast%'
      AND n.nspname NOT LIKE 'pg_temp%';
    """

    cursor.execute(dynamic_drop_triggers_query)
    row = cursor.fetchone()

    if row and row[0]:
        cursor.execute(row[0])
        print("Success: User-defined triggers dropped.")
    else:
        print("Notice: No user-defined triggers found.")


def drop_business_trigger_functions(cursor) -> None:
    """Drops known business trigger functions in public schema"""
    print("Dropping business functions (if they exist)...")

    dynamic_drop_functions_query = """
    SELECT string_agg(
             format(
               'DROP FUNCTION IF EXISTS %I.%I(%s);',
               n.nspname,
               p.proname,
               pg_get_function_identity_arguments(p.oid)
             ),
             E'\\n'
           ) AS drop_sql
    FROM pg_proc p
    JOIN pg_namespace n
      ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'autofill_order_details',
        'manage_stock_for_order_details',
        'sync_order_total_from_details',
        'validate_payment_against_order'
      );
    """

    cursor.execute(dynamic_drop_functions_query)
    row = cursor.fetchone()

    if row and row[0]:
        cursor.execute(row[0])
        print("Success: Business trigger functions dropped.")
    else:
        print("Notice: No business trigger functions found.")
