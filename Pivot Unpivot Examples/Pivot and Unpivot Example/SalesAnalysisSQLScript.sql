DECLARE @startDate DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1) -- объявление даты начала построения отчёта
DECLARE @endDate DATE = GETDATE() -- текущая дата

-- объявление временных таблиц
declare @random_orders TABLE  (id INT IDENTITY(1,1), random_date DATETIME, region nvarchar(100), random_weight FLOAT, random_client INT, randome_price FLOAT)
declare @random_region Table (id INT IDENTITY(1,1), region nvarchar (100))

-- добавление списка регионов в таблицу random_region
INSERT INTO @random_region (region)
VALUES ('Ставропольский край'),
       ('Калининградская область'),
       ('Ленинградская область'),
       ('Московская область'),
       ('Псковская область'),
       ('Ростовская область'),
       ('Тверская область'),
       ('Томская область')

-- вы полнение цикла для наполнения таблицы random_orders случайными значениями
DECLARE @i INT = 1
WHILE @i <= 1000
BEGIN
    INSERT INTO @random_orders (random_date, region, random_weight, random_client, randome_price)
    VALUES (
	DATEADD(DAY, FLOOR(RAND() * (1 + DATEDIFF(DAY, @startDate, @endDate))), @startDate),
	(SELECT TOP 1 region FROM @random_region ORDER BY NEWID()),
	RAND() * 100, 
	round(RAND() * 1000,0), 
	round(RAND() * 1000,2)
	)
    SET @i = @i + 1
END

-- агрегация данных
;WITH SalesData AS (
    SELECT 
        Region, -- Название региона
        MONTH(random_date) AS MonthNumber, -- Номер месяца
        CAST(COUNT(id) AS NVARCHAR(100)) AS [1], -- Общее количество заказов
        CAST(SUM(random_weight) AS NVARCHAR(100)) AS [2], -- Общий вес заказов
        CAST(SUM(randome_price) AS NVARCHAR(100)) AS [3], -- Общая стоимость заказов
        CAST(AVG(randome_price) AS NVARCHAR(100)) AS [4], -- Средняя стоимость заказа
        CAST(COUNT(DISTINCT random_client) as NVARCHAR(100)) AS [5] -- Количество уникальных клиентов
    FROM @random_orders
    GROUP BY Region, MONTH(random_date)
)

-- Используем PIVOT и UNPIVOT для преобразования данных
     SELECT 
	CASE WHEN ROW_NUMBER() OVER (PARTITION BY  piv.region ORDER BY (SELECT NULL)) = 1 THEN piv.region ELSE '' END AS region,
        CASE
        WHEN ID = '1' THEN '1. Общее количество заказов'
        WHEN ID = '2' THEN '2. Общий вес, кг.'
        WHEN ID = '3' THEN '3. Общая стоимость заказов'
        WHEN ID = '4' THEN '4. Средняя стоимость заказа'
        WHEN ID = '5' THEN '5. Количество уникальных клиентов'
        END AS Description,
        ISNULL([1], '0') AS [1],
        ISNULL([2], '0') AS [2],
        ISNULL([3], '0') AS [3],
        ISNULL([4], '0') AS [4],
        ISNULL([5], '0') AS [5],
        ISNULL([6], '0') AS [6],
        ISNULL([7], '0') AS [7],
        ISNULL([8], '0') AS [8],
        ISNULL([9], '0') AS [9],
        ISNULL([10], '0') AS [10],
        ISNULL([11], '0') AS [11],
        ISNULL([12], '0') AS [12]
    FROM (
        SELECT region, MonthNumber, ID, value
        FROM SalesData
        UNPIVOT(
            value FOR ID IN ([1], [2], [3], [4], [5])
        ) AS unpiv
    ) p
    PIVOT (MAX(value) FOR MonthNumber IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS piv 
    JOIN (
        SELECT region
        FROM SalesData
        GROUP BY region
    ) a ON a.region = piv.region
    ORDER BY piv.region, (CASE ID 
                                    WHEN '1' THEN 1 
                                    WHEN '2' THEN 2
                                    WHEN '3' THEN 3 
									WHEN '4' THEN 4
									WHEN '5' THEN 5 
                                    END) ASC