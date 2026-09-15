-- Reviso la calidad de los datos raw antes de limpiar: cobertura de fechas,
-- estados de las órdenes, nulos, duplicados y relación entre tablas. Son
-- consultas de diagnóstico, no tocan la capa raw. Si aparece algo raro, lo
-- documento y lo resuelvo con una regla explícita en la capa clean.

-- Cobertura temporal y completitud básica de órdenes.
SELECT
  MIN(DATE(created_at)) AS first_order_date,
  MAX(DATE(created_at)) AS last_order_date,
  COUNT(*) AS order_rows,
  COUNT(DISTINCT order_id) AS distinct_orders,
  COUNT(DISTINCT user_id) AS customers_with_orders,
  COUNTIF(created_at IS NULL) AS missing_created_at,
  COUNTIF(user_id IS NULL) AS missing_user_id
FROM `customerretentionintelligence.retention_ml.raw_orders`;

-- Distribución de los estados de las órdenes.
SELECT
  status,
  COUNT(*) AS orders,
  ROUND(
    100 * SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER()),
    2
  ) AS pct
FROM `customerretentionintelligence.retention_ml.raw_orders`
GROUP BY status
ORDER BY orders DESC;

-- Calidad de order_id y relación entre órdenes y usuarios.
WITH order_quality AS (
  SELECT
    COUNT(*) AS total_rows,
    COUNTIF(order_id IS NULL) AS null_order_ids,
    COUNTIF(user_id IS NULL) AS null_user_ids,
    COUNTIF(order_id IS NOT NULL)
      - COUNT(DISTINCT order_id) AS repeated_order_rows
  FROM `customerretentionintelligence.retention_ml.raw_orders`
),
orphans AS (
  SELECT
    COUNTIF(o.user_id IS NOT NULL AND u.id IS NULL) AS orphan_orders
  FROM `customerretentionintelligence.retention_ml.raw_orders` AS o
  LEFT JOIN `customerretentionintelligence.retention_ml.raw_users` AS u
    ON o.user_id = u.id
)
SELECT *
FROM order_quality
CROSS JOIN orphans;

-- Integridad básica del detalle de productos por orden.
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(order_id IS NULL) AS missing_order_id,
  COUNTIF(user_id IS NULL) AS missing_user_id,
  COUNTIF(product_id IS NULL) AS missing_product_id,
  COUNTIF(sale_price IS NULL) AS missing_sale_price,
  COUNTIF(sale_price < 0) AS negative_sale_price
FROM `customerretentionintelligence.retention_ml.raw_order_items`;
