-- Reviso que las cuatro tablas raw esperadas existan en el dataset y dejo
-- registro de su estructura y volumen. Solo lectura: sirve como evidencia
-- del estado de la fuente antes de empezar a transformar nada.
 
-- Tablas raw que debieran existir.
SELECT
  table_name,
  table_type,
  creation_time
FROM `customerretentionintelligence.retention_ml.INFORMATION_SCHEMA.TABLES`
WHERE table_name LIKE 'raw_%'
ORDER BY table_name;
 
-- Columnas, tipos de dato y nulabilidad de cada tabla raw.
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
 
-- Conteos de la fotografía raw replicada desde TheLook.
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
