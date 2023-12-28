with worker_personal_info_data as(

    select 
        personal_information_id as worker_id, 
        date_of_birth,
        gender,
        hispanic_or_latino
    from {{ ref('stg_workday__personal_information') }}
),

worker_name as (

    select 
        personal_info_system_id as worker_id, 
        first_name,
        last_name
    from {{ ref('stg_workday__person_name') }}
    where lower(person_name_type) = 'preferred'
),

worker_email as(

    select 
        personal_info_system_id as worker_id, 
        email_address
    from {{ ref('stg_workday__person_contact_email_address') }}
    where lower(email_code) like '%work_primary%'
),

worker_ethnicity as (

    select 
        personal_info_system_id as worker_id,
        ethnicity_code
    from {{ ref('stg_workday__personal_information_ethnicity') }}
),

worker_military as (

    select 
        personal_info_system_id as worker_id,
        true as is_military_service,
        status as military_status 
    from {{ ref('stg_workday__military_service') }}
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