-- Временная таблица для хранения регионов
DECLARE @random_region Table (id INT IDENTITY(1,1), region nvarchar (100))

-- Начальная и конечная даты
DECLARE @startDate DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
DECLARE @endDate DATE = GETDATE()

INSERT INTO @random_region (region)
VALUES ('Ставропольский край'),
       ('Калининградская область'),
       ('Ленинградская область'),
       ('Московская область'),
       ('Псковская область'),
       ('Ростовская область'),
       ('Тверская область'),
       ('Томская область')

-- Временной таблица для заказов
DECLARE @OrdersData TABLE (
    id INT IDENTITY(1,1),
    OrderId INT,
    random_date DATETIME,
    Region nvarchar (100), 
    ItemId INT,
    Amount INT
);

-- Заполнение таблицы @OrdersData случайными данными
DECLARE @i INT = 1
WHILE @i <= 1000
BEGIN
    INSERT INTO @OrdersData (random_date, OrderId, Region, ItemId, Amount)
    VALUES (
        DATEADD(DAY, FLOOR(RAND() * (1 + DATEDIFF(DAY, @startDate, @endDate))), @startDate),
        RAND() * 100, 
        (SELECT TOP 1 region FROM @random_region ORDER BY NEWID()),
        round(RAND() * 30, 0), 
        round(RAND() * 25, 0)
    )
    SET @i = @i + 1
END

-- Временная таблицы для описания товаров
DECLARE @ItemDescription TABLE (
    Id INT,
    Name NVARCHAR(100)
);

-- Добавление описания товаров
INSERT INTO @ItemDescription (Id, Name)
VALUES
    (1, 'Item1'),
    (2, 'Item2'),
    (3, 'Item3'),
    (4, 'Item4'),
    (5, 'Item5'),
    (6, 'Item6');

-- Создание сводной таблицы по товарам
SELECT *
FROM (
    SELECT OD.Region, ID.Name, Amount
    FROM @OrdersData OD
    JOIN @ItemDescription ID ON OD.ItemId = ID.Id
) AS SourceTable
PIVOT (
    SUM(Amount)
    FOR Name IN ([Item1],[Item2],[Item3],[Item4],[Item5],[Item6])
) AS piv;
