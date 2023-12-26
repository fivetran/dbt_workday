with worker_position_data as (

    select 
        worker_id,
        position_id,
        replace(employee_type, '_', ' ') as type,
        business_title,
        full_time_equivalent_percentage as fte_percent,
        start_date as position_start_date,
        end_date as position_end_date,
        effective_date as position_effective_date,
        business_site_summary_location as position_location,
        management_level_code,
        job_profile_id,
        case when end_date is null
            then date_diff(CURRENT_DATE(), start_date, day)
            else date_diff(end_date, start_date, day)
            end as days_at_position,
        row_number() over (partition by worker_id order by end_date desc) as rn
    from {{ var('worker_position') }} 
),



worker_position_measures as (

    select 
        worker_id, 
        count(distinct position_id) as worker_positions,
        count(distinct management_level_code) as worker_levels,
        sum(days_at_position) as position_days
    from worker_position_data
    group by 1
),


most_recent_position as (

    select *
    from worker_position_data
    where rn = 1
),


worker_position_enriched as (

    select
        most_recent_position.worker_id,
        most_recent_position.position_id, 
        most_recent_position.business_title,
        most_recent_position.job_profile_id, 
        most_recent_position.type as most_recent_position_type,
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
    left join worker_position_measures using(worker_id)
)

select * 
from worker_position_enriched