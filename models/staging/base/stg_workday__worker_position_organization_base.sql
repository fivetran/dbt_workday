{% if var('workday_union_schemas', []) | length > 0 or var('workday_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='worker_position_organization_history',
        database_variable='workday_database',
        schema_variable='workday_schema',
        default_database=target.database,
        default_schema='workday',
        default_variable='worker_position_organization_history',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='workday_sources',
        single_source_name='workday',
        single_table_name='worker_position_organization_history'
    )
}}

{% endif %}
