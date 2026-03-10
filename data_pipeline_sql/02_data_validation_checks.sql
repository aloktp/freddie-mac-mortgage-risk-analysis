-- CHECK 1: ROW COUNT CHECK

SELECT COUNT(*) AS origination_rows
FROM freddie_origination;
-- 1285434 loans = 1.2M loans

SELECT COUNT(*) AS performance_rows
FROM freddie_performance;
-- 51103837 loan performance history rows = 51M rows of time data

SELECT COUNT(*) AS cleaned_rows
FROM freddie_mac.cleaned_panel;
-- 51103837 loan performance history rows = 51M rows of time data


-- CHECK 2: UNIQUE LOAN COUNT

SELECT COUNT(DISTINCT loan_sequence_number) AS unique_loans
FROM freddie_origination;
-- 1285434 loans = 1.2M loans

-- CHECK 3: JOIN INTEGRITY

SELECT COUNT(*) AS unmatched_loans
FROM freddie_performance p
LEFT JOIN freddie_origination o
ON p.loan_sequence_number = o.loan_sequence_number
WHERE o.loan_sequence_number IS NULL;
-- 0 unmatched loans

-- CHECK 4: LOAN DELINQUENCY DISTRIBUTION

SELECT
current_loan_delinquency_status,
COUNT(*) AS records
FROM freddie_performance
GROUP BY current_loan_delinquency_status
ORDER BY current_loan_delinquency_status;

-- Majority of the loans are of delinquency status 0 (i.e. no delinquency)


-- CHECK 5: CHECK UPB (UNPAID PREPAID BALANCE) RANGE

SELECT
MIN(current_actual_upb) AS min_upb,
MAX(current_actual_upb) AS max_upb
FROM freddie_performance;

-- Minimum is 0 i.e.(all dues paid), and Maximum is 1307000 i.e. 1.3M USD

-- CHECK 6: LOAN AGE RANGE

SELECT
MIN(loan_age) AS min_age,
MAX(loan_age) AS max_age
FROM freddie_performance;

-- This is current status as of 9th March 2026.
-- Minimum age is 0, and maximum age is 92 months, because 7.7 years have passed since 2018. YMMV.
-- This also happens because Freddie Mac sometimes purchases seasoned loans. So, the loan  may have existed before 2018 but entered Freddie's dataset later.


-- CHECK 7: ZERO BALANCE EVENTS

SELECT
zero_balance_code,
COUNT(*) AS records
FROM freddie_performance
GROUP BY zero_balance_code
ORDER BY zero_balance_code;

-- This is current status as of 9th March 2026. YMMV.
-- Majority of the loans not closed. Still active. 
-- 1020821 i.e. 1M loans are pre-paid closed  i.e. refinance by other banks etc or early payoff
-- 156 loans defaulted.
-- 624 loans have gone through foreclosure sale.

-- Code	  Meaning
-- NULL	  still active loan
-- 01	  voluntary payoff (refinance or early payoff)
-- 02	  third-party sale
-- 03	  short sale / charge-off
-- 09	  REO disposition (foreclosure sale)
-- 15	  whole loan sale
-- 16	  reperforming loan securitization
-- 96	  defect settlement


-- CHECK 8: MONTHLY RECORD PROGRESSION

SELECT
loan_sequence_number,
COUNT(*) AS months_tracked
FROM freddie_performance
GROUP BY loan_sequence_number
ORDER BY months_tracked DESC
LIMIT 10;

-- This is current status as of 9th March 2026.
-- Tracked for 93 months, because 7.7 years have passed since 2018. YMMV.