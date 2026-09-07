-- =============================================================================
-- Archivo: 01_source_inventory.sql
-- Propósito: comprobar que la réplica inicial contiene las cuatro tablas raw
-- esperadas y registrar su estructura y cantidad de filas.
-- Las consultas utilizan customerretentionintelligence.retention_ml.raw_*,
-- pero no modifican ninguna tabla. Los resultados funcionan como evidencia
-- del estado de la fuente antes de comenzar las transformaciones.
-- =============================================================================

-- 1. Se comprueba que las tablas raw esperadas existan en el dataset.
SELECT
  table_name,
  table_type,
  creation_time
FROM `customerretentionintelligence.retention_ml.INFORMATION_SCHEMA.TABLES`
WHERE table_name LIKE 'raw_%'
ORDER BY table_name;

-- 2. Se registran las columnas, sus tipos de datos y su condición de nulabilidad.
SELECT
  table_name,
  ordinal_position,
  column_name,
  data_type,
  is_nullable
FROM `customerretentionintelligence.retention_ml.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN (
  'raw_users',
  'raw_orders',
  'raw_order_items',
  'raw_products'
)
ORDER BY table_name, ordinal_position;

-- 3. Se registran los conteos de la fotografía raw replicada desde TheLook.
SELECT
  'raw_users' AS table_name,
  COUNT(*) AS row_count
FROM `customerretentionintelligence.retention_ml.raw_users`

UNION ALL

SELECT
  'raw_orders',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.raw_orders`

UNION ALL

SELECT
  'raw_order_items',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.raw_order_items`

UNION ALL

SELECT
  'raw_products',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.raw_products`

ORDER BY table_name;
