-- Staging model for Pipedrive activities
-- One row represents a single activity

select
    activity_id,
    type as activity_type,
    assigned_to_user,
	deal_id,
    done,
    due_to as activity_date
from {{ source('pipedrive', 'activity') }}