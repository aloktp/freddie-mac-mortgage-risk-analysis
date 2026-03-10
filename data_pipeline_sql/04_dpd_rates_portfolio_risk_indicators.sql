SELECT
monthly_reporting_period,

dpd_30_plus * 1.0 / total_loans AS dpd30_rate,
dpd_60_plus * 1.0 / total_loans AS dpd60_rate,
dpd_90_plus * 1.0 / total_loans AS dpd90_rate

FROM freddie_mac.delinquency_trends
ORDER BY monthly_reporting_period;

-- This is time series of portfolio credit risk, which Banks monitor

-- dpd30 rising → early credit stress
-- dpd60 rising → deterioration
-- dpd90 rising → default wave