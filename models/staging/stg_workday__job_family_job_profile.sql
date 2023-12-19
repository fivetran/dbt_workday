
with base as (

    select * 
    from {{ ref('stg_workday__job_family_job_profile_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__job_family_job_profile_base')),
                staging_columns=get_job_family_job_profile_columns()
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
Parsing Error
  Error reading workday: staging/src_workday.yml - Runtime Error
    Syntax error near line 4
    ------------------------------
    1  | sources:
    2  |   - name: workday
    3  |     database: '{% if target.type not in ("spark") %}{{ var("workday_database", target.database) }}{% endif %}'
    4  |     schema: '{{ var("workday_schema", "workday") }}' There are 1 unused configuration paths:
    5  | - models
    6  | Found 0 sources, 0 exposures, 0 metrics, 712 macros, 0 groups, 0 semantic models
    7  | version: 2
    
    Raw Error:
    ------------------------------
    while parsing a block mapping
      in "<unicode string>", line 2, column 5
    did not find expected key
      in "<unicode string>", line 4, column 54
    from fields
)

select *
from final
