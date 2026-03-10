/*

STEP 9 — BUILD LOAN-LEVEL SNAPSHOT DATASET FOR PD MODELLING

The previous datasets are structured as a loan-month panel, meaning each loan
appears multiple times (once per reporting month). However, the borrower and
origination features used for modelling do not change every month.

Training a model directly on the panel dataset would therefore create many
duplicate observations with identical features but different outcomes, which
can distort model training and reduce predictive performance.

To address this, we collapse the panel dataset into a loan-level snapshot
dataset with one observation per loan.

For each loan we retain the borrower and loan characteristics from the
origination data and assign the target variable:

    default_next_12m

This variable indicates whether the loan defaults within the next 12 months
at any point during its observed history.

The resulting dataset contains one row per loan and is used as the modelling
dataset in the Python notebook to train the Probability of Default (PD) model.

*/



CREATE TABLE freddie_mac.loan_snapshot_pd
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/loan_snapshot_pd/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    loan_sequence_number,

    credit_score,
    original_ltv,
    original_dti,
    original_interest_rate,
    original_upb,
    number_of_borrowers,
    property_state,

    MAX(default_next_12m) AS default_next_12m

FROM freddie_mac.pd_model_dataset_final

GROUP BY
    loan_sequence_number,
    credit_score,
    original_ltv,
    original_dti,
    original_interest_rate,
    original_upb,
    number_of_borrowers,
    property_state;