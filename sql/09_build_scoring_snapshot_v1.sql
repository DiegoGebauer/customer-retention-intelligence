-- Una fila por cliente elegible al corte de demostración.
-- Reproduce las seis variables usadas por xgb_6.
-- No calcula etiquetas ni utiliza información posterior al corte.

WITH snapshots AS (
    SELECT DATE '2026-09-05' AS snapshot_date
),

orders AS (
    SELECT
        order_id,
        user_id,
        DATE(created_at) AS order_date
    FROM `customerretentionintelligence.retention_ml.clean_orders`
),

history AS (
    SELECT
        s.snapshot_date,
        o.user_id,
        o.order_id,
        o.order_date
    FROM snapshots AS s
    INNER JOIN orders AS o
        ON o.order_date <= s.snapshot_date
),

order_features AS (
    SELECT
        snapshot_date,
        user_id,
        COUNT(*) AS orders_history,
        COUNTIF(
            order_date > DATE_SUB(snapshot_date, INTERVAL 90 DAY)
        ) AS orders_90d,
        COUNTIF(
            order_date > DATE_SUB(snapshot_date, INTERVAL 365 DAY)
        ) AS orders_365d,
        DATE_DIFF(snapshot_date, MAX(order_date), DAY) AS recency_days,
        DATE_DIFF(snapshot_date, MIN(order_date), DAY) AS customer_age_days,
        MAX(order_date) AS max_feature_order_date
    FROM history
    GROUP BY snapshot_date, user_id
),

item_features AS (
    SELECT
        h.snapshot_date,
        h.user_id,
        SUM(
            IF(
                h.order_date > DATE_SUB(h.snapshot_date, INTERVAL 365 DAY),
                COALESCE(i.sale_price, 0),
                0
            )
        ) AS ordered_value_365d,
        MAX(DATE(i.created_at)) AS max_feature_item_date
    FROM history AS h
    LEFT JOIN `customerretentionintelligence.retention_ml.clean_order_items` AS i
        ON h.order_id = i.order_id
       AND h.user_id = i.user_id
       AND DATE(i.created_at) <= h.snapshot_date
    GROUP BY h.snapshot_date, h.user_id
)

SELECT
    f.user_id,
    f.snapshot_date,
    'order_created_v1' AS target_version,

    f.recency_days,
    f.orders_history,
    f.orders_90d,
    f.orders_365d,
    f.customer_age_days,
    COALESCE(i.ordered_value_365d, 0) AS ordered_value_365d,

    -- Solo para comprobar que ninguna fuente supera el corte.
    f.max_feature_order_date,
    i.max_feature_item_date

FROM order_features AS f
LEFT JOIN item_features AS i
    USING (snapshot_date, user_id);