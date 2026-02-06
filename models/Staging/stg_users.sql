-- Staging model for Pipedrive users
-- One row represents a single user
select 
    id,
    name as user_name,
    email,
    modified as last_modified
from {{ source('pipedrive', 'users') }}