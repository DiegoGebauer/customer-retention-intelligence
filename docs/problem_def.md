# Problem Definition

## Business Question

At a given snapshot date, which existing customers are most likely
to repurchase within the next 90 days?

The business objective is to identify customers with a high risk of
inactivity so that retention actions can be prioritized.

## Eligible Customers

A customer is considered eligible if they placed at least one
qualifying order on or before the snapshot date.

For this provisional analysis, qualifying orders have one of the
following statuses:

- Complete
- Shipped
- Processing

Cancelled and Returned orders are excluded.

## Target

`repurchase_90d = 1` if the customer places at least one qualifying
order in the interval:

`(snapshot_date, snapshot_date + 90 days]`

Otherwise:

`repurchase_90d = 0`

## Risk Interpretation

The model estimates:

`P(repurchase_90d = 1)`

The customer's inactivity risk is calculated as:

`inactivity_risk = 1 - P(repurchase_90d = 1)`

A higher inactivity risk means that the customer is less likely to
repurchase during the next 90 days.

## Temporal Rule

All features must be calculated using information available on or
before the snapshot date.

Future information can only be used to construct the target label.

## Provisional Horizon

`H = 90 days`

Reason: using the feasibility snapshot of 2026-06-08, the 90-day
horizon produced 3,671 repurchasers among 56,637 eligible customers,
equivalent to a 6.48% repurchase rate.

The 60-day alternative produced only 2,502 repurchasers, equivalent
to 4.42%.

Therefore, 90 days provides approximately 47% more positive examples
while maintaining a commercially interpretable prediction horizon.

This decision is provisional and must later be validated using
multiple historical snapshots and business criteria.

------------
Modelo de Machine Learning para estimar la probabilidad de recompra
y detectar clientes con riesgo de inactividad durante los próximos 90 días.
------------