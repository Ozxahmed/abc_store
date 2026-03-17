"""Generators for mapping schema tables."""

import random
from faker import Faker



def generate_mapping_US_states(cursor):

    print("Generating mapping.states data...")
    
    # Generate data
    us_states = [
            ('Alabama', 'AL'), ('Alaska', 'AK'), ('Arizona', 'AZ'), ('Arkansas', 'AR'),
            ('California', 'CA'), ('Colorado', 'CO'), ('Connecticut', 'CT'), ('Delaware', 'DE'),
            ('Florida', 'FL'), ('Georgia', 'GA'), ('Hawaii', 'HI'), ('Idaho', 'ID'),
            ('Illinois', 'IL'), ('Indiana', 'IN'), ('Iowa', 'IA'), ('Kansas', 'KS'),
            ('Kentucky', 'KY'), ('Louisiana', 'LA'), ('Maine', 'ME'), ('Maryland', 'MD'),
            ('Massachusetts', 'MA'), ('Michigan', 'MI'), ('Minnesota', 'MN'), ('Mississippi', 'MS'),
            ('Missouri', 'MO'), ('Montana', 'MT'), ('Nebraska', 'NE'), ('Nevada', 'NV'),
            ('New Hampshire', 'NH'), ('New Jersey', 'NJ'), ('New Mexico', 'NM'), ('New York', 'NY'),
            ('North Carolina', 'NC'), ('North Dakota', 'ND'), ('Ohio', 'OH'), ('Oklahoma', 'OK'),
            ('Oregon', 'OR'), ('Pennsylvania', 'PA'), ('Rhode Island', 'RI'), ('South Carolina', 'SC'),
            ('South Dakota', 'SD'), ('Tennessee', 'TN'), ('Texas', 'TX'), ('Utah', 'UT'),
            ('Vermont', 'VT'), ('Virginia', 'VA'), ('Washington', 'WA'), ('West Virginia', 'WV'),
            ('Wisconsin', 'WI'), ('Wyoming', 'WY'), ('District of Columbia', 'DC')
        ]
    
    # Insert data
    query = """
    INSERT INTO mapping.states(state_name, state_abbr)
    VALUES (%s, %s)
    """
    cursor.executemany(query, us_states)

    # Confirmation message
    print('mapping.states populated successfully.')



def generate_mapping_payment_methods(cursor):

    print("Generating mapping.payment_methods data...")

    # Generate data
    methods = ['Cash', 'Credit Card', 'Debit Card', 'Check']
    payment_methods_data = [(m,) for m in methods]

    # Insert data
    query = """
    INSERT INTO mapping.payment_methods(method_name) 
    VALUES (%s)
    """
    cursor.executemany(query, payment_methods_data)

    # Confirmation message
    print(f"mapping.payment_methods populated with {len(payment_methods_data)} records successfully.")



def generate_mapping_cities(cursor, num_cities=100):

    print("Generating mapping.cities data...")
        
    # Generate data
    fake = Faker()
    cities_data = []

    # state_ids
    query_state_ids = """
    SELECT state_id FROM mapping.states;
    """
    cursor.execute(query_state_ids)
    state_ids = [r[0] for r in cursor.fetchall()]
    if not state_ids:
        raise ValueError("mapping.states is empty")

    for _ in range(1, num_cities+1):
        city_name = fake.city()
        state_id = random.choice(state_ids)
        cities_data.append((city_name, state_id))

    # Insert data
    query = """
    INSERT INTO mapping.cities (city_name, state_id)
    VALUES (%s, %s)
    """
    cursor.executemany(query, cities_data)

    # Confirmation message
    print(f'mapping.cities populated with {num_cities} records successfully.')
