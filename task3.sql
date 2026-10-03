#пункт 1 возрастные группы клиентов с шагом 10 лет и отдельно клиентов, 
#у которых нет данной информации, с параметрами сумма и количество операций за весь период
WITH check_totals AS (
    SELECT
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        QUARTER(t.date_new) AS quarter,
        t.ID_client,
        t.Id_check,
        CASE
            WHEN c.Age IS NULL THEN 'NA'
            WHEN c.Age < 10 THEN '0-9'
            WHEN c.Age < 20 THEN '10-19'
            WHEN c.Age < 30 THEN '20-29'
            WHEN c.Age < 40 THEN '30-39'
            WHEN c.Age < 50 THEN '40-49'
            WHEN c.Age < 60 THEN '50-59'
            ELSE '60+'
        END AS age_group,
        SUM(t.Sum_payment) AS check_amount
    FROM transactions t
    JOIN customers c
	ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY month, quarter,  t.ID_client, t.Id_check, age_group
)
SELECT
    age_group,
    SUM(check_amount) AS total_amount,
    COUNT(Id_check) AS operations_count
FROM check_totals
GROUP BY age_group
ORDER BY age_group;

#пункт 2 поквартально - средние показатели и %
WITH check_totals AS (
    SELECT
        YEAR(t.date_new) AS year,
        QUARTER(t.date_new) AS quarter,
        t.ID_client,
        t.Id_check,
        CASE
            WHEN c.Age IS NULL THEN 'NA'
            WHEN c.Age < 10 THEN '0-9'
            WHEN c.Age < 20 THEN '10-19'
            WHEN c.Age < 30 THEN '20-29'
            WHEN c.Age < 40 THEN '30-39'
            WHEN c.Age < 50 THEN '40-49'
            WHEN c.Age < 60 THEN '50-59'
            WHEN c.Age < 70 THEN '60-69'
            WHEN c.Age < 80 THEN '70-79'
            ELSE '80+'
        END AS age_group,
        SUM(t.Sum_payment) AS check_amount
    FROM transactions t
    JOIN customers c
	ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY year, quarter, t.ID_client, t.Id_check, age_group
),

quarter_stats AS (
    SELECT
        year,
        quarter,
        age_group,
        COUNT(Id_check) AS operations,
        SUM(check_amount) AS total_amount,
        COUNT(DISTINCT ID_client) AS clients_count
    FROM check_totals
    GROUP BY  year, quarter, age_group
)

SELECT
    year,
    quarter,
    age_group,
    # средняя сумма на одного клиента
    ROUND( total_amount / clients_count, 2 ) AS avg_amount_per_client,
    # среднее количество операций на одного клиента
    ROUND( operations / clients_count,  2 ) AS avg_operations_per_client,
    # доля операций возрастной группы в квартале
    ROUND( operations / SUM(operations) OVER ( PARTITION BY year, quarter ) * 100, 2 ) AS operations_percent,
    # доля затрат возрастной группы в квартале
    ROUND( total_amount / SUM(total_amount) OVER (PARTITION BY year, quarter) * 100, 2 ) AS spending_percent
FROM quarter_stats
ORDER BY year, quarter, age_group;