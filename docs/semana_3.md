# Semana 3 — Modelado y puntuación de clientes

## Objetivo

El modelo estima la propensión de un cliente a crear una nueva orden durante los 90 días posteriores a una fecha de corte. La variable objetivo es `reorder_90d` (`target_version: order_created_v1`). No mide el efecto de una campaña de retención ni predice «churn» como una condición permanente.

## Entrenamiento y evaluación

Construí snapshots temporales con información disponible hasta cada fecha de corte. Utilicé los snapshots del 2025-08-31 y 2025-11-30 para entrenar, el del 2026-03-01 para comparar modelos y el del 2026-06-01 como test reservado. Este último se evaluó después de seleccionar el modelo, sin utilizarlo para ajustar variables o hiperparámetros.

Comparé una referencia basada en la tasa general, una regla de recencia, regresión logística y XGBoost. Seleccioné provisionalmente XGBoost con seis variables históricas: `recency_days`, `orders_history`, `orders_90d`, `orders_365d`, `customer_age_days` y `ordered_value_365d`.

| Modelo                  | Average precision en test | ROC AUC en test | Tasa de nueva orden en el 10 % mejor puntuado |
| ----------------------- | ------------------------: | --------------: | --------------------------------------------: |
| Regla de recencia       |                    0,1409 |          0,6612 |                                       17,07 % |
| Regresión logística     |                    0,1566 |          0,6727 |                                       19,46 % |
| XGBoost, seis variables |                    0,1969 |          0,7113 |                                       21,70 % |

El test contiene 68.484 clientes y su tasa general de nueva orden es 8,18 %. Por lo tanto, el 21,70 % observado en el grupo mejor puntuado por XGBoost equivale aproximadamente a 2,65 veces esa tasa general. La mejora describe capacidad de **priorización**, no el resultado esperado de contactar a esos clientes.

## Scoring actual

Guardé el modelo entrenado en `models/xgb_order_created_v1_6f.json`. El notebook `python/03_score_customers.ipynb` lo carga y puntúa un snapshot sin etiquetas futuras, construido por `sql/09_build_scoring_snapshot_v1.sql`.

La salida validada está en BigQuery: `customerretentionintelligence.retention_ml.customer_scores_v1`. Contiene **79.669 clientes únicos**, una fila por cliente para el corte del **2026-09-05**. Incluye el score de nueva orden, un percentil y banda para ordenar clientes, las seis variables utilizadas, las versiones de objetivo y modelo, y la fecha de generación de la predicción.

En esta tabla, un `risk_percentile` más alto indica **menor score estimado de nueva orden**. Las bandas son grupos de prioridad relativa; no deben interpretarse como probabilidades calibradas de inactividad. Los puntajes tampoco permiten afirmar que una intervención de retención causaría una compra.

## Reproducción

1. Construir y validar los snapshots históricos con `sql/08_build_customer_snapshots_v1.sql`.
2. Ejecutar `python/02_temporal_baseline.ipynb` para entrenar, evaluar y guardar el modelo.
3. Construir el snapshot actual con `sql/09_build_scoring_snapshot_v1.sql`.
4. Ejecutar `python/03_score_customers.ipynb` para validar las variables, cargar el modelo, generar scores y publicar la tabla en BigQuery.

La carga del notebook está protegida contra la sobrescritura: si la tabla de destino ya existe, se detiene. Para generar un nuevo corte habrá que definir explícitamente cómo incorporar nuevas fechas sin duplicar clientes.
