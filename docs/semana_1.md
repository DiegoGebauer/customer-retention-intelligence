# Cierre de la semana 1

Durante esta etapa definí el enfoque inicial del proyecto
Customer Retention Intelligence y preparé la base de datos
con la que continuaré el análisis.

## Objetivo del proyecto

Construir una solución de Machine Learning para analizar
la recompra y la inactividad de clientes en comercio electrónico.

El proyecto forma parte de mi aprendizaje práctico y de mi
portafolio de Data Science.

## Decisiones iniciales

Elegí BigQuery como plataforma principal para almacenar
y preparar los datos, Python para desarrollar los modelos
y Looker Studio para presentar los resultados más adelante.

Definí GitHub como repositorio para registrar el código,
las decisiones y los avances del proyecto.

## Configuración de Google Cloud

Creé el proyecto customerretentionintelligence y el dataset
retention_ml en la región US.

Vinculé la facturación y configuré alertas de presupuesto.
Estas alertas permiten monitorear el gasto, pero no equivalen
a un bloqueo automático del consumo.

## Datos utilizados

Seleccioné el dataset público TheLook eCommerce, que contiene
datos ficticios de una tienda de comercio electrónico.

Copié las siguientes tablas al dataset del proyecto:

- raw_users: usuarios.
- raw_orders: órdenes.
- raw_order_items: detalle de productos por orden.
- raw_products: catálogo de productos.

Estas copias constituyen la capa raw y permiten trabajar
sobre una versión propia de los datos de origen.

## Primera revisión

Realicé consultas iniciales para revisar las tablas cargadas,
sus cantidades de registros, columnas y tipos de datos.

Esta revisión me permitió conocer la estructura de la fuente
antes de comenzar la limpieza y la definición de variables.

## Pendientes al cierre

- Profundizar en la calidad y consistencia de los datos.
- Definir cómo medir la recompra y la inactividad.
- Construir la capa clean.
- Conectar Python con BigQuery desde VS Code.

## Nota de documentación

Este resumen fue redactado después de completar la etapa,
para dejar registrado el trabajo realizado.