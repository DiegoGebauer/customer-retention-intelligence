-- Registro la cantidad de filas de cada tabla clean.

SELECT
    'clean_users' AS table_name,
    COUNT(*) AS row_count
FROM `customerretentionintelligence.retention_ml.clean_users`

UNION ALL

SELECT
    'clean_orders',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_orders`

UNION ALL

SELECT
    'clean_order_items',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_order_items`

UNION ALL

SELECT
    'clean_products',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_products`

ORDER BY table_name;


-- Reviso que las claves principales no tengan valores nulos ni duplicados.

SELECT
    'clean_users' AS table_name,
    COUNTIF(user_id IS NULL) AS null_keys,
    COUNT(user_id) - COUNT(DISTINCT user_id) AS duplicate_rows
FROM `customerretentionintelligence.retention_ml.clean_users`

UNION ALL

SELECT
    'clean_orders',
    COUNTIF(order_id IS NULL),
    COUNT(order_id) - COUNT(DISTINCT order_id)
FROM `customerretentionintelligence.retention_ml.clean_orders`

UNION ALL

SELECT
    'clean_order_items',
    COUNTIF(order_item_id IS NULL),
    COUNT(order_item_id) - COUNT(DISTINCT order_item_id)
FROM `customerretentionintelligence.retention_ml.clean_order_items`

UNION ALL

SELECT
    'clean_products',
    COUNTIF(product_id IS NULL),
    COUNT(product_id) - COUNT(DISTINCT product_id)
FROM `customerretentionintelligence.retention_ml.clean_products`

ORDER BY table_name;


-- Reviso que los registros relacionados existan en sus tablas principales.

SELECT
    'orders_users' AS relation_name,
    COUNT(*) AS orphan_rows
FROM `customerretentionintelligence.retention_ml.clean_orders` AS o
LEFT JOIN `customerretentionintelligence.retention_ml.clean_users` AS u
    ON o.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

SELECT
    'items_orders',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_order_items` AS i
LEFT JOIN `customerretentionintelligence.retention_ml.clean_orders` AS o
    ON i.order_id = o.order_id
WHERE o.order_id IS NULL


UNION ALL

SELECT
    'items_users',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_order_items` AS i
LEFT JOIN `customerretentionintelligence.retention_ml.clean_users` AS u
    ON i.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

SELECT
    'items_products',
    COUNT(*)
FROM `customerretentionintelligence.retention_ml.clean_order_items` AS i
LEFT JOIN `customerretentionintelligence.retention_ml.clean_products` AS p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL

ORDER BY relation_name;