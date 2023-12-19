{% macro get_worker_leave_status_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "adoption_notification_date", "datatype": "date"},
    {"name": "adoption_placement_date", "datatype": "date"},
    {"name": "age_of_dependent", "datatype": dbt.type_float()},
    {"name": "benefits_effect", "datatype": dbt.type_boolean()},
    {"name": "caesarean_section_birth", "datatype": dbt.type_boolean()},
    {"name": "child_birth_date", "datatype": "date"},
    {"name": "child_sdate_of_death", "datatype": "date"},
    {"name": "continuous_service_accrual_effect", "datatype": dbt.type_boolean()},
    {"name": "date_baby_arrived_home_from_hospital", "datatype": "date"},
    {"name": "date_child_entered_country", "datatype": "date"},
    {"name": "date_of_recall", "datatype": "date"},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "estimated_leave_end_date", "datatype": "date"},
    {"name": "expected_due_date", "datatype": "date"},
    {"name": "first_day_of_work", "datatype": "date"},
    {"name": "last_date_for_which_paid", "datatype": "date"},
    {"name": "leave_end_date", "datatype": "date"},
    {"name": "leave_entitlement_override", "datatype": dbt.type_float()},
    {"name": "leave_last_day_of_work", "datatype": "date"},
    {"name": "leave_of_absence_type", "datatype": dbt.type_string()},
    {"name": "leave_percentage", "datatype": dbt.type_float()},
    {"name": "leave_request_event_id", "datatype": dbt.type_string()},
    {"name": "leave_return_event", "datatype": dbt.type_string()},
    {"name": "leave_start_date", "datatype": "date"},
    {"name": "leave_status_code", "datatype": dbt.type_string()},
    {"name": "leave_type_reason", "datatype": dbt.type_string()},
    {"name": "location_during_leave", "datatype": dbt.type_string()},
    {"name": "multiple_child_indicator", "datatype": dbt.type_boolean()},
    {"name": "number_of_babies_adopted_children", "datatype": dbt.type_float()},
    {"name": "number_of_child_dependents", "datatype": dbt.type_float()},
    {"name": "number_of_previous_births", "datatype": dbt.type_float()},
    {"name": "number_of_previous_maternity_leaves", "datatype": dbt.type_float()},
    {"name": "on_leave", "datatype": dbt.type_boolean()},
    {"name": "paid_time_off_accrual_effect", "datatype": dbt.type_boolean()},
    {"name": "payroll_effect", "datatype": dbt.type_boolean()},
    {"name": "single_parent_indicator", "datatype": dbt.type_boolean()},
    {"name": "social_security_disability_code", "datatype": dbt.type_string()},
    {"name": "stillbirth_baby_deceased", "datatype": dbt.type_boolean()},
    {"name": "stock_vesting_effect", "datatype": dbt.type_boolean()},
    {"name": "stop_payment_date", "datatype": "date"},
    {"name": "week_of_confinement", "datatype": "date"},
    {"name": "work_related", "datatype": dbt.type_boolean()},
    {"name": "worker_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
