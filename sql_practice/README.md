# SQL Practice Roadmap (PostgreSQL, Dummy DB)

## Goals

- Master joins, aggregation, subqueries, CTEs, window functions.
- Build repeatable practice with increasing difficulty, testing, and performance checks.

## Progression

1. Foundations → `01_foundations/`
   - Foreign-key fundamentals using your schemas.
   - Date/time functions, type casting, basic arithmetic.
   - Quick reps: “Top 10 newest rows,” “Last 7 days,” “Basic derived columns.”

2. Joins → `02_joins/`
   - `INNER`, `LEFT`, `RIGHT`, `FULL` joins across 2–4 tables.
   - Anti-joins: `LEFT JOIN ... IS NULL` vs `NOT EXISTS`.
   - Deliverables: 12 reps (blend of 2–4 table joins).

3. Aggregation → `03_aggregation/`
   - GROUP BY, HAVING, multi-level grouping, rollups.
   - KPIs: revenue by day/week/month; sales by category/supplier; avg order size; repeat vs new customers.
   - Optional: rollups/cubes if helpful for summaries.
   - Deliverables: 12 reps + 2 “dashboards in SQL” (a single query per dashboard).

4. Subqueries → `04_subqueries/`
   - Subqueries in `WHERE` (semi/anti), `FROM` (derived tables), and correlated subqueries.
   - Patterns: “Top-N per group,” “Entities with no recent activity,” “Threshold filters.”
   - Deliverables: 10 reps (mix correlated/non-correlated).

5. CTEs → `05_ctes/`
   - Multi-CTE pipelines (staging → filtered → aggregated → final).
   - Use CTEs to replace nested subqueries and to structure complex logic.
   - Reuse CTE outputs for multiple calculations.
   - Deliverables: 8 reps (including 2 with 3+ CTEs).

6. Window Functions → `06_window_functions/`
   - ROW_NUMBER, RANK, DENSE_RANK, NTILE
   - `LAG/LEAD`, running totals, moving averages.
   - “Top item per group with tie handling,” “WoW deltas,” “Streaks/retention.”
   - Deliverables: 12 reps (at least 4 using PARTITION BY + ORDER BY thoughtfully).

7. Set Ops & CASE → `07_set_ops_case/`
   - `UNION` / `UNION ALL` / `INTERSECT` / `EXCEPT`.
   - `CASE WHEN` bucketing and flags (VIPs, tiers, risk levels).
   - Blend with prior modules to build compact reporting queries.
   - Deliverables: 6 reps (e.g., flag VIPs, bucket AOV tiers, union historical snapshots).

8. Performance & Indexing → `08_performance/`
   - `EXPLAIN (ANALYZE, BUFFERS)` to understand access paths.
   - Choose indexes based on plans (single vs composite; covering; partial).
   - Before/after timings + short rationale in `notes.md`.
   - Deliverables: tune 3 queries; record before/after timings + plans.

9. Capstone Challenges → `09_capstone/`
    - [ ] **Sales Analytics:** rolling 28-day revenue, MoM growth, top products per category (tie-safe).
    - [ ] **Customer Behavior:** first-order cohort retention, repeat rate, churn candidates (no activity in N days).
    - [ ] **Ops View:** supplier fill rates, shipment cycle times, stockout risk.
    - [ ] **People Analytics:** dept headcount trend, hire/separation flow, span of control.

## Weekly Milestones (example)

- **W1:** Foundations + Joins + Aggregation → deliver KPI pack.
- **W2:** Subqueries + CTEs → deliver a pipeline-style query.
- **W3:** Window functions → rankings/retention pack.
- **W4:** Performance + DQ suite + Capstone.

## Ground Rules

- Prefer CTEs + clear aliases over deeply nested queries.
- Use `EXPLAIN (ANALYZE, BUFFERS)` for slow queries before adding indexes.
- Keep basic drills in rotation even as difficulty rises.
- Integrate DQ checks into practice, not as a separate chore.

## Files

- [`PROGRESS.md`](./PROGRESS.md) — running log & scorecard.
- [`notes.md`](./notes.md) — EXPLAIN findings, index decisions, gotchas.
- [`dq_snippets.sql`](./dq_snippets.sql) — reusable data-quality checks.

## Folder Layout

SQL_practice/
├─ README.md
├─ PROGRESS.md            # tracking table (or PROGRESS.csv if you prefer Sheets)
├─ notes.md               # findings/decisions/EXPLAIN notes
├─ dq_snippets.sql
├─ 01_foundations/
│  ├─ 01_filters_sorting.sql
│  └─ 02_dates_calcs.sql
├─ 02_joins/
│  ├─ 01_inner_joins.sql
│  ├─ 02_left_right_full.sql
│  └─ 03_anti_joins.sql
├─ 03_aggregation/
│  ├─ 01_groupby_having.sql
│  ├─ 02_multilevel_grouping.sql
│  └─ 03_rollups.sql
├─ 04_subqueries/
├─ 05_ctes/
├─ 06_window_functions/
├─ 07_set_ops_case/
├─ 08_performance/
│  ├─ 01_explain_examples.sql
│  └─ 02_index_experiments.sql
└─ 09_capstone/
   ├─ sales_analytics.sql
   ├─ customer_behavior.sql
   ├─ ops_people_analytics.sql
   └─ people_analytics.sql
