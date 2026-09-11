# Definición del problema

## Pregunta de negocio

En una fecha de corte determinada, ¿qué clientes existentes tienen mayor probabilidad de volver a comprar durante los próximos 90 días?

El objetivo de negocio es identificar a los clientes con mayor riesgo de inactividad para priorizar acciones de retención.

## Clientes elegibles

Un cliente se considera elegible si realizó al menos una orden que cumple los criterios del análisis en la fecha de corte o antes de ella.

Para este análisis provisional, se consideran las órdenes con alguno de los siguientes estados:

- Complete
- Shipped
- Processing

Se excluyen las órdenes con estado Cancelled o Returned.

## Variable objetivo

`repurchase_90d = 1` si el cliente realiza al menos una orden que cumple los criterios anteriores dentro del intervalo:

`(snapshot_date, snapshot_date + 90 days]`

En caso contrario:

`repurchase_90d = 0`

## Interpretación del riesgo

El modelo buscará estimar:

`P(repurchase_90d = 1)`

El riesgo de inactividad del cliente se calculará como:

`inactivity_risk = 1 - P(repurchase_90d = 1)`

Un mayor riesgo de inactividad indica una menor probabilidad de que el cliente vuelva a comprar durante los próximos 90 días.

## Regla temporal

Todas las variables predictoras deben calcularse utilizando información disponible en la fecha de corte o antes de ella.

La información futura solo puede utilizarse para construir la variable objetivo.

## Horizonte provisional

`H = 90 days`

Con la fecha de corte exploratoria `2026-06-08`, el horizonte de 90 días permitió identificar 3.671 clientes con recompra entre 56.637 clientes elegibles, lo que equivale a una tasa de recompra del 6,48 %.

La alternativa de 60 días identificó 2.502 clientes con recompra, equivalentes a una tasa del 4,42 %.

Por lo tanto, el horizonte de 90 días aporta aproximadamente un 47 % más de casos positivos y mantiene un período de predicción que puede interpretarse desde el negocio.

Esta decisión es provisional y deberá validarse posteriormente utilizando distintas fechas de corte históricas y criterios de negocio.
