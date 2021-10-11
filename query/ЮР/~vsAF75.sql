DECLARE @Дата  DATE = '20210527';
IF OBJECT_ID(N'tempdb..#address', N'U') IS NOT NULL
      DROP TABLE #address
CREATE TABLE #address(
	Договор		NVARCHAR(256),
	Лицевой		BIGINT,
	АдресСтрока NVARCHAR(MAX),
	Страна		NVARCHAR(256),
	Индекс		INT,
	Узел_1		NVARCHAR(128),
	Область		NVARCHAR(128),
	Флаг_1		INT,
	Узел_2		NVARCHAR(128),
	Район		NVARCHAR(128),
	Флаг_2		NVARCHAR(128),
	Узел_3		NVARCHAR(128),
	Город		NVARCHAR(128),
	Флаг_3		INT,
	Узел_4		NVARCHAR(128),
	насПункт	NVARCHAR(128),
	Флаг_4		INT,
	Узел_5		NVARCHAR(128),
	Улица		NVARCHAR(128),
	Флаг_5		INT,
	Узел_6		NVARCHAR(64),
	Узел_7		NVARCHAR(64),
	Узел_8		NVARCHAR(64),
	Узел_9		NVARCHAR(64)
);
WITH raw AS (
	SELECT 
		L.row_id,
		L.Номер AS Лицевой,
		D.Номер AS Договор,
		L.АдресЛС AS АдресСтрока,
		CAST(A.Адрес AS nvarchar(MAX)) AS АдресXML,
		ISNULL(X.Узел.value('.', 'nvarchar(max)'), '') Элемент,
		X.Узел.value('for $i in . return count(../*[. << $i]) + 1', 'int') AS Очередность
	FROM [stack].[Лицевые счета] AS L
	JOIN stack.[Лицевые договора] AS LD ON LD.Лицевой=L.ROW_ID AND @Дата BETWEEN LD.ДатНач AND LD.ДатКнц
	JOIN stack.Договор AS D ON LD.Договор=D.ROW_ID 
	CROSS APPLY (VALUES(
		RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L.АдресЛС, ' ', '<>'), '><', ''), '<>', ' '), ' ,', ','), ', ', ',')))
	)) AS E(Адрес)
	CROSS APPLY (VALUES(CAST(CONCAT('<H>', REPLACE(E.Адрес, ',', '</H><H>'), '</H>') AS XML))) AS A(Адрес)
	CROSS APPLY A.Адрес.nodes('H') AS X(Узел)
	WHERE  D.[Категория-Договоры] IN (252,253.254) AND @Дата BETWEEN D.[Начало договора] AND ISNULL(D.Окончание,'20450509') 
), Details AS (
	SELECT
		row_id,
		Лицевой,
		Договор,
		АдресСтрока,
		АдресXML,
		MAX(IIF(V.Страна IS NOT NULL, Элемент, NULL)) OVER (PARTITION BY row_id) AS Страна,
		MAX(IIF(V.Индекс IS NOT NULL, Элемент, NULL)) OVER (PARTITION BY row_id) AS Индекс,
		IIF(Очередность IN (MAX(V.Страна) OVER (PARTITION BY row_id), MAX(V.Индекс) OVER (PARTITION BY row_id)), NULL, Элемент) AS Элемент,
		Очередность
	FROM raw
	CROSS APPLY (VALUES(
		IIF(Очередность IN (1, 2) AND LEN(Элемент) > 3 AND TRY_CAST(Элемент AS INT) IS NOT NULL,                Очередность, NULL),
		IIF(Очередность IN (1, 2) AND RTRIM(LTRIM(LOWER(Элемент))) IN ('рф', 'российская федерация', 'россия'), Очередность, NULL)
	)) AS V(Индекс, Страна)
), КрайОбласть AS 
(
	SELECT (Obl.Название + ' ' + obl.Сокращение) AS Край,
			Obl.ROW_ID
	FROM stack.Города AS Obl
	WHERE Obl.ROW_ID IN (163,261351) AND Obl.Тип=1
)
, Район AS
(
	SELECT (ISNULL(RN.Название, '') + ' ' + ISNULL(RN.Сокращение,'')) AS Район,
			RN.Тип			
	FROM КрайОбласть AS K
	JOIN stack.Города AS RN ON RN.Города=K.ROW_ID
)
--если район есть, то у города ссылка на район
, Город AS
(
	SELECT (ISNULL(Gor.Название, '') + ' ' + ISNULL(Gor.Сокращение,'')) AS Город,
			Gor.Тип
	FROM КрайОбласть AS K
	JOIN stack.Города AS RN ON RN.Города=K.ROW_ID
	JOIN stack.Города AS Gor ON Gor.Города=RN.ROW_ID
)
--если есть район и город
,НасПункт AS
(
	SELECT (ISNULL(NP.Название, '') + ' ' + ISNULL(NP.Сокращение,'')) AS НасПункт,
			NP.Тип
	FROM КрайОбласть AS K
	JOIN stack.Города AS RN ON RN.Города=K.ROW_ID
	JOIN stack.Города AS Gor ON Gor.Города=RN.ROW_ID
	JOIN stack.Города AS NP ON NP.Города=Gor.ROW_ID
)
,Улица AS
(
	SELECT (ISNULL(UL.Название, '') + ' ' + ISNULL(UL.Сокращение,'')) AS Улица,
			UL.Тип
	FROM КрайОбласть AS K
	JOIN stack.Города AS RN ON RN.Города=K.ROW_ID
	JOIN stack.Города AS Gor ON Gor.Города=RN.ROW_ID
	JOIN stack.Города AS NP ON NP.Города=Gor.ROW_ID
	JOIN stack.Города AS UL ON UL.Города=NP.ROW_ID
)
INSERT INTO #address(Договор,
					 Лицевой, 
					 АдресСтрока, 
					 Страна, 
					 Индекс, 
					 Узел_1, 
					 Область, 
					 Флаг_1, 
					 Узел_2, 
					 Район, 
					 Флаг_2, 
					 Узел_3,
					 Город, 
					 Флаг_3,
					 Узел_4, 
					 насПункт, 
					 Флаг_4, 
					 Узел_5, 
					 Улица, 
					 Флаг_5, 
					 Узел_6, 
					 Узел_7, 
					 Узел_8, 
					 Узел_9)
SELECT	DISTINCT
		pvt.Договор,
		pvt.Лицевой,
		pvt.АдресСтрока,
		pvt.Страна,
		pvt.Индекс,
		pvt.[1],
		K.Край,
		
		pvt.[2],
		ISNULL(R.Район,'') AS Район, --край-район
		
		pvt.[3],
		CASE
			WHEN pvt.[2]='' AND pvt.[1]=K.Край THEN ISNULL(G.Район,'')  --город без уровня района
			WHEN pvt.[2]=R.Район 			   THEN ISNULL(RG.Город,'') --город в районе
		END AS Город,

		pvt.[4],
		CASE		
			WHEN pvt.[1]=K.Край AND pvt.[2]=R.Район AND pvt.[3]=RG.Город AND pvt.[3]!='' THEN ISNULL(RGNP.НасПункт,'')	--область-район-город-наспункт
			WHEN pvt.[1]=K.Край AND	pvt.[2]=R.Район AND pvt.[3]=''						 THEN NP.Город		--область-район-наспункт
			WHEN pvt.[1]=K.Край AND pvt.[2]='' AND pvt.[3]!=''   						 THEN ISNULL(KGNP.Город,'')	--область-город-наспункт
		END AS НасПункт,

		pvt.[5],
		CASE
			WHEN  pvt.[1]=K.Край AND ((pvt.[2]='' AND pvt.[3]!='') OR (pvt.[2]!='' AND pvt.[3]='') AND pvt.[4]='')  THEN OGU.Город
			WHEN  pvt.[1]=K.Край AND ((pvt.[2]!='' AND pvt.[3]!='') AND pvt.[4]='')									THEN OGNPU.НасПункт
			WHEN  pvt.[1]=K.Край AND ((pvt.[2]='' AND pvt.[3]!='') OR (pvt.[2]!='' AND pvt.[3]='') AND pvt.[4]!='') THEN OGNPU.НасПункт
			WHEN  pvt.[1]=K.Край AND pvt.[2]=R.Район AND pvt.[3]=RG.Город AND pvt.[4]=RGNP.НасПункт					THEN UL.Улица
		END AS Улица,

		pvt.[6],
		pvt.[7],
		pvt.[8],
		pvt.[9]
FROM (
	SELECT 
		row_id,
		Лицевой,
		Договор,
		АдресСтрока,
		АдресXML,
		Страна,
		Индекс,
		Элемент,
		ROW_NUMBER() OVER (PARTITION BY row_id ORDER BY Очередность) AS Очередность
	FROM Details
	WHERE Элемент IS NOT NULL
) AS T
PIVOT 
( 
	MAX(T.Элемент) FOR T.Очередность IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
) AS pvt
LEFT JOIN КрайОбласть AS K ON K.Край=pvt.[1]
LEFT JOIN Район AS R	   ON R.Район=pvt.[2]		  AND R.Тип=3--район
LEFT JOIN Район AS G	   ON G.Район=pvt.[3]		  AND G.Тип=4--города не в районах
LEFT JOIN Город AS RG	   ON RG.Город=pvt.[3]		  AND RG.Тип=4--город внутри района
LEFT JOIN Город AS NP	   ON NP.Город=pvt.[4]		  AND NP.Тип=6--наспункт внутри района
LEFT JOIN Город AS KGNP	   ON KGNP.Город=pvt.[4]	  AND KGNP.Тип=6 -- нас пункт внутри района без города
LEFT JOIN НасПункт AS RGNP ON RGNP.НасПункт=pvt.[4]	  AND RGNP.Тип=6 --населенный пункт внутри города 
LEFT JOIN Город AS OGU ON OGU.Город=pvt.[5]			  AND OGU.Тип=7 --область-город-улица
LEFT JOIN НасПункт AS OGNPU ON OGNPU.НасПункт=pvt.[5] AND OGNPU.Тип=7--область-город-наспункт-улица или область-район-город-улица
LEFT JOIN Улица	As UL ON UL.Улица=pvt.[5]			  AND UL.Тип=7 --область-район-город-наспункт-улица
--область-район-улица
--область-район-наспункт-улица

SELECT  Договор,
		Лицевой, 
		АдресСтрока, 
		Страна,
		Индекс, 
		Узел_1,
		CASE
			WHEN ISNULL(pvt.[1], '')!=ISNULL(K.Край,'') THEN 0 --несопоставлен
			WHEN pvt.[1]=K.Край							THEN 1 --сопоставлено
		END AS ФлагКрай,
		CASE
			WHEN ISNULL(pvt.[2], '')!=ISNULL(R.Район, '') THEN 0 --несопоставлено
			WHEN pvt.[2]=R.Район AND pvt.[2] != ''		  THEN 1 --сопоставлено, есть значение
			WHEN pvt.[2]='' AND ISNULL(R.Район,'')='' AND  pvt.[2]=ISNULL(R.Район,'') AND pvt.[1]=K.Край THEN 2 --сопоставлено, уровень ниже
			ELSE 0
		END AS ФлагРайон,
				CASE
			WHEN ISNULL(G.Район,'')!=ISNULL(pvt.[3],'') AND ISNULL(RG.Город,'')!=ISNULL(pvt.[3],'')	THEN 0 --несопоставлено
			WHEN ((G.Район=pvt.[3]) OR (RG.Город=pvt.[3])) AND pvt.[1]=K.Край						THEN 1--сопоставлен
			WHEN ISNULL(RG.Город,'')=ISNULL(pvt.[3],'') AND pvt.[1]=K.Край AND pvt.[2]=R.Район		THEN 2--сопоставлен, уровень ниже(есть район-нет города)
			ELSE 0
		END AS ФлагГород,
				CASE
			WHEN (ISNULL(NP.Город,'')!=ISNULL(pvt.[4],'')) AND (ISNULL(RGNP.НасПункт,'')!=ISNULL(pvt.[4],'')) AND (ISNULL(KGNP.Город,'')!=ISNULL(pvt.[4],'')) THEN 0 --нет соответствия
			WHEN NP.Город=pvt.[4] OR RGNP.НасПункт=pvt.[4] OR KGNP.Город=pvt.[4] THEN 1
			WHEN pvt.[4]='' AND (pvt.[4]=ISNULL(RGNP.НасПункт,'') OR pvt.[4]=ISNULL(KGNP.Город,'') OR pvt.[4]=ISNULL(NP.Город,'')) THEN 2
		ELSE 0
			CASE
			--WHEN 
			WHEN OGU.Город=pvt.[5] OR OGNPU.НасПункт=pvt.[5] OR UL.Улица=pvt.[5] THEN 1
			ELSE 0
		END AS ФлагУлица,
		END AS ФлагНп,
		(ISNULL(CAST(Индекс as nvarchar),'')+', '
		+(ISNULL(Узел_1,'')
		+', '+ISNULL(Узел_2,'')
		+', '+ISNULL(Узел_3,'')
		+', '+ISNULL(Узел_4,'')
		+', '+ISNULL(Узел_5,'')
		+', '+ISNULL(Узел_6,'')
		+', '+ISNULL(Узел_7,'')
		+', '+ISNULL(Узел_8,'')
		+', '+ISNULL(Узел_9,''))) AS АдресЛС
FROM #address AS A
WHERE Узел_1!='Краснодарский край' AND Узел_1!='Адыгея Респ' 
--OR  Узел_1 NOT LIKE ' Адыгея Респ'
--WHERE Флаг_1!=0 AND Флаг_2!=0 AND Флаг_3!=0 AND Флаг_4!=0 AND Флаг_5!=0 
--WHERE Узел_1 LIKE 'Респ.%'
--Флаг_1=1 AND Флаг_2!=0 AND Флаг_3!=0 AND Флаг_4!=0
--AND Флаг_2 IN (1,2) AND Флаг_3=0 AND Флаг_4=0 AND Флаг_5=0 
--Флаг_2 IN (1,2) AND Флаг_3 IN (1,2) AND Флаг_4 IN (1,2) AND Флаг_5=1 AND Страна IS NULL

--WHERE pvt.[2]='' OR (pvt.[2]=R.Район AND pvt.[2] != '')
--LEFT JOIN НасПункт AS N ON N.НасПункт=pvt.[4]
--LEFT JOIN Улица AS U ON U.Улица=pvt.[5]


--SELECT RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(' a  b s   u  ', ' ', '<>'), '><', ''), '<>', ' ')))


--WITH Cities AS (
--	SELECT 
--		row_id,
--		CONCAT('//', CAST(Название AS NVARCHAR(MAX))) AS Путь,
--		1 AS Уровень
--	FROM [stack].[Города]
--	WHERE ROW_ID = 1

--		UNION ALL

--	SELECT 
--		C.row_id,
--		CONCAT(P.Путь, '/', C.Название) AS Путь,
--		P.Уровень + 1
--	FROM Cities AS P
--	JOIN [stack].[Города] AS C ON C.Города = P.row_id
--)
--SELECT * 
--FROM Cities