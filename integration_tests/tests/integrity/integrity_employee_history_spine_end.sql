{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('employee_history_enabled', false)
) }}

-- The daily history models can't extend past today plus `employee_history_future_months`, even if the source has a far-future start date.
-- Returns a row for any model whose last date is past that cap.

with future_cap as (

    select cast({{ dbt.dateadd('month', var('employee_history_future_months', 12), dbt.current_timestamp()) }} as date) as max_allowed_date
),

last_dates as (

    select 'workday__employee_daily_history' as model_name, max(date_day) as last_date_day
    from {{ ref('workday__employee_daily_history') }}

    union all

    select 'workday__worker_position_org_daily_history' as model_name, max(date_day) as last_date_day
    from {{ ref('workday__worker_position_org_daily_history') }}
)

select
    last_dates.model_name,
    last_dates.last_date_day,
    future_cap.max_allowed_date
from last_dates
cross join future_cap
where last_dates.last_date_day > future_cap.max_allowed_date
