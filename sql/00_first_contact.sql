-- Primer chequeo del entorno: confirmo que el editor de BigQuery funciona
-- y desde qué proyecto se está ejecutando. No toca tablas ni deja nada guardado.
 
SELECT
  CURRENT_TIMESTAMP() AS execution_timestamp,
  @@project_id AS execution_project;
