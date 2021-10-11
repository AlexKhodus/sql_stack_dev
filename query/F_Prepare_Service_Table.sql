/*
    -- Создание таблицы
    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[ServiceTable_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[ServiceTable_LS_ArtemovAS](
	    [Месяц] [date] NOT NULL,
	    [Лицевой] [int] NOT NULL,
        [Родитель] [int] NOT NULL,
	    [Услуга] [int] NOT NULL,
        [Тип] [int] NOT NULL
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS]
    (
	    [Месяц] ASC,
        [Лицевой] ASC,
        [Родитель] ASC,
	    [Услуга] ASC,
        [Тип] ASC
    )
    GO

    ALTER INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] REBUILD
*/


DECLARE @DateBegin DATE = '20210401',
        @DateEnd   DATE = '20210401';

WITH Volumes AS (
    SELECT
        Счет,
        [Месяц расчета] AS Месяц
    FROM [stack].[НТариф]
    WHERE [Месяц расчета] BETWEEN @DateBegin AND @DateEnd
      AND [Номер услуги] - [Номер услуги] % 100 IN (100, 200, 400)
    --  AND Счет IN (SELECT Потомок FROM stack.[Лицевые иерархия] WHERE Родитель = 3272200)

        UNION ALL

    SELECT
        Счет,
        [Перерасчет] AS Месяц
    FROM [stack].[НПТариф]
    WHERE [Месяц расчета] BETWEEN @DateBegin AND @DateEnd
      AND [Номер услуги] - [Номер услуги] % 100 IN (100, 200, 400)
    --  AND Счет IN (SELECT Потомок FROM stack.[Лицевые иерархия] WHERE Родитель = 3272200)
      --AND Перерасчет BETWEEN DATEFROMPARTS(DATEPART(YEAR, @DateBegin), 1, 1) AND DATEFROMPARTS(DATEPART(YEAR, @DateBegin), 12, 1) -- Перерасчеты текущих лет
), Accounts AS (
    SELECT DISTINCT Счет, Месяц
    FROM Volumes
), HouseTypePivot AS (
    SELECT 
        Счет, Месяц, COALESCE([5], [4], [3]) AS Тип
    FROM (
        SELECT
            A.Счет, LH.РодительТип, A.Месяц, O.Значение
        FROM Accounts AS A
        JOIN stack.[Лицевые иерархия] AS LH ON A.Счет = LH.Потомок
        JOIN stack.Свойства AS O 
	      ON O.[Счет-Параметры] = LH.Родитель
	         AND O.[Виды-Параметры] = (SELECT row_id FROM stack.[Виды параметров] WHERE Название = 'ТИПСТРОЙ')
             AND A.Месяц BETWEEN O.ДатНач AND O.ДатКнц
        WHERE LH.ПотомокТип = 5 
          AND LH.РодительТип IN (3, 4, 5)
    ) AS T
    PIVOT( 
        MAX(Значение) FOR РодительТип IN ([3], [4], [5])
    ) AS PVT
), ServiceTypePivot AS (
    SELECT 
        Счет, Месяц, COALESCE([5], [4], [3]) AS [Номер услуги]
    FROM (
        SELECT 
            A.Счет, LH.РодительТип, A.Месяц, TU.[Номер услуги]
        FROM Accounts AS A
        JOIN stack.[Лицевые иерархия] AS LH ON A.Счет = LH.Потомок
        JOIN stack.[Список услуг] AS SU 
          ON SU.[Счет-Услуги] = LH.Родитель
             AND A.Месяц BETWEEN SU.ДатНач AND SU.ДатКнц
             AND SU.Состояние = 0
        JOIN stack.[Типы услуг] AS TU ON TU.ROW_ID = SU.[Вид-Услуги]
        WHERE LH.ПотомокТип = 5 
          AND LH.РодительТип IN (3, 4, 5)   
    ) AS T
    PIVOT( 
        MAX([Номер услуги]) FOR РодительТип IN ([3], [4], [5])
    ) AS PVT
), Parent AS (
    SELECT A.Счет, MAX(LH.Родитель) AS Родитель
    FROM Accounts AS A
    JOIN stack.[Лицевые иерархия] AS LH ON A.Счет = LH.Потомок
    WHERE LH.РодительТип = 12
      AND LH.ПотомокТип = 5
    GROUP BY A.Счет
)
INSERT INTO [dbo].[ServiceTable_LS_ArtemovAS](Месяц, Лицевой, Родитель, Услуга, Тип)
SELECT
    A.Месяц, 
    A.Счет,
    P.Родитель,
    ISNULL(ST.[Номер услуги], 100),
    CASE ISNULL(HT.Тип, 1) 
        WHEN 0 THEN 0
        WHEN 2 THEN 0  
        WHEN 1 THEN 1 
        ELSE 2 
    END
FROM Accounts AS A
JOIN Parent AS P ON P.Счет = A.Счет
LEFT JOIN HouseTypePivot AS HT ON A.Счет = HT.Счет AND A.Месяц = HT.Месяц
LEFT JOIN ServiceTypePivot AS ST ON A.Счет = ST.Счет AND A.Месяц = ST.Месяц
OPTION (RECOMPILE);

ALTER INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] REBUILD;