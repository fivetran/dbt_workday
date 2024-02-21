with worker_position_data as (

    select 
        *,
        {{ dbt.current_timestamp() }} as current_date
    from {{ ref('stg_workday__worker_position') }}
),

worker_position_data_enhanced as (

    select 
        worker_id,
        source_relation,
        position_id,
        employee_type, 
        business_title,
        fte_percent,
        position_start_date,
        position_end_date,
        position_effective_date,
        position_location,
        management_level_code,
        job_profile_id,
        case when position_end_date is null
            then {{ dbt.datediff('position_start_date', 'current_date', 'day') }}
            else {{ dbt.datediff('position_start_date', 'position_end_date', 'day') }}
        end as days_at_position,
        row_number() over (partition by worker_id order by position_end_date desc) as row_number
    from worker_position_data
),

worker_position_measures as (

    select 
        worker_id,
        source_relation,
        count(distinct position_id) as worker_positions,
        count(distinct management_level_code) as worker_levels,
        sum(days_at_position) as position_days
    from worker_position_data_enhanced
    group by 1, 2
),

most_recent_position as (

    select *
    from worker_position_data_enhanced
    where row_number = 1
),

worker_position_enriched as (

    select
        most_recent_position.worker_id,
        most_recent_position.source_relation,
        most_recent_position.position_id, 
        most_recent_position.business_title,
        most_recent_position.job_profile_id, 
        most_recent_position.employee_type as most_recent_position_type,
        most_recent_position.position_location as most_recent_location,
        most_recent_position.management_level_code as most_recent_level,
        most_recent_position.fte_percent,
        most_recent_position.days_at_position,
        most_recent_position.position_start_date as most_recent_position_start_date,
        most_recent_position.position_end_date as most_recent_position_end_date,
        most_recent_position.position_effective_date as most_recent_position_effective_date,
        worker_position_measures.worker_positions,
        worker_position_measures.worker_levels, 
        worker_position_measures.position_days
    from most_recent_position
    left join worker_position_measures 
        on most_recent_position.worker_id = worker_position_measures.worker_id
        and most_recent_position.source_relation = worker_position_measures.source_relation
)

select * 
from worker_position_enriched