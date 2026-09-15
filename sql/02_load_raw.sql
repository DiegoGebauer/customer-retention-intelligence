-- Copio las tablas de bigquery-public-data.thelook_ecommerce tal cual a mi
-- dataset (retention_ml), como raw_*. CREATE OR REPLACE pisa la fotografía
-- raw existente, así que solo corro esto cuando quiero actualizarla a propósito.

CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.raw_users`
OPTIONS (
  description = 'Fotografía raw de usuarios replicada desde el dataset público TheLook'
)
AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.users`;

CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.raw_orders`
OPTIONS (
  description = 'Fotografía raw de órdenes replicada desde el dataset público TheLook'
)
AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.orders`;

CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.raw_order_items`
OPTIONS (
  description = 'Fotografía raw de productos por orden replicada desde el dataset público TheLook'
)
AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

CREATE OR REPLACE TABLE
  `customerretentionintelligence.retention_ml.raw_products`
OPTIONS (
  description = 'Fotografía raw de productos replicada desde el dataset público TheLook'
)
AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.products`;
