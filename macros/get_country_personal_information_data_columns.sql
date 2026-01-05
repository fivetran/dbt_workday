{% macro get_country_personal_information_data_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "gender", "datatype": dbt.type_string()},
    {"name": "hispanic_or_latino", "datatype": dbt.type_boolean()},
    {"name": "hukou_locality", "datatype": dbt.type_string()},
    {"name": "hukou_postal_code", "datatype": dbt.type_string()},
    {"name": "hukou_region_code", "datatype": dbt.type_string()},
    {"name": "hukou_subregion_code", "datatype": dbt.type_string()},
    {"name": "hukou_type_code", "datatype": dbt.type_string()},
    {"name": "local_hukou", "datatype": dbt.type_boolean()},
    {"name": "marital_status", "datatype": dbt.type_string()},
    {"name": "marital_status_date", "datatype": "date"},
    {"name": "native_region_code", "datatype": dbt.type_string()},
    {"name": "native_region", "datatype": dbt.type_string()},
    {"name": "personnel_file_agency_for_person", "datatype": dbt.type_string()},
    {"name": "political_affiliation", "datatype": dbt.type_string()},
    {"name": "religion", "datatype": dbt.type_string()},
    {"name": "social_benefits_locality", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
