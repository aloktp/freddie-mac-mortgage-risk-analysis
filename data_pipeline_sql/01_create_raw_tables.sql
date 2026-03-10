-- Run the below SQL commands one by one 

-- Create Database

CREATE DATABASE freddie_mac;

-- Create Origination Table

CREATE EXTERNAL TABLE freddie_origination (
credit_score INT,
first_payment_date STRING,
first_time_homebuyer_flag STRING,
maturity_date STRING,
msa INT,
mortgage_insurance_percentage INT,
number_of_units INT,
occupancy_status STRING,
original_cltv INT,
original_dti INT,
original_upb BIGINT,
original_ltv INT,
original_interest_rate DOUBLE,
channel STRING,
prepayment_penalty_flag STRING,
product_type STRING,
property_state STRING,
property_type STRING,
postal_code STRING,
loan_sequence_number STRING,
loan_purpose STRING,
original_loan_term INT,
number_of_borrowers INT,
seller_name STRING,
servicer_name STRING,
super_conforming_flag STRING,
pre_relief_refinance_seq STRING,
program_indicator STRING,
relief_refinance_flag STRING,
property_valuation_method STRING,
interest_only_flag STRING,
mi_cancellation_flag STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 's3://freddie-mac-mortgage-risk/raw-data/origination/year=2018/';

-- Create Performance Table

CREATE EXTERNAL TABLE freddie_performance (
loan_sequence_number STRING,
monthly_reporting_period STRING,
current_actual_upb BIGINT,
current_loan_delinquency_status STRING,
loan_age INT,
remaining_months_to_maturity INT,
defect_settlement_date STRING,
modification_flag STRING,
zero_balance_code STRING,
zero_balance_effective_date STRING,
current_interest_rate DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 's3://freddie-mac-mortgage-risk/raw-data/performance/year=2018/';

-- Test the Tables

SELECT COUNT(*) FROM freddie_origination;

-- Test the Tables

SELECT COUNT(*) FROM freddie_performance;


-- Create Clean Panel Table
-- It joins origination and performance tables. Keeps only 16 important columns or variables, and converts Data to Parquet.

CREATE TABLE freddie_mac.cleaned_panel
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/processed/cleaned_panel/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    o.loan_sequence_number,
    p.monthly_reporting_period,
    
    -- Origination features
    o.credit_score,
    o.original_ltv,
    o.original_dti,
    o.original_upb,
    o.original_interest_rate,
    o.original_loan_term,
    o.property_type,
    o.occupancy_status,
    o.loan_purpose,
    o.number_of_borrowers,
    o.property_state,

    -- Performance variables
    p.loan_age,
    p.current_actual_upb,
    p.current_loan_delinquency_status,
    p.remaining_months_to_maturity,
    p.zero_balance_code

FROM freddie_origination o
JOIN freddie_performance p
ON o.loan_sequence_number = p.loan_sequence_number;

-- Test the joined table

SELECT COUNT(*) FROM freddie_mac.cleaned_panel;
