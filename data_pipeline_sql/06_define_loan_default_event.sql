/* We create a column to flag default events.

Basically, the definition of default is :-
Default = 90+ DPD OR zero_balance_code IN ('03','09')

*/

-- CREATE DEFAULT EVENT COLUMN

CREATE TABLE freddie_mac.default_flags
WITH (
    format = 'PARQUET',
    external_location = 's3://freddie-mac-mortgage-risk/analytics/default_flags/',
    parquet_compression = 'SNAPPY'
) AS
SELECT
    loan_sequence_number,
    monthly_reporting_period,

    TRY_CAST(current_loan_delinquency_status AS INTEGER) AS delinquency_status,

    zero_balance_code,

    CASE
        WHEN TRY_CAST(current_loan_delinquency_status AS INTEGER) >= 3 THEN 1
        WHEN zero_balance_code IN ('03','09') THEN 1
        ELSE 0
    END AS default_flag

FROM freddie_mac.cleaned_panel;


/* QUICK CHECK :-

SELECT default_flag, COUNT(*)
FROM freddie_mac.default_flags
GROUP BY default_flag;

As on 9th March 2026, there are 700027 loans originated in 2018 that are at default, while 50403810 are not at default.
NPL (Non-performing loan) portfolio ratio of loans originated in 2018 = 700027 / 51103837 * 100 = 1.36%
*/