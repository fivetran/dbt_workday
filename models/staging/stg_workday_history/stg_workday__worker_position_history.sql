{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ ref('stg_workday__worker_position_base') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %}
),

final as (

    select 
        worker_id,
        position_id,
        source_relation,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', '_fivetran_start']) }} as stg_history_unique_key,
        business_site_summary_location as position_location,
        exclude_from_head_count as is_exclude_from_head_count,
        full_time_equivalent_percentage as fte_percent,
        job_exempt as is_job_exempt,
        specify_paid_fte as is_specify_paid_fte,
        specify_working_fte as is_specify_working_fte,
        work_shift_required as is_work_shift_required,
        academic_pay_setup_data_annual_work_period_end_date,
        academic_pay_setup_data_annual_work_period_start_date,
        academic_pay_setup_data_annual_work_period_work_percent_of_year,
        academic_pay_setup_data_disbursement_plan_period_end_date,
        academic_pay_setup_data_disbursement_plan_period_start_date,
        business_site_summary_display_language,
        business_site_summary_local,
        business_site_summary_location as position_location,
        business_site_summary_location_type,
        business_site_summary_name,
        business_site_summary_scheduled_weekly_hours,
        business_site_summary_time_profile,
        business_title,
        critical_job as is_critical_job,
        default_weekly_hours,
        difficulty_to_fill,
        cast(effective_date as {{ dbt.type_timestamp() }}) as position_effective_date,
        employee_type,
        cast(end_date as {{ dbt.type_timestamp() }}) as position_end_date,
        cast(end_employment_date as {{ dbt.type_timestamp() }}) as end_employment_date,
        exclude_from_head_count as is_exclude_from_head_count,
        expected_assignment_end_date,
        external_employee,
        federal_withholding_fein,
        frequency,
        full_time_equivalent_percentage as fte_percent,
        headcount_restriction_code,
        home_country,
        host_country,
        international_assignment_type,
        is_primary_job,
        job_exempt as is_job_exempt,
        job_profile_id,
        management_level_code,
        paid_fte,
        pay_group,
        pay_rate,
        pay_rate_type,
        pay_through_date,
        payroll_entity,
        payroll_file_number,
        regular_paid_equivalent_hours,
        scheduled_weekly_hours,
        specify_paid_fte as is_specify_paid_fte,
        specify_working_fte as is_specify_working_fte,
        cast(start_date as {{ dbt.type_timestamp() }}) as position_start_date,
        start_international_assignment_reason,
        work_hours_profile,
        work_shift,
        work_shift_required as is_work_shift_required,
        work_space,
        worker_hours_profile_classification,
        worker_id,
        working_fte,
        working_time_frequency,
        working_time_unit,
        working_time_value
    from base
)

select *
from final