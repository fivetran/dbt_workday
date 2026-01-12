{% macro get_personal_information_ethnicity_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "country_personal_information_id", "datatype": dbt.type_string()},
    {"name": "ethnicity_code", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
