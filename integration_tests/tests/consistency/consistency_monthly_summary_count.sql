{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('employee_history_enabled', false)
) }}

with prod as (
    select 
        1 as join_key,
        count(*) as total_prod_pr_count
    from {{ target.schema }}_workday_prod.workday__monthly_summary
    group by 1
),

dev as (
    select 
        1 as join_key,
        count(*) as total_dev_pr_count
    from {{ target.schema }}_workday_dev.workday__monthly_summary
    group by 1
),

final as (
    select
        total_prod_pr_count,
        total_dev_pr_count
    from prod
    full outer join dev
        on dev.join_key = prod.join_key
)

select *
from final
where total_dev_pr_count != total_prod_pr_count