{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with worker_history as (

    select *
    from {{ ref('stg_workday__worker_history') }}
),

worker_position_history as (

    select *
    from {{ ref('stg_workday__worker_position_history') }}
),

employee_daily_history as (

    select *
    from {{ ref('workday__employee_daily_history') }}
),


--to segment out workers who did not have a start date prior to the spine cutoff
worker_last_start_date as (

    select worker_id,  
        source_relation,
        cast(max(_fivetran_start) as date) as max_start_date
    from worker_history
    group by 1, 2
),

employee_source as (

    select
        worker_history.worker_id,
        worker_history.source_relation,
        worker_position_history.position_id,
        worker_position_history.position_start_date
    from worker_history 
    join worker_last_start_date 
        on worker_history.worker_id = worker_last_start_date.worker_id
        and cast('{{ var('employee_history_start_date','2005-03-01') }}' as date) >= worker_last_start_date.max_start_date
    left join worker_position_history 
        on worker_history.worker_id = worker_position_history.worker_id
        and worker_history.source_relation = worker_position_history.source_relation
        and worker_history._fivetran_start <= worker_position_history._fivetran_end
        and worker_history._fivetran_end >= worker_position_history._fivetran_start
    group by 1, 2, 3, 4 
),

employee_end as (

    select 
        employee_id
    from employee_daily_history 
    group by 1
),

source_count as (
    select 
        1 as join_key,
        count(*) as total_employee_source
    from employee_source
    group by 1
),

end_count as (
    select 
        1 as join_key,
        count(*) as total_employee_end
    from employee_end
    group by 1
),

final as (
    select
        total_employee_source,
        total_employee_end
    from source_count
    full outer join end_count
        on source_count.join_key = end_count.join_key
)

select *
from final
where total_employee_source != total_employee_end
