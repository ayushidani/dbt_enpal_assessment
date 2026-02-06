-- Enriched deal stage entry events with stage names
-- One row = a deal entering a named funnel stage at a point in time

select
    e.deal_id,
    e.change_time,
    e.stage_id,
    s.stage_name
from {{ ref('init_deal_stage_events') }} e
join {{ ref('stg_stages') }} s
  on e.stage_id = s.stage_id