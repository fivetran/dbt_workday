with base as (

    select * 
    from {{ ref('stg_workday__worker_position_organization_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_position_organization_base')),
                staging_columns=get_worker_position_organization_history_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='workday') }}
    from base
),

deduplicate as (

    select *,
        row_number() over (
            partition by worker_id, position_id, organization_id, source_relation
            order by as_of_effective_date desc
        ) as active_row_num
    from fields
    where {{ dbt.current_timestamp() }} between _fivetran_start and _fivetran_end
),

final as (

    select
        source_relation,
        position_id,
        worker_id,
        _fivetran_synced,
        index,
        date_of_pay_group_assignment,
        organization_id,
        primary_business_site,
        used_in_change_organization_assignments as is_used_in_change_organization_assignments
    from deduplicate
    where active_row_num = 1
)

select *
from final