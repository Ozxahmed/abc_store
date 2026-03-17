"""Generators for sales schema tables."""

import random
from faker import Faker



def generate_sales_orders(cursor, n=500):
    """
    Insert n orders with total_amount placeholder = 0.00.
    """

    print('Generating sales.orders data...')
    
    # Generate data
    fake = Faker()
    orders_data = []

    # customer_ids
    customer_ids_query = """
    SELECT customer_id FROM customers.customers;
    """
    cursor.execute(customer_ids_query)
    customer_ids = [r[0] for r in cursor.fetchall()]
    if not customer_ids:
        raise ValueError("customers.customers is empty")

    for _ in range(n):
        customer_id = random.choice(customer_ids)
        order_date = fake.date_between(start_date='-1y', end_date='today')
        total_amount_placeholder = 0.00
        orders_data.append((customer_id, order_date, total_amount_placeholder))

    # Insert data
    query = """
    INSERT INTO sales.orders (customer_id, order_date, total_amount)
    VALUES (%s, %s, %s)
    """
    cursor.executemany(query, orders_data)

    # Confirmation message
    print(f'sales.orders populated by {n} records successfully.')



def generate_sales_order_details(cursor):
    """
    Insert order_details and update sales.orders.total_amount using sum(line_item_total).
    """

    print('Generating sales.order_details data...')
    
    # Generate data
    sales_order_details_data = []

    # order_ids
    order_ids_query = """
    SELECT order_id FROM sales.orders;
    """
    cursor.execute(order_ids_query)
    order_ids = [r[0] for r in cursor.fetchall()]
    if not order_ids:
        raise ValueError("sales.orders is empty")

    # product_ids, prices
    prod_ids_prices_query = """
    SELECT product_id, price FROM inventory.products;
    """
    cursor.execute(prod_ids_prices_query)
    rows = cursor.fetchall()
    if not rows:
        raise ValueError("No products found in inventory.products")
    prod_id_price_dict = {pid: float(price) for pid, price in rows}
    product_ids = list(prod_id_price_dict.keys())

    for order_id in order_ids:
        num_items = random.randint(1, 5)  # Each order has between 1 and 5 items
        chosen_products = random.sample(product_ids, num_items)

        for product_id in chosen_products:
            qty = random.randint(1, 10)  # Each item has a quantity between 1 and 10
            item_price = prod_id_price_dict[product_id]
            line_item_total = round(item_price * qty, 2)
            sales_order_details_data.append((order_id, product_id, qty, item_price, line_item_total))

    # Insert data
    query = """
    INSERT INTO sales.order_details (order_id, product_id, quantity, item_price, line_item_total)
    VALUES (%s, %s, %s, %s, %s)
    """
    cursor.executemany(query, sales_order_details_data)

    # Insertion confirmation message
    print(f'sales.order_details populated by {len(sales_order_details_data)} records successfully.')

    # update total_amount in sales.orders
    print("Updating sales.orders.total_amount from sales.order_details.line_item_total sums...")
    
    update_totals_query = """
        UPDATE sales.orders o
        SET total_amount = t.order_total
        FROM (
            SELECT order_id, ROUND(SUM(line_item_total)::numeric, 2) AS order_total
            FROM sales.order_details
            WHERE order_id = ANY(%s)
            GROUP BY order_id
        ) t
        WHERE o.order_id = t.order_id;
    """
    cursor.execute(update_totals_query, (order_ids,))

    # Update confirmation message
    print("sales.orders.total_amount updated successfully.")



def generate_payments(cursor):

    print("Generating sales payments data...")

    # Generate data
    # order_id, total_amount, order_date from sales.orders
    cursor.execute("SELECT order_id, total_amount, order_date FROM sales.orders;")
    orders = cursor.fetchall()  # List of (order_id, total_amount, order_date)
    if not orders:
        raise ValueError("sales.orders is empty")

    # payment_method_ids from mapping.payment_methods
    cursor.execute("SELECT payment_method_id FROM mapping.payment_methods;")
    payment_methods = [row[0] for row in cursor.fetchall()]  # List of payment_method_ids
    if not payment_methods:
        raise ValueError("mapping.payment_methods is empty")

    sales_payments_data = [
        (order_id, random.choice(payment_methods), total_amount, order_date)
        for order_id, total_amount, order_date in orders
    ]

    # Insert data
    insert_query = """
    INSERT INTO sales.payments (order_id, payment_method_id, amount, payment_date)
    VALUES (%s, %s, %s, %s);
    """
    cursor.executemany(insert_query, sales_payments_data)

    # Confirmation message
    print("sales.payments populated successfully.")
