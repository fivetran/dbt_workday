{{
    fivetran_utils.union_data(
        table_identifier='person_disability_incoming' if var('workday__using_person_disability_incoming', workday.does_table_exist('person_disability_incoming')) else 'person_disability',
        database_variable='workday_database',
        schema_variable='workday_schema',
        default_database=target.database,
        default_schema='workday',
        default_variable='person_disability',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}
