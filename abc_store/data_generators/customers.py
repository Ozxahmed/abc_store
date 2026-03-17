"""Generators for customers schema tables."""

import random
from faker import Faker



def generate_customers(cursor, num_customers=50):

    print("Generating customers.customers data...")
    
    # Generate data
    fake = Faker()
    customers = []

    for _ in range(num_customers):
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = fake.email()
        phone = fake.numerify('(###)###-####') # Define a pattern for a 10-digit phone number
        customers.append((first_name, last_name, email, phone))
    
    # Insert data
    query = """
    INSERT INTO customers.customers (first_name, last_name, email, phone)
    VALUES (%s, %s, %s, %s)
    """
    cursor.executemany(query, customers)

    # Confirmation message
    print("customers.customers populated successfully.")



def generate_customer_addresses(cursor):

    print("Generating customers.customer_addresses data...")
        
    # Generate data
    fake = Faker()
    customer_addresses_data = []
    addy_st_types = ['Street', 'Avenue', 'Boulevard', 'Court', 'Drive', 'Lane', 'Place', 'Road', 'Terrace']

    # city_state_ids
    query_city_state_ids = """
    SELECT city_state_id FROM mapping.cities;
    """
    cursor.execute(query_city_state_ids)
    city_state_ids = [r[0] for r in cursor.fetchall()]
    if not city_state_ids:
        raise ValueError("mapping.cities is empty")

    # customer_ids
    query_customer_ids = """
    SELECT customer_id FROM customers.customers;
    """
    cursor.execute(query_customer_ids)
    customer_ids = [r[0] for r in cursor.fetchall()]
    if not customer_ids:
        raise ValueError("customers.customers is empty")

    for customer_id in customer_ids:
        customer_id = customer_id
        addy_st_number = fake.building_number()
        addy_st_name = fake.street_name()
        addy_st_type = random.choice(addy_st_types)
        street = f"{addy_st_number} {addy_st_name} {addy_st_type}"
        city_state_id = random.choice(city_state_ids)
        zip_code = fake.zipcode()

        # 1. Add billing address
        customer_addresses_data.append((customer_id, street, city_state_id, zip_code, 'billing'))

        # 2. Add shipping address: Randomly decide if shipping address is the same or different than billing address
        if random.choice([True, False]):
            customer_addresses_data.append((customer_id, street, city_state_id, zip_code, 'shipping'))
        else:
            # Generate different shipping address
            addy_st_number = fake.building_number()
            addy_st_name = fake.street_name()
            addy_st_type = random.choice(addy_st_types)
            street = f"{addy_st_number} {addy_st_name} {addy_st_type}"
            city_state_id = random.choice(city_state_ids)
            zip_code = fake.zipcode()
            customer_addresses_data.append((customer_id, street, city_state_id, zip_code, 'shipping'))

    # Insert data
    query = f"""
    INSERT INTO customers.customer_addresses(customer_id, street, city_state_id, zip_code, address_type)
    VALUES (%s, %s, %s, %s, %s)
    """
    cursor.executemany(query, customer_addresses_data)

    # Confirmation message
    print(f'customers.customer_addresses populated with {len(customer_addresses_data)} records successfully.')
