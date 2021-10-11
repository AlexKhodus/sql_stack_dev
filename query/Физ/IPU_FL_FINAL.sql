DECLARE @Дата           DATE = '20200601',
        @ТолькоИстекшие BIT  = 0;

DECLARE @ПараметрТипСтроения INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ТИПСТРОЙ'),
        @ПараметрСостояние   INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'СОСТОЯНИЕ'),
        @ПараметрЮрЛицо      INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ЮРЛИЦО'),
        @ПараметрНТВ         INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'НТВ_ИСЧ_ЭЛ'),
        @ПараметрАСКУЭ       INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'АСКУЭ');


IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
    DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    Номер_ЛС  BIGINT, 
    Код_ОДПУ  VARCHAR(256),
    Тип       BIT,
    Лицевой   INT,
    ФИО       VARCHAR(256),
    Состояние INT,
    НТВ       INT,
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
	WHERE LI.ПотомокТип = 5
	ORDER BY ROW_NUMBER() OVER (PARTITION BY LI.Потомок ORDER BY Уровень)
), Лицевые AS (
    SELECT DISTINCT
        D.Номер,
        D.Тип,
        LI.Потомок AS Лицевой,
        SLS.Значение AS Состояние
    FROM ОДПУ AS D
    JOIN [stack].[Показания счетчиков] AS PS 
      ON PS.[Показания-Документ] = D.Групповой
         AND PS.Тип = 6
    JOIN [stack].[Лицевые иерархия] AS LI ON LI.Родитель = PS.[Показания-Счет]
    LEFT JOIN stack.Свойства AS TU
      ON TU.[Счет-Параметры] = LI.Потомок
	     AND @Дата BETWEEN TU.ДатНач AND TU.ДатКнц
         AND TU.[Виды-Параметры] = @ПараметрЮрЛицо
    LEFT JOIN stack.Свойства AS SLS
      ON SLS.[Счет-Параметры] = LI.Потомок
	     AND @Дата BETWEEN SLS.ДатНач AND SLS.ДатКнц
         AND SLS.[Виды-Параметры] = @ПараметрСостояние
    WHERE LI.ПотомокТип = 5
      AND TU.row_id IS NULL
      AND ISNULL(SLS.Значение, 0) != 2
)
INSERT INTO #temp_accounts (Номер_ЛС, Код_ОДПУ, Тип, Лицевой, ФИО, Состояние, НТВ, ТипСтрой)
SELECT
    L.Номер,
    LS.Номер, 
    LS.Тип, 
    LS.Лицевой,
    CR.ФИО,
    LS.Состояние,
    US.Значение,
    T.ТипСтрой
FROM Лицевые AS LS
JOIN stack.[Лицевые счета] AS L ON L.ROW_ID = LS.Лицевой
JOIN stack.[Карточки регистрации] CR ON CR.[Счет-Наниматель] = LS.Лицевой
LEFT JOIN ТипСтроения AS T ON T.Потомок = LS.Лицевой
LEFT JOIN stack.Свойства AS US
  ON US.[Счет-Параметры] = LS.Лицевой
	 AND @Дата BETWEEN US.ДатНач AND US.ДатКнц
     AND US.[Виды-Параметры] = @ПараметрНТВ
	 
WHERE L.Номер IN (230202366337, 230206663699, 230206663699, 230202328489, 230405000685,230201932516);

CREATE INDEX NCI_Лицевой ON #temp_accounts (Лицевой);

IF OBJECT_ID(N'tempdb..#temp_counters', N'U') IS NOT NULL
    DROP TABLE #temp_counters;

CREATE TABLE #temp_counters (
	[Лицевой]                   INT,
	[Дата_установки]            DATE,
	[Состояние]                 INT,
	[ЗаводскойНомер]            VARCHAR(256),
	[Разрядность]               TINYINT,
	[Тарифность]                INT,
	[Коэффициент трансформации] FLOAT,
	[ГодВыпуска]                DATE,
	[ДатаПоверки]               DATE,
	[Место установки]           INT,
	[Примечание]                VARCHAR(256),
	[ДатаСледующейПоверки]      DATE,
	[Наименование]              VARCHAR(256),
	[НомНомер]                  VARCHAR(256),
	[МПИ]                       VARCHAR(256),
	[Класс точности]            VARCHAR(256),
	[Напряжение]                VARCHAR(256),
	[Ток]                       VARCHAR(256),
	[Фазы]                      VARCHAR(256),
    [АСКУЭ]                     INT,
    [ИстекСрокПоверки]          BIT,
    [Дата установки]            DATE,
    [Кто установил]             INT,  
    [Состояние пломбы]          INT
);

WITH ПараметрыСчетчика AS (
    SELECT 
        Номенклатура,
        [60] AS МПИ,
        [23] AS [Класс точности], 
        [28] AS Напряжение,
        [27] AS Ток,
        [24] AS Фазы
    FROM (            
		SELECT 
            [ном-параметры] AS Номенклатура,
            [Параметр-Значения] AS Параметр, 
            Значение
        FROM stack.[значения параметров]
        WHERE [Параметр-Значения] IN (23, 24, 27, 28, 60)
    ) AS T
    PIVOT ( 
        MAX(Значение) FOR Параметр IN ([28], [27], [24], [60], [23])
    ) AS PVT
)
INSERT INTO #temp_counters (
    [Лицевой], [Дата_установки], [Состояние], [ЗаводскойНомер],
	[Разрядность], [Тарифность], [Коэффициент трансформации], [ГодВыпуска], [ДатаПоверки], [Место установки],
	[Примечание], [ДатаСледующейПоверки], [Наименование], [НомНомер],
	[МПИ], [Класс точности], [Напряжение], [Ток], [Фазы], [АСКУЭ], [ИстекСрокПоверки],
    [Дата установки], [Кто установил], [Состояние пломбы]
)
SELECT 
    A.Лицевой,
    F.ДатНач, 
	F.Состояние, 
    F.ЗаводскойНомер,
    F.Разрядность, 
    F.Тарифность,
    F.[Коэффициент трансформации],
    F.ГодВыпуска,
    F.ДатаПоверки,
    F.[Место установки],
    F.Примечание,
    F.ДатаСледующейПоверки,
    F.Наименование,
    F.НомНомер,
    PS.МПИ,
    PS.[Класс точности],
    PS.Напряжение, 
    PS.Ток,
    PS.Фазы,
    ASK.Значение,
    IIF(@Дата >= DATEADD (YEAR, CAST(PS.МПИ AS INT), F.ДатаПоверки), 1, 0),
    PL.[Дата установки],
    PL.[Кто установил],
    PL.Состояние
FROM #temp_accounts AS A
CROSS APPLY
(
	SELECT TOP (1)
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
	WHERE SO.[Объекты-Счет] = A.Лицевой 
	  AND @Дата BETWEEN SO.ДатНач AND SO.ДатКнц
	  AND ISNULL(NOM.Идентификатор, 0) = 0
	ORDER BY SO.ДатКнц DESC
) AS F
LEFT JOIN ПараметрыСчетчика AS PS ON PS.Номенклатура = F.nom_row
LEFT JOIN stack.[Свойства] AS ASK 
  ON ASK.[Объекты-Параметры]=F.so_row
     AND @Дата BETWEEN ASK.ДатНач AND ASK.ДатКнц
	 AND ASK.[Виды-Параметры] = @ПараметрАСКУЭ
OUTER APPLY (
	SELECT TOP (1)
        PL.[Дата установки],
        PL.[Кто установил],
        PL.Состояние
	FROM stack.[Пломбы] AS PL
	WHERE PL.[Пломба-Объект] = F.so_row 
	ORDER BY PL.[Дата установки] DESC
) AS PL;

IF OBJECT_ID(N'tempdb..#temp_phones', N'U') IS NOT NULL
    DROP TABLE #temp_phones;

CREATE TABLE #temp_phones (
	[Лицевой]  INT,
    СМС        VARCHAR(MAX),
    Автообзвон VARCHAR(MAX),
    Телефон    VARCHAR(MAX),
    [E_MAIL]   VARCHAR(MAX)
);

WITH Телефоны AS (
    SELECT DISTINCT 
        A.Лицевой,
        T.Флаги,
        T.Номер
    FROM #temp_accounts AS A
    JOIN [stack].[Телефоны] AS T ON T.[Счет-Телефон] = A.Лицевой
    WHERE T.Флаги IN (1, 2, 3, 4)
)
INSERT INTO #temp_phones ([Лицевой], СМС, Автообзвон, Телефон, [E_MAIL])
SELECT
    Лицевой,
    [stack].[CLR_Concat](IIF(Флаги = 1, Номер, NULL)) AS [Телефон],
    [stack].[CLR_Concat](IIF(Флаги = 2, Номер, NULL)) AS [Смс],
    [stack].[CLR_Concat](IIF(Флаги = 3, Номер, NULL)) AS [Автообзвон],
    [stack].[CLR_Concat](IIF(Флаги = 4, Номер, NULL)) AS [E_MAIL]
FROM Телефоны
GROUP BY Лицевой;

CREATE INDEX NCI_Лицевой ON #temp_phones (Лицевой);

WITH Адрес AS(
    SELECT 
        PVT.[Потомок] AS row_id,  
        PVT.[0] AS [Филиал],
        PVT.[1] AS [Участок],
        PVT.[12] AS [Населенный пункт], 
        PVT.[2] AS [Улица], 
        PVT.[3] AS [Дом],
        PVT.[4] AS [Квартира]
	FROM (
        SELECT
			LI.Потомок,
			LI.РодительТип,
			CASE WHEN LI.РодительТип = 0        THEN L.Фамилия
				 WHEN LI.РодительТип = 1        THEN O.Название
				 WHEN LI.РодительТип IN (12, 2) THEN IIF(C.До_После = 1, CONCAT(C.Название, ' ', C.Сокращение), CONCAT(C.Сокращение, ' ', C.Название))
				 WHEN LI.РодительТип IN (3, 4)  THEN CAST(L.Номер AS NVARCHAR(12)) 
			END AS Адрес
	    FROM stack.[Лицевые иерархия] AS LI
	    JOIN stack.[Лицевые счета] AS L ON LI.Родитель = L.row_id
	    LEFT JOIN stack.[Города] AS C ON L.[Улица-Лицевой счет] = C.row_id
	    LEFT JOIN stack.[Организации] AS O ON O.row_id = L.[Счет-Линейный участок]
	    WHERE LI.ПотомокТип = 5 AND РодительТип IN (0, 1, 12, 2, 3, 4)
	) AS T
	PIVOT
	(
		MAX(Адрес) FOR РодительТип IN([0], [1], [12], [2], [3], [4])
	) AS PVT
), УправляющиеКомпании AS (
    SELECT 
        A.Лицевой,
        MAX(O.Название) AS [Наим_УК],
        MAX(CAST(D.Номер AS VARCHAR(256))) AS [Ном_Дог_УК]
	FROM #temp_accounts AS A
    JOIN [stack].[Лицевые иерархия] AS LI ON LI.Потомок = A.Лицевой
	JOIN [stack].[Управляющие компании] AS U 
      ON U.[Счет-УК] = LI.Родитель
		 AND @Дата BETWEEN U.ДатНач AND U.ДатКнц
    JOIN stack.Организации AS O ON U.[Организация-УК] = O.row_id
    LEFT JOIN stack.[УК Договоры] AS D 
      ON D.row_id = U.[Дом-УКДоговор] 
         AND @Дата BETWEEN D.ДатНач AND D.ДатКнц
    GROUP BY A.Лицевой
)   
SELECT 
    LS.Номер_ЛС,
    LS.Код_ОДПУ, 
    'Да' AS Признак_нал_дог,
    IIF(ISNULL(LS.Состояние, 0) = 0, 'Используется', 'Не проживает') AS [Сост_ЛС],
    CASE LS.ТипСтрой 
        WHEN 0 THEN 'Многоквартирный'		
		WHEN 1 THEN 'Частный'				
		WHEN 2 THEN 'Общежитие'
		WHEN 3 THEN 'Дача'
		WHEN 4 THEN 'Гараж'
		WHEN 5 THEN 'Баня'
		WHEN 6 THEN 'Сарай'
		WHEN 7 THEN 'Прочие'
		WHEN 8 THEN 'Гаражи отдельностоящие'
    END AS [Тип_строения],
    AD.Филиал,
    AD.Участок,
    AD.[Населенный пункт] AS [Населенный_пункт],
    AD.Улица AS [Улица],
    AD.Дом AS [Ном_дома],
    AD.Квартира AS [Ном_квартиры],
    K.Фамилия AS [Ном_комнаты],
    LS.ФИО,
    CASE LS.НТВ 
        WHEN 0 THEN 'Есть'
        WHEN 1 THEN 'Нет'
    END AS [Возможность_уст_ПУ],
    IIF(C.Наименование IS NULL, 'Отсутствует ПУ', 'Индивидуальный') AS [Вид_ПУ],
    FORMAT(C.[Дата_установки], 'dd.MM.yyyy') AS [Дата_установки],
    CHOOSE(C.Состояние, 'Работает', 'Начисляется по среднему', 'не работает') AS [Состояние_ПУ],
    C.Наименование AS [Наименование_ПУ],
    C.ЗаводскойНомер AS [Номер_ПУ],
	CONVERT( nvarchar, C.Разрядность) Разрядность, 
    CONVERT( nvarchar, C.Тарифность) Тарифность,
    CONVERT( nvarchar, C.[Коэффициент трансформации]) AS [Коэф_трансф],
    FORMAT(C.ГодВыпуска, 'dd.MM.yyyy') AS [Год_выпуска],
    FORMAT(C.ДатаПоверки, 'dd.MM.yyyy') AS [Дата_пред_поверки],
    C.МПИ AS МПИ,
    FORMAT(C.ДатаСледующейПоверки, 'dd.MM.yyyy') AS [Дата_след_поверки],
    C.[Класс точности] AS [Класс_точности],
    C.ТОК AS [Ток_пу],
    C.Фазы AS [Кол_во_фаз_счетчика],
    C.НАПРЯЖЕНИЕ AS [Напр_пу],
    CASE C.[Место установки] 
        WHEN 0  THEN 'На опоре'
	    WHEN 1  THEN 'Лестничная площадка'
	    WHEN 2  THEN 'Квартира'
	    WHEN 3  THEN 'Комната'
	    WHEN 4  THEN 'Жилой дом'
	    WHEN 5  THEN 'Подъезд'
	    WHEN 6  THEN 'Гараж'
	    WHEN 7  THEN 'Сарай'
	    WHEN 8  THEN 'Фасад здания'
	    WHEN 9  THEN 'Тумба в подъезде МЖД'
	    WHEN 10 THEN 'Веранда'
	    WHEN 11 THEN 'ВРУ МКД'
	    WHEN 12 THEN 'РУ ТП'
                ELSE 'Не указано'
    END [Место_установки_ПУ],
    C.НомНомер AS [Номенкл_номер],
    CASE C.АСКУЭ 
        WHEN 0 THEN 'Возможность подключения имеется' 
	    WHEN 1 THEN 'Сбор показаний' 
	    WHEN 2 THEN 'Дистанционное ограничение и отключение' 
    END [АСКУЭ],
    T.СМС,
    T.Автообзвон,
    T.Телефон,
    T.[E_MAIL],
    U.[Наим_УК],
    U.[Ном_Дог_УК],
    C.Примечание AS [Прим_к_месту_ПУ],
    FORMAT(C.[Дата установки], 'dd.MM.yyyy') AS [Дата_посл_пломбы],
    CASE C.[Кто установил]
        WHEN 0 THEN 'Сети'
	    WHEN 1 THEN 'Сбыт'
	    WHEN 2 THEN 'ИКУ'
	    WHEN 3 THEN 'Энергоконтроль'
    END AS [Орг_проверку_пломбы],
    CASE C.[Состояние пломбы] 
        WHEN 0 THEN 'Установлено'  
        WHEN 1 THEN 'Не нарушено'
	    WHEN 2 THEN 'Нарушено'
    END [Сост_пломбы]
FROM #temp_accounts AS LS
LEFT JOIN #temp_counters AS C ON C.Лицевой = LS.Лицевой
LEFT JOIN #temp_phones AS T ON T.Лицевой = LS.Лицевой
LEFT JOIN Адрес AS AD ON AD.row_id = LS.Лицевой
LEFT JOIN УправляющиеКомпании AS U ON U.Лицевой = LS.Лицевой
LEFT JOIN [stack].[Лицевые иерархия] AS LK 
  ON LK.Потомок = LS.Лицевой
     AND LK.РодительТип = 4
LEFT JOIN [stack].[Лицевые счета] AS K ON K.row_id = LK.Родитель
WHERE @ТолькоИстекшие = 0 
   OR C.ИстекСрокПоверки = 1

   UNION ALL

SELECT 
	LS.Номер AS [Номер_ЛС],
	CAST(ODPU.Номер AS VARCHAR(256)) AS [Код_ОДПУ],
	'Нет' AS [Признак_нал_дог],
	CASE SLS.Значение
        WHEN 0 THEN 'Используется'
		WHEN 1 THEN 'Не проживает'
		WHEN 2 THEN 'Закрыт'
	END [Сост_ЛС],
	CASE ISNULL(OPTS.Значение, OPTSH.Значение)
        WHEN 0 THEN 'Многоквартирный'
		WHEN 2 THEN 'Общежитие'
	END [Тип_строения],
    AD.Филиал,
    AD.Участок,
    AD.[Населенный пункт],
    AD.Улица,
    AD.Дом,
    AD.Квартира,
    K.Фамилия AS [Ном_комнаты],
	CR.ФИО,
	CASE ISNULL(US.Значение, 0)	
        WHEN 0 THEN 'Есть'
		WHEN 1 THEN 'Нет'
    END [Возможность_уст_ПУ],
    IIF(NOM.Наименование IS NULL, 'Отсутствует ПУ', 'Индивидуальный') AS [Вид_ПУ],
	FORMAT(SO.ДатНач, 'dd.MM.yyyy') AS[Дата_установки],
	CHOOSE(SS.Состояние, 'Работает', 'Начисляется по среднему', 'не работает') AS [Состояние_ПУ],
    NOM.Наименование AS [Наименование_ПУ],
    SO.ЗаводскойНомер AS [Номер_ПУ],
	SO.Разрядность,
	SO.Тарифность,
	SO.[Коэффициент трансформации] AS [Коэф_трансф],
	FORMAT(SO.ГодВыпуска, 'dd.MM.yyyy') AS [Год_выпуска],
	FORMAT(SO.ДатаПоверки, 'dd.MM.yyyy') AS [Дата_пред_поверки],
	SP.МПИ,
    FORMAT(SO.ДатаСледующейПоверки, 'dd.MM.yyyy') AS [Дата_след_поверки],
	SP.[Класс точности],
	SP.Ток,
	SP.Фазы,
	SP.Напряжение,
    CASE SO.[Место установки] 
        WHEN 0  THEN 'На опоре'
		WHEN 1  THEN 'Лестничная площадка'
		WHEN 2  THEN 'Квартира'
		WHEN 3  THEN 'Комната'
		WHEN 4  THEN 'Жилой дом'
		WHEN 5  THEN 'Подъезд'
		WHEN 6  THEN 'Гараж'
		WHEN 7  THEN 'Сарай'
		WHEN 8  THEN 'Фасад здания'
		WHEN 9  THEN 'Тумба в подъезде МЖД'
		WHEN 10 THEN 'Веранда'
		WHEN 11 THEN 'ВРУ МКД'
		WHEN 12 THEN 'РУ ТП'
		        ELSE 'Не указано'
	END [Место_установки_ПУ],
	NOM.НомНомер AS [Номенкл_номер],
	CASE ASK.Значение
        WHEN 0 THEN 'Возможность подключения имеется' 
		WHEN 1 THEN 'Сбор показаний' 
		WHEN 2 THEN 'Дистанционное ограничение и отключение' 
    END [АСКУЭ], 
	PH.СМС,
    PH.Автообзвон,
    PH.Телефон,
    PH.[E_MAIL],
	ORG.Название AS [Наим_УК],
	CAST(UKDOG_DOM.Номер AS VARCHAR(256)) AS [Ном_Дог_УК],
	SO.Примечание AS [Прим_к_месту_ПУ],
	FORMAT(P.[Дата установки], 'dd.MM.yyyy') AS [Дата_посл_пломбы],
	CASE P.[Кто установил]
        WHEN 0 THEN 'Сети'
		WHEN 1 THEN 'Сбыт'
		WHEN 2 THEN 'ИКУ'
		WHEN 3 THEN 'Энергоконтроль'
	END [Орг_проверку_пломбы],
	CASE P.Состояние
		WHEN 0 THEN 'Установлено'
		WHEN 1 THEN 'Не нарушено'
		WHEN 2 THEN 'Нарушено'
	END [Сост_пломбы]
FROM TNS_Kuban_fl_522.stack.[Лицевые счета] AS LS
JOIN TNS_Kuban_fl_522.stack.[Лицевые иерархия] AS LI ON LI.Потомок = LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Показания счетчиков] AS PS ON LI.Родитель = PS.[Показания-Счет] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Документ] AS ODPU 
  ON ODPU.[ROW_ID] = ps.[Показания-Документ] 
     AND ODPU.[Тип документа] = 77 
     AND PS.Тип = 6 
     AND ODPU.ВидСчета = 0
LEFT JOIN TNS_Kuban_fl_522.stack.[Список объектов] AS SOODPU ON SOODPU.[Объекты-Групповой] = ODPU.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства AS SLS 
 ON SLS.[Счет-Параметры] = LS.ROW_ID
	 AND SLS.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'СОСТОЯНИЕ')
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTS 
  ON OPTS.[Счет-Параметры] = LS.ROW_ID 
	 AND OPTS.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'ТИПСТРОЙ')
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTSH 
  ON OPTSH.[Счет-Параметры] = LI.Родитель 
	 AND OPTSH.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'ТИПСТРОЙ')
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства TU 
  ON TU.[Счет-Параметры] = LS.ROW_ID 
	AND OPTSH.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'ЮРЛИЦО')
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Свойства] US 
  ON US.[Счет-Параметры]=LS.ROW_ID 
	 AND US.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'НТВ_ИСЧ_ЭЛ')
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Карточки регистрации] CR ON CR.[Счет-Наниматель] = LS.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Список объектов] SO ON SO.[Объекты-Счет] = LS.ROW_ID 
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Состояние счетчика] SS ON SS.[Счет-Счетчика состояние] = SO.[Объекты-Счет] 
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Номенклатура] NOM ON SO.[Номенклатура-Объекты]=nom.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Свойства] AS ASK 
  ON ASK.[Объекты-Параметры] = SO.ROW_ID
	 AND ASK.[Виды-Параметры] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[Виды параметров] WHERE Название = 'АСКУЭ')
LEFT JOIN (
    SELECT 
        Номенклатура,
        [60] AS МПИ,
        [23] AS [Класс точности], 
        [28] AS Напряжение,
        [27] AS Ток,
        [24] AS Фазы
    FROM (            
	    SELECT 
            [ном-параметры] AS Номенклатура,
            [Параметр-Значения] AS Параметр, 
            Значение
        FROM [TNS_Kuban_fl_522].[stack].[значения параметров]
        WHERE [Параметр-Значения] IN (23, 24, 27, 28, 60)
    ) AS T
    PIVOT ( 
        MAX(Значение) FOR Параметр IN ([28], [27], [24], [60], [23])
    ) AS PVT
) AS SP ON SP.Номенклатура = NOM.row_id
LEFT JOIN (
     SELECT 
        PVT.[Потомок] AS row_id,  
        PVT.[0] AS [Филиал],
        PVT.[1] AS [Участок],
        PVT.[12] AS [Населенный пункт], 
        PVT.[2] AS [Улица], 
        PVT.[3] AS [Дом],
        PVT.[4] AS [Квартира]
	FROM (
        SELECT
			LI.Потомок,
			LI.РодительТип,
			CASE WHEN LI.РодительТип = 0        THEN L.Фамилия
				 WHEN LI.РодительТип = 1        THEN O.Название
				 WHEN LI.РодительТип IN (12, 2) THEN IIF(C.До_После = 1, CONCAT(C.Название, ' ', C.Сокращение), CONCAT(C.Сокращение, ' ', C.Название))
				 WHEN LI.РодительТип IN (3, 4)  THEN CAST(L.Номер AS NVARCHAR(12)) 
			END AS Адрес
	    FROM [TNS_Kuban_fl_522].[stack].[Лицевые иерархия] AS LI
	    JOIN [TNS_Kuban_fl_522].[stack].[Лицевые счета] AS L ON LI.Родитель = L.row_id
	    LEFT JOIN [TNS_Kuban_fl_522].[stack].[Города] AS C ON L.[Улица-Лицевой счет] = C.row_id
	    LEFT JOIN [TNS_Kuban_fl_522].[stack].[Организации] AS O ON O.row_id = L.[Счет-Линейный участок]
	    WHERE LI.ПотомокТип = 5 AND РодительТип IN (0, 1, 12, 2, 3, 4)
	) AS T
	PIVOT
	(
		MAX(Адрес) FOR РодительТип IN([0], [1], [12], [2], [3], [4])
	) AS PVT
) AS AD ON AD.ROW_ID = LS.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Лицевые иерархия] AS LK 
  ON LK.Потомок = LS.row_id
     AND LK.РодительТип = 4
LEFT JOIN [TNS_Kuban_fl_522].[stack].[Лицевые счета] AS K ON K.row_id = LK.Родитель
LEFT JOIN (
    SELECT 
        T.[Счет-Телефон],
        [stack].[CLR_Concat](DISTINCT IIF(T.Флаги = 1, T.Номер, NULL)) AS [Телефон],
        [stack].[CLR_Concat](DISTINCT IIF(T.Флаги = 2, T.Номер, NULL)) AS [Смс],
        [stack].[CLR_Concat](DISTINCT IIF(T.Флаги = 3, T.Номер, NULL)) AS [Автообзвон],
        [stack].[CLR_Concat](DISTINCT IIF(T.Флаги = 4, T.Номер, NULL)) AS [E_MAIL]
    FROM (
        SELECT
            T.[Счет-Телефон],
            T.Флаги,
            T.Номер
        FROM TNS_Kuban_fl_522.[stack].[Телефоны] AS T
        WHERE T.Флаги IN (1, 2, 3, 4)
    ) AS T
    GROUP BY T.[Счет-Телефон]
) AS PH ON PH.[Счет-Телефон] = LS.row_id 
LEFT JOIN TNS_Kuban_fl_522.stack.[Управляющие компании] AS UK_DOM ON UK_DOM.[Счет-УК] = LI.Родитель 
LEFT JOIN TNS_Kuban_fl_522.stack.[УК Договоры] AS UKDOG_DOM	ON UKDOG_DOM.ROW_ID = UK_DOM.[Дом-УКДоговор] 
LEFT JOIN TNS_Kuban_fl_522.stack.Организации AS ORG ON UK_DOM.[Организация-УК] = ORG.ROW_ID
OUTER APPLY(
    SELECT TOP (1)
        [Дата установки],
        [Кто установил],
        Состояние
	FROM TNS_Kuban_fl_522.stack.[Пломбы]
	WHERE [Пломба-Объект] = SO.ROW_ID 
	ORDER BY [Дата установки] DESC
) AS P 
WHERE LI.ПотомокТип = 5  AND LI.РодительТип=3
 AND (@ТолькоИстекшие = 0
    OR (SO.ROW_ID IS NOT NULL AND @Дата  >= DATEADD (year, CAST(SP.МПИ AS int), SO.ДатаПоверки))
 );