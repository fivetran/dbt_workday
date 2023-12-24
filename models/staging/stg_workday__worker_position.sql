
with base as (

    select * 
    from {{ ref('stg_workday__worker_position_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_position_base')),
                staging_columns=get_worker_position_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_deleted,
        _fivetran_synced,
        academic_pay_setup_data_annual_work_period_end_date,
        academic_pay_setup_data_annual_work_period_start_date,
        academic_pay_setup_data_annual_work_period_work_percent_of_year,
        academic_pay_setup_data_disbursement_plan_period_end_date,
        academic_pay_setup_data_disbursement_plan_period_start_date,
        business_site_summary_display_language,
        business_site_summary_local,
        business_site_summary_location,
        business_site_summary_location_type,
        business_site_summary_name,
        business_site_summary_scheduled_weekly_hours,
        business_site_summary_time_profile,
        business_title,
        critical_job,
        default_weekly_hours,
        difficulty_to_fill,
        effective_date,
        employee_type,
        end_date,
        end_employment_date,
        exclude_from_head_count,
        expected_assignment_end_date,
        external_employee,
        federal_withholding_fein,
        frequency,
        full_time_equivalent_percentage,
        headcount_restriction_code,
        home_country,
        host_country,
        international_assignment_type,
        is_primary_job,
        job_exempt,
        job_profile_id,
        management_level_code,
        paid_fte,
        pay_group,
        pay_rate,
        pay_rate_type,
        pay_through_date,
        payroll_entity,
        payroll_file_number,
        position_id,
        regular_paid_equivalent_hours,
        scheduled_weekly_hours,
        specify_paid_fte,
        specify_working_fte,
        start_date,
        start_international_assignment_reason,
        work_hours_profile,
        work_shift,
        work_shift_required,
        work_space,
        worker_hours_profile_classification,
        worker_id,
        working_fte,
        working_time_frequency,
        working_time_unit,
        working_time_value
    from fields
)

select *
from final
