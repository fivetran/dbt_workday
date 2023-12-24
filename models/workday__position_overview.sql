with position_data as (

    select *
    from {{ var('position') }}
),

position_job_profile_data as (

    select *
    from {{ var('position_job_profile') }}
),

position_organization_data as (

    select *
    from {{ var('position_organization') }}
),

organization_data as (
    
    select *
    from {{ var('organization') }}
),

position_organizations as (

    select 
        position_organization_data.*,
        organization_data.organization_code,
        organization_data.name as organization_name
    
    from position_organization_data
    left join organization_data on organization.id = position_organization.organization_id
),

position_data_enhanced as (

    select
      position.id as position_id,
      position.position_code,
      position.job_posting_title as title,
      position.effective_date,
      if(position.closed, 'Closed', 'Open') as position_status,
      position.closed,
      position.hiring_freeze,
      position.available_for_hire,
      position.availability_date,
      position.available_for_recruiting,
      position.earliest_hire_date,
      position.available_for_overlap,
      position.earliest_overlap_date,
      position.worker_for_filled_position_id as filled_worker_id,
      position.worker_type_code as type_code, 
      replace(position.position_time_type_code, '_', ' ') as time_type,
      position_company.organization_id as company_id,
      position_company.organization_code as company_code,
      position.supervisory_organization_id as supervisory_department_code,
      position_cost_center.organization_id as cost_center_id,
      position_cost_center.organization_code as cost_center_code,
      position_job_profile.job_profile_id,
      -- position_locations.location_id,
      -- position_locations.location_code,
      position.compensation_package_code,
      position.compensation_grade_code,
      position.compensation_grade_profile_code
    from `dbt-package-testing.workday_hcm.position` position
    left join position_organizations as position_company on position_company.position_id = position.id
      -- and not position_company._fivetran_deleted
      and lower(position_company.type) = 'company_assignment'
    left join position_organizations as position_cost_center on position_cost_center.position_id = position.id
      -- and not position_cost_center._fivetran_deleted
      and lower(position_cost_center.type) = 'cost_center_assignment'
    left join `dbt-package-testing.workday_hcm.position_job_profile` position_job_profile  on position_job_profile.position_id = position.id
      -- and not position_job_profile._fivetran_deleted
    -- left join position_locations on position_locations.position_id = position.id
    -- where not position._fivetran_deleted
    order by position_code
)

select *
from position_data_enhanced 