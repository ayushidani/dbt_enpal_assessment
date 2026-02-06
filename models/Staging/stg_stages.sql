-- Staging model for Pipedrive stages
-- One row represents a stage definition in the sales funnel

select
    stage_id,
    stage_name
from {{ source('pipedrive', 'stages') }}