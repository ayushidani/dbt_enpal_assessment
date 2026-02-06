-- Staging model for Pipedrive deal change events
-- One row represents a single change event for a deal

select
    deal_id,
    change_time	,
    changed_field_key,
	new_value
from {{ source('pipedrive', 'deal_changes') }}