# Customer Retention Intelligence

Proyecto end-to-end para estimar qué clientes tienen menor probabilidad de generar una nueva orden en los próximos 90 días, usando BigQuery para el pipeline de datos, Python para el modelo y Looker Studio para exponer los scores.

<img width="1189" height="893" alt="image" src="https://github.com/user-attachments/assets/55c80c07-a4d1-4dbf-b831-9578d5b4fd1b" />

**[Ver dashboard completo en Looker Studio →](https://datastudio.google.com/u/1/reporting/1a2eb806-2c29-491e-9fa0-150a4a8d1c9e)**

## Contexto

Trabajo con **TheLook eCommerce**, un dataset público y sintético de BigQuery (no son clientes reales ni resultados de una campaña real). Copié los datos a mi propio proyecto de GCP (`customerretentionintelligence`, dataset `retention_ml`) y construí capas `raw` y `clean` de usuarios, órdenes, ítems y productos.

**Pregunta de negocio:** en una fecha de corte dada, ¿qué clientes existentes tienen menor probabilidad de crear una nueva orden en los próximos 90 días? La variable objetivo es `reorder_90d`, y el indicador usado para ordenar clientes es `inactivity_risk = 1 - P(reorder_90d = 1)`.

## Resultados

Comparé cuatro enfoques sobre el mismo split temporal (entrenamiento: snapshots de ago–nov 2025, validación: mar 2026, test reservado: jun 2026):

| Modelo | Average Precision | ROC AUC | Tasa de recompra, top 10 % |
|---|---:|---:|---:|
| Regla de recencia | 0,1409 | 0,6612 | 17,07 % |
| Regresión logística | 0,1566 | 0,6727 | 19,46 % |
| **XGBoost (6 variables)** | **0,1969** | **0,7113** | **21,70 %** |

El test tiene 68.484 clientes elegibles con una tasa general de recompra de 8,18 %. El 21,70 % que logra XGBoost en el 10 % mejor puntuado equivale a ~2,65x esa tasa base: el modelo prioriza razonablemente bien a quién revisar primero, aunque sus probabilidades todavía no están calibradas.

Variables del modelo final: `recency_days`, `orders_history`, `orders_90d`, `orders_365d`, `customer_age_days`, `ordered_value_365d`.

El detalle de la evaluación (por qué el split es temporal y no aleatorio, cómo se define la elegibilidad de un cliente, qué mide exactamente `reorder_90d`) está en [`docs/definicion_problema.md`](docs/definicion_problema.md) y [`docs/semana_3.md`](docs/semana_3.md).

## Pipeline

```
BigQuery (raw → clean → snapshots) → Python (train / score) → BigQuery (scores) → Looker Studio
```

1. `sql/00`–`sql/03`: inventario y chequeos de calidad sobre la fuente raw.
2. `sql/04`: define la variable objetivo y evalúa horizontes de 60 vs. 90 días.
3. `sql/05`: construye la capa clean.
4. `sql/06`–`sql/07`: valida conteos y consistencia temporal de la capa clean.
5. `sql/08`: construye los snapshots históricos (train/validación/test) para entrenar.
6. `python/02_temporal_baseline.ipynb`: entrena y compara los modelos, guarda el mejor en `models/`.
7. `sql/09`: construye el snapshot de scoring (sin etiquetas futuras).
8. `python/03_score_customers.ipynb`: carga el modelo, puntúa el snapshot y publica la tabla `customer_scores_v1` en BigQuery.
9. Looker Studio lee `customer_scores_v1` y muestra los scores.

## Reproducirlo

1. Tener un proyecto de GCP con BigQuery habilitado.
2. Correr `sql/02_load_raw.sql` para copiar TheLook a tu propio dataset.
3. Correr `sql/05_build_clean.sql` y `sql/08_build_customer_snapshots_v1.sql`.
4. Ejecutar `python/02_temporal_baseline.ipynb` (dependencias en `requirements.txt`).
5. Correr `sql/09_build_scoring_snapshot_v1.sql` y luego `python/03_score_customers.ipynb`.

## Estructura

```
docs/     → bitácora del proyecto y definición del problema
sql/      → pipeline de BigQuery (raw → clean → snapshots → scoring)
python/   → conexión, entrenamiento y scoring
models/   → modelo XGBoost entrenado (.json)
```

## Stack

BigQuery · Python (pandas, scikit-learn, XGBoost) · Looker Studio

## Licencia

MIT — ver [`LICENSE`](LICENSE).
