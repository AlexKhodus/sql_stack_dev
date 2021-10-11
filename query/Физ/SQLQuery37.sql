DECLARE @Дата      DATE = '20200720'


IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
   DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    [Номер_дог] VARCHAR(256),
    [Имя_потр]  VARCHAR(256),
	[Телефон]   VARCHAR(256),
    [Ном_ТУ]    INT,
	[Имя_ТУ]    VARCHAR(256),
	[Лицевой]	INT
);
WITH 
ТУ AS( 
SELECT	
		  DOG.Номер AS [Ном_дог]
		, O.Наименование AS [Имя_потр]
		, O.Телефон
		, LS.Номер AS [Ном_ТУ]
		, LS.Примечание AS [Имя_ТУ]
		, LS.ROW_ID As Лицевой
FROM	stack.[Договор] AS DOG
JOIN stack.Организации AS O
	ON O.ROW_ID=DOG.Плательщик
JOIN stack.[Лицевые договора] AS LD
	ON LD.Договор=DOG.ROW_ID
JOIN stack.[Лицевые счета] AS LS
	ON LS.ROW_ID=LD.Лицевой
	  --AND ISNULL(NOM.Идентификатор, 0) = 0
)
INSERT INTO #temp_accounts (
    [Номер_дог],
    [Имя_потр] ,
	[Телефон]  ,
    [Ном_ТУ]   ,
	[Имя_ТУ]   ,
	[Лицевой]  
)
SELECT *
FROM  ТУ
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
    '' [Код_ОДПУ]
	,LS.Номер_дог
	,'' [Ном_ЭСО]
	,LS.Имя_потр
	,LS.Телефон
	,LS.Ном_ТУ
	,LS.Имя_ТУ
FROM #temp_accounts AS LS

Where	LS.Лицевой = 8221
