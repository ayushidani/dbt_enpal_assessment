-- Staging model for Pipedrive activity types
-- One row represents a single activity type

select id,
    name as activity_name,
    active,
    type as activity_type
from {{ source('pipedrive', 'activity_types') }}