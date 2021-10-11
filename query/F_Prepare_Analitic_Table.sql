/*
    -- Создание таблицы
    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[Analitic_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[Analitic_LS_ArtemovAS](
        [Услуга] [int] NOT NULL,
        [Тариф] [varchar](5) NOT NULL,
        [Тарифность] [int] NOT NULL,
        [Зона] [int] NOT NULL
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS]
    (
        [Услуга] ASC,
        [Тариф] ASC,
        [Тарифность] ASC,
        [Зона] ASC
    )
    GO

    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[AnaliticReplace_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[AnaliticReplace_LS_ArtemovAS](
	    [Услуга] [int] NOT NULL,
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS]
    (
	    [Услуга] ASC
    )
    GO

    ALTER INDEX [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS] REBUILD
    ALTER INDEX [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS] REBUILD
*/

WITH Replaced AS (
    SELECT * FROM (VALUES -- Для этих услуг, номер услуги подменяется Аналитикой1
        (191), (192), (193), (199), (291), (292), (293),
        (145), (146), (149), (181), (182), (183), (188),
        (245), (246), (249), (281), (282), (283), (288),
        (184), (185), (186), (187)
    ) AS V(Услуга)
)
INSERT INTO [dbo].[AnaliticReplace_LS_ArtemovAS]
SELECT * FROM Replaced;

WITH Services AS (
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 1 AS Тарифность, 1 AS Зона FROM (VALUES (101), (151), (181), (191), (201), (251), (281), (291), (401), (4001), (4003)) AS V(Услуга) UNION ALL -- Газовые плиты - Один тариф
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 2 AS Тарифность, 1 AS Зона FROM (VALUES (154), (254))                                                                  AS V(Услуга) UNION ALL -- Газовые плиты - Два тарифа - День
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 2 AS Тарифность, 2 AS Зона FROM (VALUES (157), (257))                                                                  AS V(Услуга) UNION ALL -- Газовые плиты - Два тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 3 AS Тарифность, 1 AS Зона FROM (VALUES (166), (266))                                                                  AS V(Услуга) UNION ALL -- Газовые плиты - Три тарифа - Пик
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 3 AS Тарифность, 2 AS Зона FROM (VALUES (160), (260))                                                                  AS V(Услуга) UNION ALL -- Газовые плиты - Три тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 3 AS Тарифность, 3 AS Зона FROM (VALUES (163), (263))                                                                  AS V(Услуга) UNION ALL -- Газовые плиты - Три тарифа - Полупик

    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 1 AS Тарифность, 1 AS Зона FROM (VALUES (102), (152), (182), (192), (202), (252), (282), (292), (402))                 AS V(Услуга) UNION ALL -- Электроплиты  - Один тариф
    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 2 AS Тарифность, 1 AS Зона FROM (VALUES (155), (255))                                                                  AS V(Услуга) UNION ALL -- Электроплиты  - Два тарифа - День
    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 2 AS Тарифность, 2 AS Зона FROM (VALUES (158), (258))                                                                  AS V(Услуга) UNION ALL -- Электроплиты  - Два тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 3 AS Тарифность, 1 AS Зона FROM (VALUES (167), (267))                                                                  AS V(Услуга) UNION ALL -- Электроплиты  - Три тарифа - Пик
    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 3 AS Тарифность, 2 AS Зона FROM (VALUES (161), (261))                                                                  AS V(Услуга) UNION ALL -- Электроплиты  - Три тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'Э' AS Тариф, 3 AS Тарифность, 3 AS Зона FROM (VALUES (164), (264))                                                                  AS V(Услуга) UNION ALL -- Электроплиты  - Три тарифа - Полупик
     
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 1 AS Тарифность, 1 AS Зона FROM (VALUES (103), (153), (183), (193), (203), (253), (283), (293), (403))                 AS V(Услуга) UNION ALL -- Село          - Один тариф
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 2 AS Тарифность, 1 AS Зона FROM (VALUES (156), (256))                                                                  AS V(Услуга) UNION ALL -- Село          - Два тарифа - День
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 2 AS Тарифность, 2 AS Зона FROM (VALUES (159), (259))                                                                  AS V(Услуга) UNION ALL -- Село          - Два тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 3 AS Тарифность, 1 AS Зона FROM (VALUES (168), (268))                                                                  AS V(Услуга) UNION ALL -- Село          - Три тарифа - Пик
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 3 AS Тарифность, 2 AS Зона FROM (VALUES (162), (262))                                                                  AS V(Услуга) UNION ALL -- Село          - Три тарифа - Ночь
    SELECT 'Э' AS Группа, Услуга, 'С' AS Тариф, 3 AS Тарифность, 3 AS Зона FROM (VALUES (165), (265))                                                                  AS V(Услуга) UNION ALL -- Село          - Три тарифа - Полупик

    SELECT 'П' AS Группа, Услуга, 'ОТКЛ'  AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (301), (302), (303), (304), (305))                                        AS V(Услуга) UNION ALL -- Прочие услуги  - Отключение
    SELECT 'П' AS Группа, Услуга, 'ПОДКЛ' AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (351), (352), (353), (354), (355))                                        AS V(Услуга) UNION ALL -- Прочие услуги  - Подключение
    SELECT 'П' AS Группа, Услуга, 'ГОСП'  AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (3700), (3701))                                                           AS V(Услуга) UNION ALL -- Прочие услуги  - Госпошлина
    SELECT 'П' AS Группа, Услуга, 'СИЗД'  AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (3800), (3801))                                                           AS V(Услуга) UNION ALL -- Прочие услуги  - Судебные издержки
    SELECT 'П' AS Группа, Услуга, 'СПЕНИ' AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (3900), (3901))                                                           AS V(Услуга) UNION ALL -- Прочие услуги  - Судебные пени
    SELECT 'П' AS Группа, Услуга, 'ПЕНИ'  AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (65535))                                                                  AS V(Услуга) UNION ALL -- Прочие услуги  - Пени
    SELECT 'П' AS Группа, Услуга, 'РЕСТР' AS Тариф, 0 AS Тарифность, 0 AS Зона FROM (VALUES (20000), (21001))                                                         AS V(Услуга) UNION ALL -- Прочие услуги  - Проценты по реструктуризации

    SELECT 'Э' AS Группа, Услуга, 'Г' AS Тариф, 1 AS Тарифность, 1 AS Зона FROM 
        (VALUES (109), (135), (145), (146), (149), (176), (184), (185), (186), (187), (188), (189), (199), (235), (245), (246), (249), (284), (285), (286), (287),
                (100), (130), (150), (200), (230), (250), (400))                                                                                                     AS V(Услуга)            -- Остальные услуги 100, 200 групп, трактуются ка ЭЭ газовые плиты одноставочный
)
INSERT INTO [dbo].[Analitic_LS_ArtemovAS](Услуга, Тариф, Тарифность, Зона)
SELECT Услуга, Тариф, Тарифность, Зона
FROM Services
WHERE Группа = 'Э'