
with base as (

    select * 
    from {{ ref('stg_workday__person_contact_email_address_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__person_contact_email_address_base')),
                staging_columns=get_person_contact_email_address_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
Compilation Error
  Documentation for 'source.workday.workday.job_profile' depends on doc 'job_profile'  which was not found
    from fields
)

select *
from final
