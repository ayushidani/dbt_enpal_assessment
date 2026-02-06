-- Monthly sales funnel report
-- Counts how many deals entered each funnel step per month
-- Sales Call 1 restricted to Qualified Lead stage
-- Sales Call 2 restricted to Needs Assessment stage

with stage_entries as (

    select
        date_trunc('month', change_time)::date as month,
        stage_name as funnel_step,
        deal_id
    from {{ ref('init_deal_stage_enriched') }}

),

stage_funnel as (

    select
        month,
        'Sales Funnel' as kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from stage_entries
    group by 1, 2, 3

),

call_entries as (
    -- Sales Call 1: Only count if deal is in "Qualified Lead" stage
    -- Sales Call 2: Only count if deal is in "Needs Assessment" stage
    select
        date_trunc('month', a.activity_date)::date as month,
        case
            when a.activity_type = 'meeting' then 'Sales Call 1'
            when a.activity_type = 'sc_2' then 'Sales Call 2'
        end as funnel_step,
        a.deal_id
    from {{ ref('stg_activity') }} a
    inner join (
        -- Get the most recent stage entry before or at activity time
        select distinct on (deal_id, activity_date)
            s.deal_id,
            s.stage_name,
            s.change_time,
            a.activity_date
        from {{ ref('stg_activity') }} a
        join {{ ref('init_deal_stage_enriched') }} s
            on a.deal_id = s.deal_id
            and s.change_time <= a.activity_date
        where a.activity_type in ('meeting', 'sc_2')
        order by deal_id, activity_date, change_time desc
    ) stage_check
        on a.deal_id = stage_check.deal_id
        and a.activity_date = stage_check.activity_date
    where a.activity_type in ('meeting', 'sc_2')
        and (
            -- Sales Call 1 only for Qualified Lead
            (a.activity_type = 'meeting' and stage_check.stage_name = 'Qualified Lead')
            or
            -- Sales Call 2 only for Needs Assessment
            (a.activity_type = 'sc_2' and stage_check.stage_name = 'Needs Assessment')
        )

),

call_funnel as (

    select
        month,
        'Sales Funnel' as kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from call_entries
    where funnel_step is not null
    group by 1, 2, 3

)

select * from (
    select * from stage_funnel
    union all
    select * from call_funnel
) as combined