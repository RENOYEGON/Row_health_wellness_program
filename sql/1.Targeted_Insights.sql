-- What wellness products are most commonly claimed in different years?
SELECT 
    product_name, 
    YEAR(claim_date) AS claim_year,
    MONTH(claim_date) AS claim_month,  
    COUNT(*) AS total_claims
FROM claims
GROUP BY 
    product_name, 
    claim_month, 
    YEAR(claim_date)
ORDER BY 
    claim_year, 
    claim_month, 
    total_claims DESC;

-- Number of signups and plans in years
SELECT 
    YEAR(signup_date) AS signup_year,
    plan,
    COUNT(*) AS total_signups
FROM customers
GROUP BY 
    signup_year, 
    plan
ORDER BY 
    signup_year, 
    plan;

-- Which campaign type or category are driving the most reimbursement claims?
SELECT 
    c.campaign_type,
    cu.campaign_id,
    COUNT(cl.claim_id) AS total_claims
FROM claims cl
JOIN customers cu 
    ON cl.customer_id = cu.customer_id
LEFT JOIN campaigns c 
    ON cu.campaign_id = c.campaign_id
GROUP BY 
    c.campaign_type, 
    cu.campaign_id
ORDER BY 
    total_claims DESC;

-- Which states have the highest reimbursement usage?
SELECT 
    cu.state,
    COUNT(cl.claim_id) AS total_claims
FROM claims cl
JOIN customers cu 
    ON cl.customer_id = cu.customer_id
GROUP BY 
    cu.state
ORDER BY 
    total_claims DESC;

-- The product most often bought as a second product for customers with more than one order
WITH ranked_claims AS (
    SELECT 
        cl.customer_id,
        cl.product_name,
        cl.claim_date,
        ROW_NUMBER() OVER (
            PARTITION BY cl.customer_id 
            ORDER BY cl.claim_date
        ) AS claim_rank
    FROM claims cl
)
SELECT 
    product_name, 
    COUNT(*) AS second_product_count
FROM ranked_claims
WHERE claim_rank = 2
GROUP BY 
    product_name
ORDER BY 
    second_product_count DESC
LIMIT 1;

-- Overall average number of days between claims for customers with more than one claim
WITH claim_diffs AS (
    SELECT 
        customer_id,
        claim_date,
        LAG(claim_date) OVER (
            PARTITION BY customer_id 
            ORDER BY claim_date
        ) AS prev_claim_date
    FROM claims
)
SELECT 
    ROUND(AVG(DATEDIFF(claim_date, prev_claim_date)), 1) AS avg_days_between_claims
FROM claim_diffs
WHERE prev_claim_date IS NOT NULL;

-- Product with the highest number of claims
SELECT 
    product_name, 
    COUNT(*) AS total_claims
FROM claims
GROUP BY 
    product_name
ORDER BY 
    total_claims DESC
LIMIT 5;

-- Customers with the most claims across all time (and total claims)
SELECT 
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    cu.customer_id,
    COUNT(cl.claim_id) AS total_claims
FROM claims cl
JOIN customers cu 
    ON cl.customer_id = cu.customer_id
GROUP BY 
    customer_name, 
    cu.customer_id
ORDER BY 
    total_claims DESC
LIMIT 5;
