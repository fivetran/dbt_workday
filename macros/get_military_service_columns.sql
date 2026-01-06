{% macro get_military_service_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "personal_info_common_id", "datatype": dbt.type_string()},
    {"name": "discharge_date", "datatype": "date"},
    {"name": "discharge_type", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "rank", "datatype": dbt.type_string()},
    {"name": "service", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "status_id", "datatype": dbt.type_string()},
    {"name": "status_begin_date", "datatype": "date"}
] %}

{{ return(columns) }}

{% endmacro %}
