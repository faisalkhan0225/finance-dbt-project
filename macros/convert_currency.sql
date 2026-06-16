-- macros/convert_currency.sql

{% macro convert_currency(amount_col, from_currency, rate) %}
    CASE
        WHEN {{ from_currency }} = 'USD'
        THEN {{ amount_col }} * {{ rate }}
        ELSE {{ amount_col }}
    END
{% endmacro %}