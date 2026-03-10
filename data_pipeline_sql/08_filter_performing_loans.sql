/*

We will remove months where the loan is already in serious delinquency

Banks usually do not predict default for loans already ≥90 DPD, because they are already in default stage.

## Filtering Dataset for PD Model Training

Before training the Probability of Default (PD) model, we restrict the dataset
to **loans that are currently performing (delinquency_status = 0)**.

The objective of the PD model is to answer the question:

> If a loan is **current today**, what is the probability that it will default
within the next 12 months?

Including loans that are already delinquent (30 or 60 days past due) would
introduce **information leakage**, because those loans are already showing
clear distress signals and are much closer to default.

Therefore, we filter the dataset to keep only **current loans**, which ensures
that the model learns early risk indicators such as borrower credit quality,
loan leverage, and loan characteristics rather than simply detecting loans
that are already in trouble.

This filtered dataset will be used as the **final modelling dataset** for
training the 12-month mortgage PD model.

So, basically we filter delinquency_status = 0

*/

-- CREATE FINAL MODELLING DATASET

CREATE TABLE freddie_mac.pd_model_dataset_final
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/pd_model_dataset_final/',
    parquet_compression = 'SNAPPY'
) AS
SELECT *
FROM freddie_mac.pd_model_dataset
WHERE delinquency_status = 0;

/* QUICK CHECK 

SELECT default_next_12m, COUNT(*)
FROM freddie_mac.pd_model_dataset_final
GROUP BY default_next_12m;

We see lesser rows now .. default next 12 months has 976522 observation rows, while no default within 12 month has 49420429 observation rows.
Total 50396951 rows x  18 columns which we load into Python notebook in next step.

So, the filter in SQL command filters out 90 DPD -> default cases, which is not useful prediction data for the PD model.
*/


-- YOU CAN DELETE THE PD_MODEL_DATASET TABLE SAVED IN S3 IN PREVIOUS SQL STEP.