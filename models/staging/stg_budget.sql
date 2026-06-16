-- models/staging/stg_budget.sql

SELECT
    budget_id,
    account_id,
    fiscal_year,
    UPPER(quarter)              AS quarter,
    budgeted_amount,
    actual_amount,
    actual_amount - budgeted_amount  AS variance,
    updated_at
FROM {{ source('raw', 'budget') }}