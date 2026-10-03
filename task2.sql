WITH check_totals AS (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS month,
        ID_client,
        Id_check,
        SUM(Sum_payment) AS check_amount
    FROM transactions
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
    GROUP BY month, ID_client, Id_check
),

#SELECT * FROM check_totals
#ORDER BY month, ID_client, Id_check;

#относится к пункту 4
monthly AS (
    SELECT
        month,
        COUNT(Id_check) AS operations,
        SUM(check_amount) AS total_amount
    FROM check_totals
    GROUP BY month
)

#Пункт 1 средняя сумма чека в месяц
SELECT month, AVG(check_amount) AS avg_check
FROM check_totals
GROUP BY month
ORDER BY month;

#Пункт 2 среднее количество операций в месяц
SELECT
    month,
    COUNT(Id_check) / COUNT(DISTINCT ID_client) AS avg_operations
FROM check_totals
GROUP BY month
ORDER BY month;

#Пункт 3 среднее количество клиентов, которые совершали операции
SELECT
    month,
    COUNT(DISTINCT ID_client) AS clients_count
FROM check_totals
GROUP BY month
ORDER BY month;

#пункт 4 долю от общего количества операций за год и долю в месяц от общей суммы операций
SELECT
    month,
    operations,
    ROUND(operations / SUM(operations) OVER () * 100, 2) AS operating_share,
    total_amount,
    ROUND(total_amount / SUM(total_amount) OVER () * 100, 2) AS amount_share
FROM monthly
ORDER BY month;

#пункт 5 вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
WITH check_totals_fmna AS (
    SELECT
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        t.ID_client,
        t.Id_check,
        c.Gender,
        SUM(t.Sum_payment) AS check_amount
    FROM transactions t
    JOIN customers c
	ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY month, t.ID_client, t.Id_check, c.Gender
)

SELECT
    month,
	# % мужчин среди клиентов
    ROUND(COUNT(DISTINCT CASE WHEN Gender = 'M' THEN ID_client END) / COUNT(DISTINCT ID_client) * 100, 2 ) AS M_clients_percent,
    # % женщин среди клиентов
    ROUND(COUNT(DISTINCT CASE WHEN Gender = 'F' THEN ID_client END) / COUNT(DISTINCT ID_client) * 100, 2 ) AS F_clients_percent,
    # % клиентов без указанного пола
    ROUND(COUNT(DISTINCT CASE WHEN Gender = 'NA' THEN ID_client END) / COUNT(DISTINCT ID_client) * 100, 2 ) AS NA_clients_percent,
    # % затрат мужчин
    ROUND( SUM(CASE WHEN Gender = 'M' THEN check_amount ELSE 0 END) / SUM(check_amount) * 100, 2 ) AS M_spending_percent,
    # % затрат женщин
    ROUND(SUM(CASE WHEN Gender = 'F' THEN check_amount ELSE 0 END) / SUM(check_amount) * 100, 2 ) AS F_spending_percent,
    # % затрат NA
    ROUND(SUM(CASE WHEN Gender = 'NA' THEN check_amount ELSE 0 END) / SUM(check_amount) * 100, 2 ) AS NA_spending_percent
FROM check_totals_fmna
GROUP BY month
ORDER BY month;