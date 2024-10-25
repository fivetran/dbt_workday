{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

-- this test ensures the workday__monthly_summary end model matches the prior version.
-- for now we only look at non-active metrics since this PR is changing that logic
with prod as (
    select metrics_month,
        source_relation,
        new_employees,
        churned_employees,
        churned_voluntary_employees,
        churned_involuntary_employees,
        churned_workers
    from {{ target.schema }}_workday_prod.workday__monthly_summary 
),

dev as (
    select metrics_month,
        source_relation,
        new_employees,
        churned_employees,
        churned_voluntary_employees,
        churned_involuntary_employees,
        churned_workers 
    from {{ target.schema }}_workday_dev.workday__monthly_summary 
),

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final