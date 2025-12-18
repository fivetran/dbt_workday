{% macro get_personal_information_common_data_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "additional_nationality", "datatype": dbt.type_string()},
    {"name": "blood_type", "datatype": dbt.type_string()},
    {"name": "citizenship_status", "datatype": dbt.type_string()},
    {"name": "city_of_birth", "datatype": dbt.type_string()},
    {"name": "city_of_birth_code", "datatype": dbt.type_string()},
    {"name": "country_of_birth", "datatype": dbt.type_string()},
    {"name": "country_region_of_birth", "datatype": dbt.type_string()},
    {"name": "date_of_birth", "datatype": "date"},
    {"name": "date_of_death", "datatype": "date"},
    {"name": "last_medical_exam_date", "datatype": "date"},
    {"name": "last_medical_exam_valid_to", "datatype": "date"},
    {"name": "medical_exam_notes", "datatype": dbt.type_string()},
    {"name": "primary_nationality", "datatype": dbt.type_string()},
    {"name": "region_of_birth", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
