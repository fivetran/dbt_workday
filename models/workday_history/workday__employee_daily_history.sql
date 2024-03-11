{{
    config(
        enabled = var('employee_history_enabled', False),
        materialized = 'incremental',
        partition_by = {
            'field': 'date_day', 
            'data_type': 'date'
        } if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key = 'employee_day_id',
        incremental_strategy = 'insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        file_format = 'parquet',
        on_schema_change = 'fail'
    )
}}

{% if execute %}
    {% set date_query %}
    select 
        {{ dbt.date_trunc('day', dbt.current_timestamp_backcompat()) }} as max_date
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

employee_history as (

    select *        
    from {{ ref('int_workday__employee_history') }}
    {% if is_incremental() %}
        where _fivetran_start >= (select max(cast((_fivetran_start) as {{ dbt.type_timestamp() }})) from {{ this }} )
    {% else %}
        {% if var('employee_history_start_date',[]) %}
        where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
        {% endif %}
    {% endif %} 
),

order_daily_values as (

    select 
        *,
        row_number() over (
            partition by _fivetran_date, employee_id
            order by _fivetran_start desc) as row_num    
    from employee_history
),

get_latest_daily_value as (

    select * 
    from order_daily_values
    where row_num = 1
),

daily_history as (

    select 
        {{ dbt_utils.generate_surrogate_key(['spine.date_day','get_latest_daily_value.employee_id']) }} as employee_day_id,
        cast(spine.date_day as date) as date_day,
        get_latest_daily_value.*
    from get_latest_daily_value
    join spine on get_latest_daily_value._fivetran_start <= cast(spine.date_day as {{ dbt.type_timestamp() }})
        and get_latest_daily_value._fivetran_end >= cast(spine.date_day as {{ dbt.type_timestamp() }})
)

select * 
from daily_history