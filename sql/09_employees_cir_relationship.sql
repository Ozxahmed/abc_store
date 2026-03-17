------------------------------
-- EMPLOYEES Schema 
-- FOREIGN KEYS (circular relationship)
------------------------------
-- Employee -> Department (many-to-one)
ALTER TABLE employees.employees
    ADD CONSTRAINT employees_department_id_fk
        FOREIGN KEY (department_id)
        REFERENCES employees.departments(department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Department -> Employee (manager is also an employee)
ALTER TABLE employees.departments
    ADD CONSTRAINT departments_manager_id_fk
        FOREIGN KEY (manager_id)
        REFERENCES employees.employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;
