# Definición del problema

## Contexto del proyecto

En este proyecto quiero construir una solución de Machine Learning que ayude a identificar clientes con menor probabilidad de generar una nueva orden en los próximos 90 días. La idea es transformar el historial de compras en una herramienta que permita ordenar clientes para una eventual revisión o acción de retención.

Estoy trabajando con **TheLook eCommerce**, un [dataset público y sintético disponible en BigQuery](https://cloud.google.com/blog/products/ai-machine-learning/bigquery-meets-google-adk-and-mcp). No son clientes reales de una empresa ni resultados de una campaña. Copié los datos a mi proyecto `customerretentionintelligence`, en el dataset `retention_ml`, y preparé tablas `raw` y `clean` de usuarios, órdenes, ítems y productos.

El recorrido que busco construir es: preparar y validar los datos en BigQuery, generar una tabla histórica por cliente y fecha de corte, entrenar y evaluar un modelo en Python y, más adelante, mostrar predicciones en Looker Studio. Este repositorio documenta tanto las decisiones como las limitaciones del proceso.

## Pregunta de negocio

En una fecha de corte determinada, ¿qué clientes existentes tienen menor probabilidad de crear una nueva orden durante los próximos 90 días?

Una respuesta útil permitiría priorizar a quiénes revisar primero. El modelo no decidirá por sí solo qué acción ofrecer ni demostrará que una campaña de retención vaya a funcionar.

## Unidad de análisis y clientes elegibles

Cada fila del conjunto de entrenamiento representará a **un cliente en una fecha de corte** (`user_id`, `snapshot_date`). Un mismo cliente puede aparecer en distintas fechas, con un historial y un resultado futuro diferentes.

Para el primer modelo, consideraré elegible a un cliente si tiene al menos una orden creada en la fecha de corte o antes de ella.

## Variable objetivo del primer modelo

La primera versión del objetivo se llamará `reorder_90d` y quedará identificada mediante `target_version = order_created_v1`.

* `reorder_90d = 1`: el cliente crea al menos una nueva orden en el intervalo `(snapshot_date, snapshot_date + 90 días]`.
* `reorder_90d = 0`: no crea una nueva orden en ese intervalo, siempre que se disponga de datos hasta el final de los 90 días.

Usaré `clean_orders.created_at` para ubicar cada orden en el tiempo. No filtraré por el estado *actual* de la orden al reconstruir fechas históricas, porque ese estado pudo haber cambiado después del corte y no cuento con un historial de sus cambios.

Por esa razón, **crear una orden no equivale necesariamente a completar una compra**. `reorder_90d` mide generación de una nueva orden; no ventas finales ni abandono definitivo.

## Predicción e interpretación

Comenzaré con una regresión logística como modelo de referencia. Estimará `P(reorder_90d = 1)`, es decir, la probabilidad de que un cliente elegible genere una nueva orden dentro del horizonte definido.

Como indicador para ordenar clientes calcularé `inactivity_risk = 1 - P(reorder_90d = 1)`. Un valor alto indicará una menor probabilidad estimada de generar una orden durante esos 90 días. No debe interpretarse como una probabilidad demostrada de abandono permanente ni como el beneficio esperado de contactar al cliente.

## Regla temporal y evaluación

Las variables predictoras se calcularán solo con información disponible hasta la fecha de corte. Los datos posteriores se usarán exclusivamente para definir el resultado futuro. La fecha de creación de la orden será la referencia de la compra; los ítems aportarán información histórica únicamente cuando ya fueran visibles al corte. Mantendré un criterio de fechas consistente en UTC.

Separaré entrenamiento, validación y prueba por fechas, evitando mezclar aleatoriamente filas del pasado y del futuro. Compararé el primer modelo con referencias sencillas —una probabilidad constante y una regla basada en recencia— antes de probar modelos más complejos.

| Uso                    | Fecha de corte | Fin del horizonte de 90 días |
| ---------------------- | -------------- | ---------------------------- |
| Entrenamiento 1        | 2025-08-31     | 2025-11-29                   |
| Entrenamiento 2        | 2025-11-30     | 2026-02-28                   |
| Validación             | 2026-03-01     | 2026-05-30                   |
| Prueba final reservada | 2026-06-01     | 2026-08-30                   |
