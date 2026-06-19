{% snapshot accounts_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='account_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=true,
        tags=['Daily']
    )
}}

SELECT
    account_id,
    account_name,
    account_type,
    credit_limit,
    relationship_manager,
    updated_at
FROM {{ source('raw', 'accounts') }}

{% endsnapshot %}