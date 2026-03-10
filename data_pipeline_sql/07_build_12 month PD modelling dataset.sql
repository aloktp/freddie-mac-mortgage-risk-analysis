/*

In credit risk modelling, the Probability of Default (PD) model is designed
to estimate the likelihood that a performing loan will default within a
specified future time horizon.

For this project, we construct a **12-month forward-looking default indicator**.

For each loan-month observation, we check whether the loan defaults at any
point within the next 12 months.

The default definition used is:

    Default = 
        • Loan becomes 90+ days delinquent (current_loan_delinquency_status ≥ 3)
        OR
        • Loan is terminated due to liquidation events
          (zero_balance_code IN ('03','09'))

Using a window function, we look forward 12 months within each loan’s
reporting history and flag whether a default event occurs in that horizon.

This produces the target variable:

    default_next_12m

which equals:
    1 → loan defaults within the next 12 months
    0 → loan does not default within the next 12 months

The resulting dataset is a **loan-month panel dataset** used to construct
the final modelling dataset in later steps.

*/

-- BUILD PD MODELLING DATASET

CREATE TABLE freddie_mac.pd_model_dataset
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/pd_model_dataset/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    loan_sequence_number,
    monthly_reporting_period,

    -- Origination features
    credit_score,
    original_ltv,
    original_dti,
    original_upb,
    original_interest_rate,
    original_loan_term,
    property_type,
    occupancy_status,
    loan_purpose,
    number_of_borrowers,
    property_state,

    -- Performance variables
    loan_age,
    current_actual_upb,
    TRY_CAST(current_loan_delinquency_status AS INTEGER) AS delinquency_status,
    remaining_months_to_maturity,

    -- Target variable: default in next 12 months
    MAX(default_flag) OVER (
        PARTITION BY loan_sequence_number
        ORDER BY monthly_reporting_period
        ROWS BETWEEN CURRENT ROW AND 12 FOLLOWING
    ) AS default_next_12m

FROM freddie_mac.cleaned_panel cp
JOIN freddie_mac.default_flags df
USING (loan_sequence_number, monthly_reporting_period);

-- QUICK VALIDATION CHECK
/*

SELECT default_next_12m, COUNT(*)
FROM freddie_mac.pd_model_dataset
GROUP BY default_next_12m;

As of 9th March 2026, 49,422,458 loan-month history observations or rows (i.e. 66.7%) didn't default within next 12 months after origination, while 1,681,379 loan-month history observations or rows (i.e. 3.3%) defaulted within next 12 months.= of origination.

*/