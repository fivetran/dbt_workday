{{ config(enabled=var('employee_history_enabled', False)) }}

{% if execute %}
    {% set date_query %}
    select 
        {{ dbt.date_trunc('day', dbt.current_timestamp()) }} as max_date
    {% endset %}

    {% set last_date = run_query(date_query).columns[0][0]|string %}

    {# If only compiling, creates range going back 1 year #}
    {% else %} 
        {% set last_date = dbt.dateadd("year", "-1", "current_date") %}
{% endif %}


with spine as (
    {# Prioritizes variables over calculated dates #}
    {% set first_date = var('employee_history_start_date', '2020-01-01')|string %}
    {% set last_date = last_date|string %}

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
        end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
        )
    }}
),

worker_position_org_history as (

    select *        
    from {{ ref('stg_workday__worker_position_organization_history') }}
),


order_daily_values as (

    select 
        *,
        row_number() over (
            partition by _fivetran_date, history_unique_key
            order by _fivetran_start desc) as row_num    
    from worker_position_org_history  
),

get_latest_daily_value as (

    select * 
    from order_daily_values
    where row_num = 1
),

daily_history as (

    select 
        {{ dbt_utils.generate_surrogate_key(['spine.date_day',
                                            'get_latest_daily_value.history_unique_key']) }} 
                                            as wpo_day_id,
        cast(spine.date_day as date) as date_day,
        get_latest_daily_value.*
    from get_latest_daily_value
    join spine on get_latest_daily_value._fivetran_start <= cast(spine.date_day as {{ dbt.type_timestamp() }})
        and get_latest_daily_value._fivetran_end >= cast(spine.date_day as {{ dbt.type_timestamp() }})
)

select * 
from daily_history