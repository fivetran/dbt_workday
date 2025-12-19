{% macro get_personal_information_sexual_orientation_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "sexual_orientation_code", "datatype": dbt.type_string()},
    {"name": "sexual_orientation_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
