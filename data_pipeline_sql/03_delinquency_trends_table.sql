CREATE TABLE freddie_mac.delinquency_trends
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/delinquency_trends/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    monthly_reporting_period,

    COUNT(*) AS total_loans,

    SUM(
        CASE 
            WHEN TRY_CAST(current_loan_delinquency_status AS INTEGER) >= 1 
            THEN 1 ELSE 0 
        END
    ) AS dpd_30_plus,

    SUM(
        CASE 
            WHEN TRY_CAST(current_loan_delinquency_status AS INTEGER) >= 2 
            THEN 1 ELSE 0 
        END
    ) AS dpd_60_plus,

    SUM(
        CASE 
            WHEN TRY_CAST(current_loan_delinquency_status AS INTEGER) >= 3 
            THEN 1 ELSE 0 
        END
    ) AS dpd_90_plus

FROM freddie_mac.cleaned_panel
GROUP BY monthly_reporting_period
ORDER BY monthly_reporting_period;




-- VIEW THE RESULTS:-

-- SELECT *
-- FROM freddie_mac.delinquency_trends
-- ORDER BY monthly_reporting_period
-- LIMIT 20;