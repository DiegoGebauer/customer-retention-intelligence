# Semana 2.5 — Auditoría temporal

## Cobertura de las órdenes

- Primera orden registrada: 2019-01-25.
- Última orden registrada: 2026-09-06.
- Total de órdenes en la capa clean: 124.053.
- Órdenes fechadas después del día de ejecución: 0.
- No se observaron días sin órdenes entre 2026-05-01 y 2026-09-06.

Las cuatro tablas raw se crearon el 2026-09-06 entre las 04:34:33 y las 04:34:41 UTC, por lo que parecen corresponder a una misma copia.

El 2026-09-06 registra solo 46 órdenes y la copia se creó durante ese día. Por ahora usaré 2026-09-05 como último día observado para las comprobaciones. Esta fecha es provisional: la ausencia de días vacíos no demuestra por sí sola que cada día anterior esté completo.

## Coherencia de ítems

- Total de ítems: 179.932.
- Ítems con `created_at` anterior al de su orden: 101.519.
- De ellos, 8.140 tienen una fecha calendario anterior.
- Desfase máximo observado: 14.258 segundos.
- Ítems con más de 24 horas de adelanto: 0.
- No se encontraron usuarios distintos entre ítem y orden, fechas de ítem faltantes, precios nulos ni precios negativos.

Para definir cuándo ocurrió una compra usaré `clean_orders.created_at`. Al construir variables de importe para una fecha de corte, incluiré solo ítems cuya información ya estuviera disponible hasta ese corte. No eliminaré ítems únicamente por este desfase.