/*
Migration / Roll-Rate Matrix.

This shows transitions like:
- Current → 30 DPD
- 30 DPD → 60 DPD
- 60 DPD → 90 DPD
- 90 DPD → Default
*/

-- 1st STEP: Build Loan Month-to-Month Transitions table that tracks each loan’s status this month vs next month.

CREATE TABLE freddie_mac.loan_status_transitions
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/loan_status_transitions/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    loan_sequence_number,
    monthly_reporting_period,

    TRY_CAST(current_loan_delinquency_status AS INTEGER) AS current_status,

    LEAD(
        TRY_CAST(current_loan_delinquency_status AS INTEGER)
    ) OVER (
        PARTITION BY loan_sequence_number
        ORDER BY monthly_reporting_period
    ) AS next_status

FROM freddie_mac.cleaned_panel;

-- 2nd STEP: Create Migration Matrix

CREATE TABLE freddie_mac.migration_matrix
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/migration_matrix/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    current_status,
    next_status,
    COUNT(*) AS transition_count
FROM freddie_mac.loan_status_transitions
GROUP BY current_status, next_status
ORDER BY current_status, next_status;


-- 3rd STEP (OPTIONAL) QUICK CHECK :-

SELECT *
FROM freddie_mac.migration_matrix
ORDER BY current_status, next_status;

/*
If you see current status some value say 0 (i.e. non-delinquent), but NEXT STATUS is NULL, then it means Loan was current in the last available month, but there is no next month record.

This happens because of one of these reasons :-

loan ended (prepaid / closed)

loan left the dataset (someone else bought it or refinance)

or it is simply the latest reporting month

*/

