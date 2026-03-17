"""Generators for employees schema tables."""

import random
from faker import Faker



def generate_departments(cursor):

    print("Generating employees.departments data...")

    # Generate data
    departments_data = [
        ('HR', None), ('IT', None), ('Sales', None), ('Marketing', None), ('Finance', None)
    ]

    # Insert data
    query = "INSERT INTO employees.departments(name, manager_id) VALUES (%s, %s)"
    cursor.executemany(query, departments_data)
    
    # Confirmation message
    print(f"employees.departments populated with {len(departments_data)} records successfully.")



def generate_employees(cursor, num_employees=50):

    print("Generating employees.employees data...")
    
    # Generate data
    fake = Faker()
    employees_data = []
    
    for _ in range(num_employees):
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = f"{first_name.lower()}.{last_name.lower()}@dummycompany.com"
        start_date = fake.date_between(start_date='-5y', end_date='today')
        dept_id = random.randint(1, 5)
        salary = random.randint(40000, 120000)
        employees_data.append((first_name, last_name, email, start_date, None, dept_id, salary))
        
    # Insert data
    query = """
    INSERT INTO employees.employees(first_name, last_name, email, start_date, end_date, department_id, salary)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    cursor.executemany(query, employees_data)

    # Insertion confirmation message
    print(f'{num_employees} employees inserted successfully.')

    # Assign employees.departments.managers_id
    print('Assigning department managers based on highest salary...')
    
    update_manager_id_query = """
    WITH ranked AS (
        SELECT employee_id, department_id,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC, employee_id ASC) AS rn
        FROM employees.employees
    )
    UPDATE employees.departments d
    SET manager_id = r.employee_id
    FROM ranked r
    WHERE d.department_id = r.department_id AND r.rn = 1;
    """
    cursor.execute(update_manager_id_query)
    
    # Update confirmation message
    print('employees.departments.manager_id updated successfully.')
