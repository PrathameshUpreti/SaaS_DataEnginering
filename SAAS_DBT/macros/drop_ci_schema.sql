-- Macro to drop the ephemeral CI schema after PR tests complete
-- Co-authored with CoCo

{% macro drop_ci_schema(schema_name) %}
  {% set sql %}
    DROP SCHEMA IF EXISTS {{ target.database }}.{{ schema_name }} CASCADE;
  {% endset %}
  {{ run_query(sql) }}
  {{ log("Dropped schema: " ~ target.database ~ "." ~ schema_name, info=True) }}
{% endmacro %}
