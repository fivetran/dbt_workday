{{
    fivetran_utils.union_data(
        table_identifier='person_contact_email_address', 
        database_variable='workday_database', 
        schema_variable='workday_schema', 
        default_database=target.database,
        default_schema='workday',
        default_variable='person_contact_email_address',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}
