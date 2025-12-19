{% macro get_person_disability_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "disability_degree", "datatype": dbt.type_string()},
    {"name": "disability_grade", "datatype": dbt.type_string()},
    {"name": "disability_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_person_disability_incoming_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "disability_degree", "datatype": dbt.type_string()},
    {"name": "disability_grade", "datatype": dbt.type_string()},
    {"name": "disability_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
