{{
    fivetran_utils.union_data(
        table_identifier='worker_position_organization', 
        database_variable='workday_database', 
        schema_variable='workday_schema', 
        default_database=target.database,
        default_schema='workday',
        default_variable='worker_position_organization',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}
