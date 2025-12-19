{% macro get_sexual_orientation_and_gender_identity_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "gender_identity", "datatype": dbt.type_string()},
    {"name": "sexual_orientation", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
