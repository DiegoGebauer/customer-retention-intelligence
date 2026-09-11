# Cierre de la semana 2

Dejé funcionando la conexión entre Python y BigQuery desde
VS Code, usando el entorno virtual del proyecto.

## Configuración

- Proyecto de Google Cloud: customerretentionintelligence
- Dataset: retention_ml
- Región: US
- Notebook de conexión: python/01_bigquery_connection.ipynb

## Validaciones realizadas

Las tablas clean conservaron la cantidad de registros de raw:

| Tabla | Registros |
|---|---:|
| Usuarios | 100.000 |
| Órdenes | 124.053 |
| Ítems de órdenes | 179.932 |
| Productos | 29.120 |

No encontré duplicados en las cuatro claves revisadas ni
registros huérfanos en las cuatro relaciones comprobadas.

Desde Python pude leer los 100.000 usuarios y obtener un
resumen de 79.684 clientes con órdenes.

## Pendientes

Falta revisar la cobertura de fechas y la consistencia temporal,
además de posibles problemas en los precios.

El resumen de órdenes utiliza todo el período y todos los
estados. Para entrenar el modelo construiré una tabla por
cliente y fecha de corte, usando únicamente la información
disponible hasta ese momento.