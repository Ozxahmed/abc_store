"""Generators for inventory schema tables."""

import random
from faker import Faker



def generate_products(cursor, num_products=50):

    print("Generating inventory.products data...")

    # Generate data
    fake = Faker()
    products = []

    for _ in range(num_products):
        name = fake.word().capitalize()  # Product name
        description = fake.sentence(nb_words=10)  # Short description
        price = round(random.uniform(10, 1000), 2)  # Price between 10 and 1000
        stock_quantity = fake.random_int(min=1, max=500)  # qty between 1 and 500
        products.append((name, description, price, stock_quantity))
    
    # Insert data
    query = """
    INSERT INTO inventory.products (name, description, price, stock_quantity)
    VALUES (%s, %s, %s, %s)
    """
    cursor.executemany(query, products)
    
    # Confirmation message
    print('inventory.products populated successfully.')



def generate_suppliers(cursor, num_suppliers=10):

    print("Generating inventory.suppliers data...")
    
    # Generate data
    fake = Faker()
    suppliers = []
    
    for _ in range(1, num_suppliers + 1):
        name = fake.company()
        contact_info = fake.phone_number()
        suppliers.append((name, contact_info))
    
    # Insert data
    query = """
        INSERT INTO inventory.suppliers(name, contact_info)
        VALUES (%s, %s)
        """
    cursor.executemany(query, suppliers)

    # Confirmation message
    print(f'inventory.suppliers populated with {num_suppliers} suppliers successfully.')



def generate_inventory_shipments(cursor, num_shipments=50):

    print("Generating inventory.shipments data...")
    
    # Generate data
    fake = Faker()
    shipments = []

    # supplier_ids
    query_supplier_ids = """
    SELECT supplier_id FROM inventory.suppliers
    """
    cursor.execute(query_supplier_ids)
    supplier_ids = [r[0] for r in cursor.fetchall()]
    if not supplier_ids:
        raise ValueError("inventory.suppliers is empty")
    
    # status_options
    status_options = ['Shipped', 'Delivered', 'Pending']

    for _ in range(1, num_shipments + 1):
        supplier_id = random.choice(supplier_ids)
        shipment_date = fake.date_between(start_date='-1y', end_date='today')
        status = random.choice(status_options)
        shipments.append((supplier_id, shipment_date, status))
    
    # Insert data
    query = """
    INSERT INTO inventory.shipments(supplier_id, shipment_date, status)
    VALUES (%s, %s, %s)
    """
    cursor.executemany(query, shipments)

    # Confirmation message
    print(f'inventory.shipments populated with {num_shipments} shipments successfully.')
