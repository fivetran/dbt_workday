with worker_personal_info_data as(

    select 
        id as worker_id, 
        date_of_birth,
        gender,
        hispanic_or_latino
    from {{ var('personal_information') }} 
),

worker_name as (

    select 
        personal_info_system_id as worker_id, 
        first_name,
        last_name
    from {{ var('person_name') }}
    where lower(type) = 'preferred'
),

worker_email as(

    select 
        personal_info_system_id as worker_id, 
        email_address    
    from {{ var('person_contact_email_address') }}  
    where lower(email_code) like '%work_primary%'
),

worker_ethnicity as (

    select 
        personal_info_system_id as worker_id,
        ethnicity_code 
    from {{ var('personal_information_ethnicity') }}
),

worker_military as (

    select 
        personal_info_system_id as worker_id,
        true as is_military_service,
        status as military_status
    from {{ var('military_service') }}
),

worker_personal_details as (

    select 
        worker_personal_info_data.*,
        worker_name.first_name,
        worker_name.last_name,
        worker_email.email_address,
        worker_ethnicity.ethnicity_code,
        worker_military.military_status
    from worker_personal_info_data
    left join worker_name using(worker_id)
    left join worker_email using(worker_id)
    left join worker_ethnicity using(worker_id)
    left join worker_military using(worker_id)
)

select * 
from worker_personal_details