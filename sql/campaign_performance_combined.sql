WITH campaign_signups AS (
  SELECT 
    c.campaign_id,
    COUNT(DISTINCT cu.customer_id) AS num_signups
  FROM campaigns c
  LEFT JOIN customers cu ON c.campaign_id = cu.campaign_id
  GROUP BY c.campaign_id
)
SELECT 
    c.campaign_id,
    c.campaign_category,
    c.campaign_type,
    c.platform,
    CONCAT(c.campaign_category, ' - ', c.platform) AS campaign_detail,
    c.days_run,
    c.cost,
    c.impressions,
    c.clicks,
    cs.num_signups,
    ROUND(cs.num_signups * 100.0 / NULLIF(c.impressions, 0), 2) AS Impres_signup_rate,
    ROUND(cs.num_signups * 100.0 / NULLIF(c.clicks, 0), 2) AS clicks_signup_rate,
    ROUND(c.cost / NULLIF(cs.num_signups, 0), 2) AS cost_per_signup,
    ROUND(c.clicks * 100.0 / NULLIF(c.impressions, 0), 2) AS click_through_rate,
    ROUND(c.cost / NULLIF(c.clicks, 0), 2) AS cost_per_click
FROM campaigns c
LEFT JOIN campaign_signups cs ON c.campaign_id = cs.campaign_id;



