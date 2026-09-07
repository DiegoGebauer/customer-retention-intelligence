-- =============================================================================
-- Archivo: 02_load_raw.sql
-- Propósito: construir una fotografía reproducible de las tablas utilizadas
-- desde el dataset público TheLook eCommerce.
-- La fuente corresponde a bigquery-public-data.thelook_ecommerce y las copias
-- quedan almacenadas como raw_* en el dataset retention_ml.
-- Importante: CREATE OR REPLACE reemplaza la fotografía raw existente. Por
-- este motivo, el archivo solo debe ejecutarse cuando se decida actualizar
-- intencionalmente la fuente del proyecto.
-- =============================================================================

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
