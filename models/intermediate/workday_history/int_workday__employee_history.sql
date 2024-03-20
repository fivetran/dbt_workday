{{ config(enabled=var('employee_history_enabled', False)) }}

with worker_history as (

    select *
    from {{ ref('stg_workday__worker_history') }}
),

worker_position_history as (

    select *
    from {{ ref('stg_workday__worker_position_history') }}
),

personal_information_history as (

    select *
    from {{ ref('stg_workday__personal_information_history') }}
),

worker_start_records as (

    select worker_id, 
        _fivetran_start
    from worker_history
    union distinct
    select worker_id,
        _fivetran_start 
    from worker_position_history
    union distinct
    select worker_id,
        _fivetran_start
    from personal_information_history
    order by worker_id, _fivetran_start 
),

worker_history_end_values as (

    select *,
        lead({{ dbt.dateadd('microsecond', -1, '_fivetran_start') }} ) over(partition by worker_id order by _fivetran_start) as eventual_fivetran_end
    from worker_start_records   
),

worker_history_scd as (

    select *,
        coalesce(cast(eventual_fivetran_end as {{ dbt.type_timestamp() }}),
            cast('9999-12-31 23:59:59.999000' as {{ dbt.type_timestamp() }})) as _fivetran_end
    from worker_history_end_values
    order by worker_id, _fivetran_start, _fivetran_end
),

employee_history_scd as (

    select worker_history_scd.worker_id, 
        worker_position_history.position_id,
        worker_history_scd._fivetran_start,
        worker_history_scd._fivetran_end,
        worker_history._fivetran_active as wh_active,
        worker_position_history._fivetran_active as wph_active,
        personal_information_history._fivetran_active as pih_active,
        worker_history.end_employment_date as wh_end_employment_date,
        worker_position_history.end_employment_date as wph_end_employment_date,
        worker_history.pay_through_date as wh_pay_through_date,
        worker_position_history.pay_through_date as wph_pay_through_date,
        {{ dbt_utils.star(from=ref('stg_workday__worker_history'), except=["worker_id", "_fivetran_start", "_fivetran_end", "_fivetran_synced", "_fivetran_active", "_fivetran_date", "history_unique_key", "end_employment_date", "pay_through_date"]) }},
        {{ dbt_utils.star(from=ref('stg_workday__worker_position_history'), except=["worker_id", "position_id", "_fivetran_start", "_fivetran_end", "_fivetran_synced", "_fivetran_active", "_fivetran_date", "history_unique_key", "end_employment_date", "pay_through_date"])}},
        {{ dbt_utils.star(from=ref('stg_workday__personal_information_history'), except=["worker_id", "_fivetran_start", "_fivetran_end", "_fivetran_synced", "_fivetran_active", "_fivetran_date", "history_unique_key"])}}
    from worker_history_scd

    left join worker_history 
        on worker_history_scd.worker_id = worker_history.worker_id
        and worker_history_scd._fivetran_start <= worker_history._fivetran_end
        and worker_history_scd._fivetran_end >= worker_history._fivetran_start

    left join worker_position_history 
        on worker_history_scd.worker_id = worker_position_history.worker_id
        and worker_history_scd._fivetran_start <= worker_position_history._fivetran_end
        and worker_history_scd._fivetran_end >= worker_position_history._fivetran_start

    left join personal_information_history
        on worker_history_scd.worker_id = personal_information_history.worker_id
        and worker_history_scd._fivetran_start <= personal_information_history._fivetran_end
        and worker_history_scd._fivetran_end >= personal_information_history._fivetran_start

    order by worker_id, _fivetran_start, _fivetran_end
),

employee_key as (

    select {{ dbt_utils.generate_surrogate_key(['worker_id','position_id','position_start_date']) }} as employee_id,
        cast(_fivetran_start as date) as _fivetran_date,
        employee_history_scd.*
    from employee_history_scd
),

history_surrogate_key as (

    select {{ dbt_utils.generate_surrogate_key(['employee_id', '_fivetran_date']) }} as history_unique_key,
        employee_key.*
    from employee_key
)

select * 
from history_surrogate_key


