-- Intermediate model capturing deal stage entry events
-- One row represents a deal entering a specific stage at a specific time

select
    deal_id,
    change_time,
    new_value::int as stage_id
from {{ ref('stg_deal_changes') }}
where changed_field_key = 'stage_id'

