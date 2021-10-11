DECLARE @Дата           DATE = '20200720',
		@ТолькоИстекшие BIT  = 0;

DECLARE @ПараметрТипСтроения INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ТИПСТРОЙ'),
		@ПараметрСостояние   INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'СОСТОЯНИЕ'),
        @ПараметрАСКУЭ       INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'АСКУЭ');

IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
   DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    Код_ОДПУ  VARCHAR(256),
    Тип       BIT,
    Лицевой   INT,
	Групповой INT,
    ТипСтрой  INT
);
WITH ОДПУ (Групповой, Номер, Тип) AS (
	SELECT
		D.row_id,
        D.Номер,
		0
	FROM [stack].[Документ] AS D 
	JOIN [stack].[Список объектов] AS SO ON D.row_id = SO.[Объекты-Групповой]
	JOIN [stack].[Номенклатура] AS N ON N.row_id = SO.[Номенклатура-Объекты]
	JOIN [stack].[Состояние счетчика] AS SS ON SO.row_id = SS.[Объект-Состояние]
	WHERE D.[Тип документа] = 77
	  AND D.Папки_ADD = 1
	  AND ISNULL(D.ИсправлениеНомер, 0) = 0
	  AND ISNULL(D.ВидСчета, 0) = 0
	  AND ISNULL(N.Идентификатор, 0) = 0
	  AND @Дата BETWEEN SO.ДатНач AND SO.ДатКнц
	  AND @Дата BETWEEN SS.ДатНач AND SS.ДатКнц
	  AND SS.Состояние = 1  
		
		UNION ALL
	
	SELECT 
		D.row_id,
        D.Номер,
		1
	FROM [stack].[Документ] AS D
	JOIN [stack].[Свойства] AS O 
	  ON O.[Документ-Параметры] = D.row_id
		AND @Дата BETWEEN O.ДатНач AND O.ДатКнц
		AND O.[Виды-Параметры] = @ПараметрСостояние
	WHERE D.[Тип документа] = 77
	  AND D.Папки_ADD = 1
	  AND ISNULL(D.ИсправлениеНомер, 0) = 1
	  AND ISNULL(D.ВидСчета, 0) = 0
	  AND O.Значение = 0
), ТипСтроения AS (
    SELECT TOP(1) WITH TIES
        LI.Потомок,
        O.Значение AS ТипСтрой
    FROM [stack].[Лицевые иерархия] AS LI
	JOIN [stack].[Свойства] AS O 
	  ON O.[Счет-Параметры] = LI.Родитель
		 AND O.[Виды-Параметры] = @ПараметрТипСтроения
		 AND @Дата BETWEEN O.ДатНач AND O.ДатКнц
	WHERE LI.ПотомокТип = 3
	ORDER BY ROW_NUMBER() OVER (PARTITION BY LI.Потомок ORDER BY Уровень)
), Лицевые AS (
    SELECT DISTINCT
        D.Номер,
		D.Групповой,
        D.Тип,
        LI.Родитель AS Лицевой
    FROM ОДПУ AS D
    JOIN [stack].[Показания счетчиков] AS PS 
      ON PS.[Показания-Документ] = D.Групповой
         AND PS.Тип = 6
    JOIN [stack].[Лицевые иерархия] AS LI ON LI.Родитель = PS.[Показания-Счет]
    WHERE LI.ПотомокТип = 3
	AND LI.РодительТип=3
)
INSERT INTO #temp_accounts (Код_ОДПУ, Тип, Лицевой,Групповой, ТипСтрой)
SELECT
    LS.Номер, 
    LS.Тип, 
    LS.Лицевой,
	LS.Групповой,
    T.ТипСтрой
FROM Лицевые AS LS
LEFT JOIN ТипСтроения AS T ON T.Потомок = LS.Лицевой
CREATE INDEX NCI_Лицевой ON #temp_accounts (Лицевой);
IF OBJECT_ID(N'tempdb..#temp_counters', N'U') IS NOT NULL
    DROP TABLE #temp_counters;
CREATE TABLE #temp_counters (
	[Лицевой]                   INT,
	[Наименование]              VARCHAR(256),
	[НомНомер]                  VARCHAR(256),
	[ЗаводскойНомер]            VARCHAR(256),
	[Дата_установки]            DATE,
	[ДатаПоверки]               DATE,
	[МПИ]                       VARCHAR(256),
	[ДатаСледующейПоверки]      DATE,
	[Класс точности]            VARCHAR(256),
	[Разрядность]               TINYINT,
	[ГодВыпуска]                DATE,
	[Тарифность]                INT,
	--Собственник
	[Место установки]           INT,
	--Расчётный коэффициент
	[Примечание]                VARCHAR(256),
	[АСКУЭ]                     INT,
	[Состояние]                 INT,
    [ИстекСрокПоверки]          BIT,
);
WITH ПараметрыСчетчика AS (
    SELECT 
        Номенклатура,
        [60] AS МПИ,
        [23] AS [Класс точности]
    FROM (            
		SELECT 
            [ном-параметры] AS Номенклатура,
            [Параметр-Значения] AS Параметр, 
            Значение
        FROM stack.[значения параметров]
        WHERE [Параметр-Значения] IN (23, 60)
    ) AS T
    PIVOT ( 
        MAX(Значение) FOR Параметр IN ([60], [23])
    ) AS PVT
)
INSERT INTO #temp_counters (
	[Лицевой],
	[Наименование],
	[НомНомер],
	[ЗаводскойНомер],
	[Дата_установки],
	[ДатаПоверки],
	[МПИ],
	[ДатаСледующейПоверки],
	[Класс точности],
	[Разрядность],
	[ГодВыпуска],
	[Тарифность],
	--Собственник
	[Место установки],
	--Расчётный коэффициент
	[Примечание],
	[АСКУЭ],
	[Состояние],
	[ИстекСрокПоверки]
)
SELECT 
    A.Лицевой,
	F.Наименование,
	F.НомНомер,
	F.ЗаводскойНомер,
    F.ДатНач, 
	F.ДатаПоверки,
	PS.МПИ,
	F.ДатаСледующейПоверки,
	PS.[Класс точности],
	F.Разрядность, 
    F.ГодВыпуска,
	F.Тарифность,
	--собственник
	F.[Место установки],
	--расчетный
	F.Примечание,
	ASK.Значение,
	F.Состояние,  
    IIF(@Дата >= DATEADD (YEAR, CAST(PS.МПИ AS INT), F.ДатаПоверки), 1, 0)
FROM #temp_accounts AS A
CROSS APPLY
(
	SELECT 
        SO.ROW_ID AS so_row,
        SO.ДатНач, 
		SS.Состояние, 
        SO.ЗаводскойНомер,
        SO.Разрядность,
        SO.Тарифность,
        SO.[Коэффициент трансформации],
        SO.ГодВыпуска,
        SO.ДатаПоверки,
        so.[Место установки],
        SO.Примечание,
        SO.ДатаСледующейПоверки,
        NOM.ROW_ID AS nom_row,
        NOM.Наименование,
        NOM.НомНомер
	FROM stack.[Список объектов] AS SO 
	JOIN stack.[Состояние счетчика] SS
	  ON SS.[Объект-Состояние] = SO.row_id
         AND @Дата BETWEEN SS.ДатНач AND SS.ДатКнц
	JOIN [stack].[Номенклатура] NOM ON SO.[Номенклатура-Объекты] = nom.ROW_ID
	WHERE SO.[Объекты-Групповой] = A.Групповой
	  AND @Дата BETWEEN SO.ДатНач AND SO.ДатКнц
	  AND ISNULL(NOM.Идентификатор, 0) = 0
	  --AND NOM.Идентификатор= 1
	--ORDER BY SO.ДатКнц DESC
) AS F
OUTER APPLY(
	SELECT TOP (1) SSC.ДатКнц
	FROM stack.[Состояние счетчика] AS SSC
	WHERE @Дата>SSC.ДатКнц
	AND
	SSC.Состояние=1 
	AND SSC.[Объект-Состояние]=F.so_row
	ORDER BY SSC.ДатНач 
	) AS SSC
LEFT JOIN ПараметрыСчетчика AS PS ON PS.Номенклатура = F.nom_row
LEFT JOIN stack.[Свойства] AS ASK 
  ON ASK.[Объекты-Параметры]=F.so_row
     AND @Дата BETWEEN ASK.ДатНач AND ASK.ДатКнц
	 AND ASK.[Виды-Параметры] = @ПараметрАСКУЭ;

WITH Адрес AS(
SELECT 
        PVT.[Потомок] AS row_id,  
        PVT.[0] AS [Филиал],
        PVT.[1] AS [Участок],
        PVT.[12] AS [Населенный пункт], 
        PVT.[2] AS [Улица], 
        PVT.[3] AS [Дом]
	FROM (
        SELECT
			LI.Потомок,
			LI.РодительТип,
			CASE WHEN LI.РодительТип = 0        THEN L.Фамилия
				 WHEN LI.РодительТип = 1        THEN O.Название
				 WHEN LI.РодительТип IN (12, 2) THEN IIF(C.До_После = 1, CONCAT(C.Название, ' ', C.Сокращение), CONCAT(C.Сокращение, ' ', C.Название))
				 WHEN LI.РодительТип = 3  THEN CAST(L.Номер AS NVARCHAR(12)) 
			END AS Адрес
	    FROM stack.[Лицевые иерархия] AS LI
	    JOIN stack.[Лицевые счета] AS L ON LI.Родитель = L.row_id
	    LEFT JOIN stack.[Города] AS C ON L.[Улица-Лицевой счет] = C.row_id
	    LEFT JOIN stack.[Организации] AS O ON O.row_id = L.[Счет-Линейный участок]
	    WHERE LI.ПотомокТип = 3 AND РодительТип IN (0, 1, 12, 2, 3)
	) AS T
	PIVOT
	(
		MAX(Адрес) FOR РодительТип IN([0], [1], [12], [2], [3])
	) AS PVT),

УправляющиеКомпании AS (
    SELECT 
        A.Лицевой,
        MAX(O.Название) AS [Наим_УК],
        MAX(CAST(D.Номер AS VARCHAR(256))) AS [Ном_Дог_УК],
		MAX(ORG.Название) AS [Наим_Постав],
		(O.Телефон) AS [Тел_УК]
	FROM #temp_accounts AS A
    JOIN [stack].[Лицевые иерархия] AS LI ON LI.Родитель = A.Лицевой
	JOIN [stack].[Управляющие компании] AS U 
      ON U.[Счет-УК] = LI.Родитель
		 AND @Дата BETWEEN U.ДатНач AND U.ДатКнц
    JOIN stack.Организации AS O ON U.[Организация-УК] = O.row_id
    LEFT JOIN stack.[УК Договоры] AS D 
      ON D.row_id = U.[Дом-УКДоговор] 
         AND @Дата BETWEEN D.ДатНач AND D.ДатКнц
	LEFT JOIN stack.Поставщики AS PS
		ON PS.[Счет-Список поставщиков]=LI.Родитель
		AND @Дата BETWEEN PS.ДатНач AND PS.ДатКнц
	JOIN stack.Организации AS ORG ON PS.[Поставщики-Список] = ORG.row_id
    GROUP BY A.Лицевой, O.Телефон
) 
SELECT  LS.Код_ОДПУ 
		,U.Ном_Дог_УК
		,U.Наим_УК
		,AD.[Населенный пункт] AS [Нас_пункт]
		,AD.Улица
		,AD.Дом
		,U.Наим_Постав
		,AD.Филиал
		,AD.Участок
		,C.Наименование AS [Наименование_ПУ]
		,C.НомНомер AS [Ном_номер]
		,C.ЗаводскойНомер AS [Зав_номер]
		,FORMAT(C.[Дата_установки], 'dd.MM.yyyy') AS [Дата_установки]
		,CHOOSE(C.Состояние, 'Работает', 'Начисляется по среднему', 'не работает') AS [Состояние_ПУ]
		,CONVERT( nvarchar, C.Разрядность) Разрядность
		,CONVERT( nvarchar, C.Тарифность) Тарифность
		,FORMAT(C.ГодВыпуска, 'dd.MM.yyyy') AS [Год_выпуска]
		,FORMAT(C.ДатаПоверки, 'dd.MM.yyyy') AS [Дата_поверки]
		,C.МПИ AS МПИ
		,FORMAT(C.ДатаСледующейПоверки, 'dd.MM.yyyy') AS [Дата_след_поверки]
		,C.[Класс точности] AS [Класс_точности]
		,C.Разрядность
		,C.ГодВыпуска
		,C.Тарифность
		,C.[Место установки]
		,C.Примечание
		,C.АСКУЭ
FROM #temp_accounts AS LS
LEFT JOIN #temp_counters AS C ON C.Лицевой = LS.Лицевой
LEFT JOIN Адрес AS AD ON AD.row_id = LS.Лицевой
LEFT JOIN УправляющиеКомпании AS U ON U.Лицевой = LS.Лицевой

ORDER BY LS.Код_ОДПУ