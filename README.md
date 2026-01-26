# things to do

## Big picture to do

- [ ] dummy project
  - dockerize
  - readme
  - load project onto gitlab
- [ ] gitlab
  - set up profile page
- [ ] linkedin
  - update profile

## Dockerize to do

- [ ] Folder structure- Create folders with scripts within 12/8
  - [x] schema (folder + scripts) -> These define structure (schemas, tables, constraints, triggers, functions); No data inserted here.
    - [x] test scripts on test database
  
  - [ ] /scripts/python (folder + scripts) -> python scripts for generating the fake data. This will not run, and is just there to show the script to generate the data.
    - [ ] test script against test db, to make sure the python code has all the correct columns, etc.
  
  - [ ] data (folder + scripts) -> These are INSERT (or COPY) scripts that populate the DB with the dummy data. This is the snapshot of the data produced by the python code, which is stored in in the `scripts` folder. The python code is just there to show what was done to generate the data, it won't be ran when running the docker container. Instead the snapshot (the data) will be uploaded once the schema is built.

- [ ] docker init- 'init.sql' or '/docker-entrypoint-initdb.d'? -> Docker runs on first startup
  - [ ] test sql scripts with adminer
  - [ ] (Optional) seeding service to run python scripts inside docker

- [ ] test sql scripts with adminer
- [ ] (Optional) seeding service to run python scripts inside docker

## README to do

- [ ] Project overview and goals
- [ ] Folder structure and data flow explanation
- [ ] To-do list / roadmap for future improvements
- [ ] Add **ERD diagram** to visualize schema
- [ ] Add section for **Advanced SQL queries**
  - Suggested formats:
    - `queries.md` (Markdown file with annotated SQL)
    - or `queries.ipynb` (Jupyter notebook showing outputs)

## (optional) to do

- [ ] Rename pkey col `sales.order_details.order_item_id` to `order_details_id`. This will have to be done in **sql** scripts and **python** scripts.

### Rough outline

In your README.md, I’d structure it like:

````md
# Dummy Company ABC – SQL Practice Environment

## Overview
- Purpose of the project
- Tech stack: PostgreSQL, Docker, Adminer

## Database Structure
- Schemas: customers, employees, inventory, mapping, sales, analytics
- Brief description of each schema & main tables
- Mention triggers (stock update, order totals, etc.)

## How to Run

```bash
git clone <repo>
cd dummy_company_abc
docker compose up -d
```

- How to access Adminer (<http://localhost:8080>)
- Connection details (user, pass, db)

## SQL Practice Phases

- Step 1: intermediate SQL (joins, filters, group by)
- Step 2: advanced SQL (CTEs, window functions, etc.)
- Step 3: analytics & staging tables
````

### Manual schema approach within docker container

I’d literally brag about the manual-schema approach in the README:

```md
This project is intentionally initialized using hand-written SQL DDL and DML scripts (rather than a pg_dump) so that:

- the database structure (schemas, tables, constraints, triggers, functions, and indexes) is fully transparent and reviewable, and

- the data generation logic (Python scripts under scripts/python) is separated from the final seed SQL, making it easy to reason about both modeling and ETL.
```

That tells them:

- you care about transparency,
- you understand schema vs data,
- you know how to structure a maintainable data project repo.

### SQL client for container

Start with **Adminer**.

In the README, **explicitly** mention:

- “You can also connect with any external SQL client (DBeaver, psql, DataGrip, pgAdmin, etc.) using these connection details…”

That shows you know the ecosystem without burdening the docker-compose file.

### Functions/Triggers

I'm going to leave the functions in the **public schema**, and in the sql script a note as to why I'm leaving it in public, and acknowledge that **the cleaner and 'best practices' option would be to add function within the schemas where the related data resides.**

```sql
-- List all non-system functions with their full DDL
SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_ddl
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND p.prokind = 'f'          -- 'f' = function (not agg/procedure)
ORDER BY n.nspname, p.proname;


-- List all triggers
SELECT
    event_object_schema AS table_schema,
    event_object_table  AS table_name,
    trigger_name,
    action_timing,        -- BEFORE / AFTER
    event_manipulation,   -- INSERT / UPDATE / DELETE
    action_statement
FROM information_schema.triggers
ORDER BY table_schema, table_name, trigger_name;
```

### Possible future expansions/improvements

#### Shipping details + purchasing system

my prompt:

```md
I think I'm being OCD now, but I feel like we need more details on shipments, as in what products are being shipped within each shipment, also maybe a mechanism for tracking product prices. The workflow I'm thinking is: suppliers provide product quotes --> record this within the database --> then we issue a purchase order to the supplier --> record this --> Supplier ships --> we record this.
```

ChatGPT:

```md
Yeah, that “this could be more realistic…” voice in your head is the data-modeling brain turning on 😂
You’re right: quotes → POs → shipments → shipment line items → price history is how a real system would evolve… but that’s also exactly how a nice clean practice DB turns into a mini-ERP and eats your entire weekend.

For this project’s goals (SQL practice + portfolio + dockerized demo), I’d say:

✅ Keep shipments simple in v1, and
✅ Park quotes/POs/price history as a “v2 enhancements” section in your README.

You can even brag there: “Here’s how I’d extend this toward a purchasing system in the future.”
```

#### Audit Logging

One future enhancement I’d like to add is a dedicated **`log` schema** for audit logging. The idea is to keep a change history for important tables (e.g. `sales.orders`, `sales.order_details`, `sales.payments`) using **row-level triggers**:

- Add **per-table log tables** such as `log.order_details_changes`.
- Each log record would capture:
  - The table and primary key of the row that changed.
  - The operation type (`INSERT`, `UPDATE`, or `DELETE`).
  - Timestamps and (optionally) which user performed the change.
  - A JSON snapshot of the **old** row, the **new** row, and a list of **changed columns**.
- A `BEFORE`/`AFTER` trigger on each base table would write a log row whenever data is inserted, updated, or deleted.

This would make it easy to answer questions like:

- “Who changed this order and what exactly changed?”
- “What was the previous stock quantity for this product?”

Longer-term, this could be extended to:

- A **single global audit table** for all tables in the database.
- Integration with **pgAudit** or **logical decoding / CDC** tools (e.g. Debezium) to stream changes out of Postgres into a data lake or event bus.

### Database design

#### Indexing

#### Triggers

### SQL Exercises

Question ideas:

- How many customers have different shipping addresses that are different from their billing address.
