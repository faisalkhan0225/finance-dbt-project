-- snapshots/accounts_snapshot.sql

{% snapshot accounts_snapshot %}

{{
    config(
        target_schema = 'snapshots',
        unique_key    = 'account_id',
        strategy      = 'timestamp',
        updated_at    = 'updated_at'
    )
}}

SELECT
    account_id,
    account_name,
    account_type,
    credit_limit,
    relationship_manager
FROM {{ source('raw', 'accounts') }}

{% endsnapshot %}