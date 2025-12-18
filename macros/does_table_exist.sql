{%- macro does_table_exist(table_name, source_name='workday') -%}
    {{ return(adapter.dispatch('does_table_exist', 'workday')(table_name, source_name)) }}
{% endmacro %}

{% macro default__does_table_exist(table_name, source_name='workday') %}
    {%- if execute -%}
    {%- set source_relation = adapter.get_relation(
        database=source(source_name, table_name).database,
        schema=source(source_name, table_name).schema,
        identifier=source(source_name, table_name).name) -%}

    {% set table_exists=source_relation is not none %}
    {{ return(table_exists) }}
    {%- endif -%}

{% endmacro %}
