{{ config(enabled=var('workday__using_personal_info_v2_schema', false)) }}

{{
    fivetran_utils.union_data(
        table_identifier='country_personal_information',
        database_variable='workday_database',
        schema_variable='workday_schema',
        default_database=target.database,
        default_schema='workday',
        default_variable='country_personal_information',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}
