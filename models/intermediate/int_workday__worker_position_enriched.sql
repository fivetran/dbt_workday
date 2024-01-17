with worker_position_data as (

    select 
        *,
        {{ dbt.current_timestamp_backcompat() }} as current_date
    from {{ ref('stg_workday__worker_position') }}
),

worker_position_data_enhanced as (

    select 
        worker_id,
        position_id,
        employee_type, 
        business_title,
        full_time_equivalent_percentage as fte_percent,
        start_date as position_start_date,
        end_date as position_end_date,
        effective_date as position_effective_date,
        business_site_summary_location as position_location,
        management_level_code,
        job_profile_id,
        case when end_date is null
            then {{ dbt.datediff('start_date', 'current_date', 'day') }}
            else {{ dbt.datediff('start_date', 'end_date', 'day') }}
        end as days_at_position,
        row_number() over (partition by worker_id order by end_date desc) as row_number
    from worker_position_data
),

worker_position_measures as (

    select 
        worker_id, 
        count(distinct position_id) as worker_positions,
        count(distinct management_level_code) as worker_levels,
        sum(days_at_position) as position_days
    from worker_position_data_enhanced
    group by 1
),

most_recent_position as (

    select *
    from worker_position_data_enhanced
    where row_number = 1
),

worker_position_enriched as (

    select
        most_recent_position.worker_id,
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
)

select * 
from worker_position_enriched