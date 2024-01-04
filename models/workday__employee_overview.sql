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
        *,
        case when days_of_employment >= 365 then true else false end as employed_one_year,
        case when days_of_employment >= 365*5 then true else false end as employed_five_years,
        case when days_of_employment >= 365*10 then true else false end as employed_ten_years,
        case when days_of_employment >= 365*20 then true else false end as employed_twenty_years,
        case when days_of_employment >= 365*30 then true else false end as employed_thirty_years,
        case when days_of_employment >= 365 and is_user_active then true else false end as is_current_employee_one_year,
        case when days_of_employment >= 365*5 and is_user_active then true else false end as is_current_employee_five_years,
        case when days_of_employment >= 365*10 and is_user_active then true else false end as is_current_employee_ten_years,
        case when days_of_employment >= 365*20 and is_user_active then true else false end as is_current_employee_twenty_years,
        case when days_of_employment >= 365*30 and is_user_active then true else false end as is_current_employee_thirty_years
    from int_worker_base
    left join int_worker_personal_details using(worker_id) 
    left join int_worker_position_enriched using(worker_id) 
)

select *
from worker_employee_enhanced
