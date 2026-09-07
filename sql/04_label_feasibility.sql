-- =============================================================================
-- Archivo: 04_label_feasibility.sql
-- Propósito: evaluar si los horizontes de 60 y 90 días contienen suficientes
-- clientes elegibles y casos de recompra para formular el problema predictivo.
-- La fecha de snapshot se fija 90 días antes de la última fecha observada, de
-- modo que ambos horizontes puedan evaluarse utilizando información disponible.
-- De manera provisional, se consideran compras válidas los estados Complete,
-- Shipped y Processing; Cancelled y Returned se excluyen.
-- Esta comparación no busca determinar qué horizonte producirá un mejor modelo.
-- La decisión se basa en su interpretación comercial y en la disponibilidad de
-- suficientes casos positivos antes de comenzar el entrenamiento.
-- =============================================================================

WITH purchases AS (
  SELECT
    user_id,
    order_id,
    DATE(created_at) AS order_date
  FROM `customerretentionintelligence.retention_ml.raw_orders`
  WHERE user_id IS NOT NULL
    AND created_at IS NOT NULL
    AND status IN ('Complete', 'Shipped', 'Processing')
),
bounds AS (
  SELECT
    MIN(order_date) AS min_date,
    MAX(order_date) AS max_date
  FROM purchases
),
params AS (
  SELECT
    DATE_SUB(max_date, INTERVAL 90 DAY) AS snapshot_date
  FROM bounds
),
horizons AS (
  SELECT 60 AS horizon_days
  UNION ALL
  SELECT 90 AS horizon_days
),
eligible AS (
  SELECT DISTINCT
    p.user_id
  FROM purchases AS p
  CROSS JOIN params AS x
  WHERE p.order_date <= x.snapshot_date
),
labels AS (
  SELECT
    x.snapshot_date,
    e.user_id,
    h.horizon_days,
    COUNTIF(
      p.order_date > x.snapshot_date
      AND p.order_date <= DATE_ADD(
        x.snapshot_date,
        INTERVAL h.horizon_days DAY
      )
    ) > 0 AS repurchase
  FROM eligible AS e
  CROSS JOIN horizons AS h
  CROSS JOIN params AS x
  LEFT JOIN purchases AS p
    ON p.user_id = e.user_id
  GROUP BY
    x.snapshot_date,
    e.user_id,
    h.horizon_days
)
SELECT
  snapshot_date,
  horizon_days,
  COUNT(*) AS eligible_customers,
  COUNTIF(repurchase) AS repurchasers,
  ROUND(
    SAFE_DIVIDE(COUNTIF(repurchase), COUNT(*)),
    4
  ) AS repurchase_rate,
  ROUND(
    1 - SAFE_DIVIDE(COUNTIF(repurchase), COUNT(*)),
    4
  ) AS inactivity_rate
FROM labels
GROUP BY
  snapshot_date,
  horizon_days
ORDER BY horizon_days;
