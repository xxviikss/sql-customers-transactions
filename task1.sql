WITH monthly_clients AS (
      SELECT DISTINCT
		ID_client,
		DATE_FORMAT(date_new, '%Y-%m') AS month
	FROM transactions
	WHERE date_new >= '2015-06-01'
	  AND date_new < '2016-06-01'
	ORDER BY ID_client, month
),

continuous_clients AS (
    SELECT
        ID_client
    FROM monthly_clients
    GROUP BY ID_client
    HAVING COUNT(*) = 12
),

#SELECT *FROM continuous_clients;


check_totals AS (
    SELECT
        ID_client,
        Id_check,
        SUM(Sum_payment) AS check_amount
    FROM transactions
    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'
    GROUP BY
        ID_client,
        Id_check
)

SELECT
    cc.ID_client,
    AVG(ct.check_amount) AS avg_check,
    SUM(ct.check_amount) / 12.0 AS avg_monthly_purchase,
    COUNT(ct.Id_check) AS operations_count
FROM continuous_clients cc
JOIN check_totals ct
    ON cc.ID_client = ct.ID_client
GROUP BY cc.ID_client
ORDER BY cc.ID_client;