-- =============================================================================
-- Archivo: 05_build_clean.sql
-- Propósito: construir una capa clean reproducible a partir de las tablas raw,
-- sin modificar la fotografía original de la fuente.
-- Se conservan únicamente las columnas necesarias para el caso, se excluyen
-- registros sin claves o fechas indispensables y se minimiza el uso de datos
-- personales. Los estados de las órdenes se mantienen completos, debido a que
-- las reglas para features y labels se aplicarán en una etapa posterior.
-- Las tablas transaccionales se particionan por fecha y se agrupan mediante
-- las claves utilizadas con mayor frecuencia en filtros y relaciones.
-- Importante: CREATE OR REPLACE permite reconstruir la capa clean, pero también
-- reemplaza cualquier versión anterior de estas tablas.
-- =============================================================================

-- 1. Atributos de clientes necesarios para el análisis, sin identificadores directos.
CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.clean_users`
OPTIONS (
  description = 'Atributos clean de clientes sin nombres, correos, direcciones ni coordenadas'
)
AS
SELECT
  id AS user_id,
  age,
  gender,
  country,
  state,
  city,
  traffic_source,
  created_at
FROM `customerretentionintelligence.retention_ml.raw_users`
WHERE id IS NOT NULL;

-- 2. Órdenes con identificadores y fecha de creación disponibles.
CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.clean_orders`
PARTITION BY DATE(created_at)
CLUSTER BY user_id
OPTIONS (
  description = 'Órdenes clean particionadas por fecha de creación y agrupadas por cliente'
)
AS
SELECT
  order_id,
  user_id,
  status,
  created_at,
  shipped_at,
  delivered_at,
  returned_at,
  num_of_item
FROM `customerretentionintelligence.retention_ml.raw_orders`
WHERE order_id IS NOT NULL
  AND user_id IS NOT NULL
  AND created_at IS NOT NULL;

-- 3. Detalle de productos por orden para construir posteriormente variables monetarias.
CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.clean_order_items`
PARTITION BY DATE(created_at)
CLUSTER BY user_id, order_id
OPTIONS (
  description = 'Productos por orden particionados por fecha y agrupados por cliente y orden'
)
AS
SELECT
  id AS order_item_id,
  order_id,
  user_id,
  product_id,
  status,
  created_at,
  sale_price
FROM `customerretentionintelligence.retention_ml.raw_order_items`
WHERE id IS NOT NULL
  AND order_id IS NOT NULL
  AND user_id IS NOT NULL
  AND created_at IS NOT NULL;

-- 4. Atributos de productos que podrán utilizarse para resumir el comportamiento de compra.
CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.clean_products`
OPTIONS (
  description = 'Atributos clean de productos para caracterizar el comportamiento de compra'
)
AS
SELECT
  id AS product_id,
  cost,
  category,
  brand,
  retail_price,
  department
FROM `customerretentionintelligence.retention_ml.raw_products`
WHERE id IS NOT NULL;

-- 5. Verificación de los conteos obtenidos después de la transformación.
SELECT
  'clean_users' AS table_name,
  COUNT(*) AS row_count
FROM `customerretentionintelligence.retention_ml.clean_users`

UNION ALL

SELECT
  'clean_orders',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_orders`

UNION ALL

SELECT
  'clean_order_items',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_order_items`

UNION ALL

SELECT
  'clean_products',
  COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_products`

ORDER BY table_name;
