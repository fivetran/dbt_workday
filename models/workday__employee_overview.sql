with int_worker_base as (

    select * 
    from {{ ref('int_workday__worker_details') }} 
),

int_worker_personal_details as (

    select * 
    from {{ ref('int_workday__personal_details') }} 
),


int_worker_position_enriched as (

    select * 
    from {{ ref('int_workday__worker_position_enriched') }} 
), 

worker_employee_enhanced as (

    select 
        int_worker_base.*,
        first_name,
        last_name,
        date_of_birth,
        gender,
        is_hispanic_or_latino,
        email_address,
        ethnicity_codes,
        military_status,
        position_id,
        business_title,
        job_profile_id,
        most_recent_position_type,
        most_recent_location,
        most_recent_level,
        fte_percent,
        days_at_position,
        most_recent_position_start_date,
        most_recent_position_end_date,
        most_recent_position_effective_date,
        worker_positions,
        worker_levels,
        position_days,
        case when days_of_employment >= 365 
            then true 
            else false 
        end as is_employed_one_year,
        case when days_of_employment >= 365*5 
            then true 
            else false 
        end as is_employed_five_years,
        case when days_of_employment >= 365*10 
            then true 
            else false 
        end as is_employed_ten_years,
        case when days_of_employment >= 365*20 
            then true 
            else false 
        end as is_employed_twenty_years,
        case when days_of_employment >= 365*30 
            then true 
            else false 
        end as is_employed_thirty_years,
        case when days_of_employment >= 365 and is_user_active 
            then true 
            else false 
        end as is_current_employee_one_year,
        case when days_of_employment >= 365*5 and is_user_active
            then true 
            else false 
        end as is_current_employee_five_years,
        case when days_of_employment >= 365*10 and is_user_active 
            then true 
            else false 
        end as is_current_employee_ten_years,
        case when days_of_employment >= 365*20 and is_user_active 
            then true 
            else false 
        end as is_current_employee_twenty_years,
        case when days_of_employment >= 365*30 and is_user_active 
            then true 
            else false 
        end as is_current_employee_thirty_years
    from int_worker_base
    left join int_worker_personal_details 
        on int_worker_base.worker_id = int_worker_personal_details.worker_id
        and int_worker_base.source_relation = int_worker_personal_details.source_relation
    left join int_worker_position_enriched
        on int_worker_base.worker_id = int_worker_position_enriched.worker_id
        and int_worker_base.source_relation = int_worker_position_enriched.source_relation
)

select *
from worker_employee_enhanced
