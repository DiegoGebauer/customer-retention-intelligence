-- Reviso la primera y última fecha disponible en las órdenes.

SELECT
    MIN(DATE(created_at)) AS first_order_date,
    MAX(DATE(created_at)) AS last_order_date,
    COUNTIF(DATE(created_at) > CURRENT_DATE('UTC')) AS future_dated_orders,
    COUNT(*) AS order_rows
FROM `customerretentionintelligence.retention_ml.clean_orders`;


-- Registro cuándo se crearon las tablas raw utilizadas en el proyecto.

SELECT
    table_name,
    creation_time
FROM `customerretentionintelligence.retention_ml.INFORMATION_SCHEMA.TABLES`
WHERE table_name IN (
    'raw_users',
    'raw_orders',
    'raw_order_items',
    'raw_products'
)
ORDER BY table_name;

-- Reviso que los ítems sean coherentes con sus órdenes y tengan precios válidos.

SELECT
    COUNTIF(i.user_id IS DISTINCT FROM o.user_id) AS user_mismatch,
    COUNTIF(i.created_at < o.created_at) AS item_before_order,
    COUNTIF(i.created_at IS NULL) AS missing_item_date,
    COUNTIF(i.sale_price IS NULL) AS missing_price,
    COUNTIF(i.sale_price < 0) AS negative_price
FROM `customerretentionintelligence.retention_ml.clean_order_items` AS i
INNER JOIN `customerretentionintelligence.retention_ml.clean_orders` AS o
    ON i.order_id = o.order_id;



    -- Diagnostico el desfase entre la fecha del ítem y la fecha oficial de su orden.

SELECT
    COUNT(*) AS total_items,
    COUNTIF(i.created_at < o.created_at) AS item_before_order,
    COUNTIF(DATE(i.created_at) < DATE(o.created_at)) AS item_before_order_date,

    APPROX_QUANTILES(
        IF(
            i.created_at < o.created_at,
            TIMESTAMP_DIFF(o.created_at, i.created_at, SECOND),
            NULL
        ),
        100
    )[OFFSET(50)] AS median_seconds_before,

    APPROX_QUANTILES(
        IF(
            i.created_at < o.created_at,
            TIMESTAMP_DIFF(o.created_at, i.created_at, SECOND),
            NULL
        ),
        100
    )[OFFSET(95)] AS p95_seconds_before,

    MAX(
        IF(
            i.created_at < o.created_at,
            TIMESTAMP_DIFF(o.created_at, i.created_at, SECOND),
            NULL
        )
    ) AS max_seconds_before,

    COUNTIF(
        TIMESTAMP_DIFF(o.created_at, i.created_at, SECOND) > 86400
    ) AS items_more_than_24h_before

FROM `customerretentionintelligence.retention_ml.clean_order_items` AS i
INNER JOIN `customerretentionintelligence.retention_ml.clean_orders` AS o
    ON i.order_id = o.order_id;