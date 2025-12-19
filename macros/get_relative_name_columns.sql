{% macro get_relative_name_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "middle_name", "datatype": dbt.type_string()},
    {"name": "relationship_type", "datatype": dbt.type_string()},
    {"name": "relationship_type_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_relative_name_incoming_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "middle_name", "datatype": dbt.type_string()},
    {"name": "relationship_type", "datatype": dbt.type_string()},
    {"name": "relationship_type_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
