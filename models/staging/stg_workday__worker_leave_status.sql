
with base as (

    select * 
    from {{ ref('stg_workday__worker_leave_status_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_leave_status_base')),
                staging_columns=get_worker_leave_status_columns()
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
        adoption_notification_date,
        adoption_placement_date,
        age_of_dependent,
        benefits_effect,
        caesarean_section_birth,
        child_birth_date,
        child_sdate_of_death,
        continuous_service_accrual_effect,
        date_baby_arrived_home_from_hospital,
        date_child_entered_country,
        date_of_recall,
        description,
        estimated_leave_end_date,
        expected_due_date,
        first_day_of_work,
        last_date_for_which_paid,
        leave_end_date,
        leave_entitlement_override,
        leave_last_day_of_work,
        leave_of_absence_type,
        leave_percentage,
        leave_request_event_id,
        leave_return_event,
        leave_start_date,
        leave_status_code,
        leave_type_reason,
        location_during_leave,
        multiple_child_indicator,
        number_of_babies_adopted_children,
        number_of_child_dependents,
        number_of_previous_births,
        number_of_previous_maternity_leaves,
        on_leave,
        paid_time_off_accrual_effect,
        payroll_effect,
        single_parent_indicator,
        social_security_disability_code,
        stillbirth_baby_deceased,
        stock_vesting_effect,
        stop_payment_date,
        week_of_confinement,
        work_related,
        worker_id
    from fields
)

select *
from final
