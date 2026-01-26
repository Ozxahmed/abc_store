-- 06_employees_tables.sql
-- Employees and departments


------------------------------
-- DEPARTMENTS
------------------------------
CREATE TABLE employees.departments (
    department_id  SERIAL,
    name           VARCHAR(100) NOT NULL,
    manager_id     INT,  -- will reference employees.employee_id

    CONSTRAINT departments_pkey
        PRIMARY KEY (department_id)
);

COMMENT ON TABLE employees.departments IS 'Business departments within the company (e.g. Sales, HR, IT)';


------------------------------
-- EMPLOYEES
------------------------------
CREATE TABLE employees.employees (
    employee_id    SERIAL,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE,
    department_id  INT,
    salary         NUMERIC(10, 2) NOT NULL,

    CONSTRAINT employees_pkey
        PRIMARY KEY (employee_id),

    CONSTRAINT employees_email_unique
        UNIQUE (email),

    CONSTRAINT employees_salary_nonnegative_chk
        CHECK (salary >= 0)
);

COMMENT ON TABLE employees.employees IS 'Employee master data, including department and salary';


------------------------------
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
