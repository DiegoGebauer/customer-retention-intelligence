# SQL pipeline

Esta carpeta contiene las consultas reproducibles del proyecto **Customer Retention Intelligence**.

Proyecto de Google Cloud: `customerretentionintelligence`  
Dataset de BigQuery: `retention_ml`  
Fuente: `bigquery-public-data.thelook_ecommerce`

## Orden de ejecución

1. `00_first_contact.sql`: comprueba que el editor de BigQuery funciona.
2. `01_source_inventory.sql`: registra tablas, columnas, tipos y conteos de la capa raw.
3. `02_load_raw.sql`: reconstruye las copias raw desde TheLook. Reemplaza las tablas existentes.
4. `03_quality_checks.sql`: audita fechas, estados, claves, duplicados y relaciones.
5. `04_label_feasibility.sql`: compara horizontes de recompra de 60 y 90 días.
6. `05_build_clean.sql`: crea y valida las cuatro tablas de la capa clean.

## Capas

- `raw_*`: copia sin modificaciones de la fuente pública.
- `clean_*`: columnas seleccionadas y reglas de integridad explícitas.
- Features y labels: se construirán en una etapa posterior respetando la fecha de snapshot.

## Consideraciones

- El Project ID no es una contraseña ni una credencial.
- No se deben guardar claves, tokens, archivos `.env` ni JSON de cuentas de servicio en el repositorio.
- Las tablas de TheLook contienen datos ficticios y generados para demostraciones.
- Antes de ejecutar consultas, se debe revisar la estimación de bytes de BigQuery.
- `02_load_raw.sql` solo debe ejecutarse cuando se quiera actualizar intencionalmente la fotografía raw.

