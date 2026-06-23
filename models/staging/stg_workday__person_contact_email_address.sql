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
        {{ fivetran_utils.apply_source_relation(package_name='workday') }}
    from base
),

final as (
    
    select 
        personal_info_system_id as worker_id,
        source_relation,
        _fivetran_synced,
        email_address,
        email_code,
        email_comment,
        id as person_contact_email_address_id
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final