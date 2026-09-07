-- =============================================================================
-- Archivo: 00_first_contact.sql
-- Propósito: realizar una primera comprobación del entorno de BigQuery e
-- identificar el proyecto desde el cual se ejecuta la consulta.
-- No utiliza tablas ni genera resultados persistentes. Por lo tanto, esta
-- consulta sirve únicamente como prueba inicial y no procesa datos del caso.
-- =============================================================================

SELECT
  CURRENT_TIMESTAMP() AS execution_timestamp,
  @@project_id AS execution_project;
