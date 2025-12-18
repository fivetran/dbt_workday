{{
    fivetran_utils.union_data(
        table_identifier='relative_name_incoming' if var('workday__using_relative_name_incoming', workday.does_table_exist('relative_name_incoming')) else 'relative_name',
        database_variable='workday_database',
        schema_variable='workday_schema',
        default_database=target.database,
        default_schema='workday',
        default_variable='relative_name',
        union_schema_variable='workday_union_schemas',
        union_database_variable='workday_union_databases'
    )
}}
