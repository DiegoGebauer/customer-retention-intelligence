-- Construyo la capa clean a partir de raw, sin tocar la fotografía original.
-- Dejo solo las columnas necesarias, saco registros sin claves o fechas
-- clave, y evito datos personales. Mantengo todos los estados de las
-- órdenes; las reglas de features y labels las aplico más adelante. Las
-- tablas transaccionales quedan particionadas por fecha y agrupadas por las
-- claves que más uso en filtros y joins.
-- Ojo: CREATE OR REPLACE reconstruye la capa clean, pero también pisa
-- cualquier versión anterior.

-- Atributos de clientes, sin identificadores directos.
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

-- Órdenes con id de usuario y fecha de creación disponibles.
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

-- Detalle de productos por orden, para variables monetarias más adelante.
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

-- Atributos de productos, para caracterizar el comportamiento de compra.
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

-- Conteos después de la transformación, para comparar contra raw.
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
