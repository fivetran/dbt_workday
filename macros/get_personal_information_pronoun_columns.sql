{% macro get_personal_information_pronoun_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "pronoun_code", "datatype": dbt.type_string()},
    {"name": "pronoun_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
