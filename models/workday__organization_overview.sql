with organization_data as (

    select * 
    from {{ ref('stg_workday__organization') }}
),

organization_role_data as (

    select * 
    from {{ ref('stg_workday__organization_role') }}
),

organization_role_worker_data as (

    select * 
    from {{ ref('stg_workday__organization_role_worker') }}
),

organization_roles as (

    select 
        organization_role_data.organization_id,
        organization_role_data.role_id as organization_role_id,
        organization_role_data.organization_role_code as organization_role_code,
        organization_role_worker_data.associated_worker_id as organization_worker_code
    from organization_role_data
    left join organization_role_worker_data
        on organization_role_worker_data.organization_id = organization_role_data.organization_id
        and organization_role_worker_data.role_id = organization_role_data.role_id 
),

organization_data_enhanced as (

    select   
        organization_data.organization_id,
        organization_data.organization_code,
        organization_data.organization_name,
        organization_data.organization_type,
        organization_data.organization_sub_type,
        organization_data.superior_organization_id,
        organization_data.top_level_organization_id, 
        organization_data.manager_id,
        organization_roles.organization_role_id,
        organization_roles.organization_role_code,
        organization_roles.organization_worker_code 
    from organization_data
    left join organization_roles 
        on organization_roles.organization_id = organization_data.organization_id 
)

select *
from organization_data_enhanced