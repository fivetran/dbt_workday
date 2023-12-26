with job_profile_data as (

    select * 
    from {{ var('job_profile') }}
),


job_family_profile_data as (

    select 
        job_family_id,
        job_profile_id
    from {{ var('job_family_job_profile') }}
),

job_family_data as (

    select 
        id as job_family_id, 
        job_family_code,
        summary
    from {{ var('job_family') }}
),

job_family_job_family_group_data as (

    select 
        job_family_group_id,
        job_family_id
    from {{ var('job_family_job_family_group') }}
),

job_family_group_data as (

    select 
        id as job_family_group_id,
        job_family_group_code,
        summary as job_family_group_summary
    from {{ var('job_family_group') }}
),

job_data_enhanced as (

    select
        job_profile_data.id as job_profile_id,
        job_profile_data.job_profile_code, 
        job_profile_data.title as job_title,
        job_profile_data.private_title as job_title_private,
        job_profile_data.summary as job_summary,
        job_profile_data.description as job_description,
        job_family_data.job_family_id, 
        job_family_job_family_group_data.job_family_group_id,
        job_family_data.job_family_code,
        job_family_data.summary as job_family_summary,
        job_family_group_data.job_family_group_code,
        job_family_group_data.job_family_group_summary
    from job_profile_data 
    left join job_family_profile_data 
        on job_profile_data.id = job_family_profile_data.job_profile_id
    left join job_family_data
        on job_family_profile_data.job_family_id = job_family_data.job_family_id
    left join job_family_job_family_group_data
        on job_family_job_family_group_data.job_family_id = job_family_data.job_family_id
    left join job_family_group_data 
        on job_family_job_family_group_data.job_family_group_id = job_family_group_data.job_family_group_id
)

select *
from job_data_enhanced 