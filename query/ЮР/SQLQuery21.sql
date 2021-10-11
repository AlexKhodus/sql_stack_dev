IF 0 = 1

BEGIN
	DROP TABLE IF EXISTS #addresses;

	CREATE TABLE #addresses (
		[row_id]         [int]           NOT NULL,
		[Лицевой]        [bigint]        NOT NULL,
		[Договор]        [varchar](256)  NOT NULL,
		[АдресСтрока]    [varchar](256)  NULL,
		[АдресXML]       [nvarchar](max) NULL,
		[Страна]         [nvarchar](max) NULL,
		[Индекс]         [nvarchar](max) NULL,
		[Элемент]        [nvarchar](max) NULL,
		[Очередность]    [int]           NULL,
		[Города]         [int]           NULL,
		[Города_Уровень] [int]           NULL   
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
		JOIN stack.[Лицевые договора] AS LD ON LD.Лицевой=L.ROW_ID AND CAST(GETDATE() AS DATE) BETWEEN LD.ДатНач AND LD.ДатКнц
		JOIN stack.Договор AS D ON LD.Договор=D.ROW_ID 
		CROSS APPLY (VALUES(CAST(CONCAT('<H>', REPLACE(L.АдресЛС, ',', '</H><H>'), '</H>') AS XML))) AS A(Адрес)
		CROSS APPLY A.Адрес.nodes('H') AS X(Узел)
		WHERE D.[Категория-Договоры] IN (252,253.254) AND CAST(GETDATE() AS DATE) BETWEEN D.[Начало договора] AND ISNULL(D.Окончание,'20450509') 
		  AND D.Номер IN (23060401282, 23060501288, 23110601049, 23010201291)
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
	)
	INSERT INTO #addresses ([row_id], [Лицевой], [Договор], [АдресСтрока], [АдресXML], [Страна], [Индекс], [Элемент],[Очередность], [Города], [Города_Уровень])
	SELECT *
	FROM (
		SELECT
			[row_id],
			[Лицевой],
			[Договор],
			[АдресСтрока],
			[АдресXML],
			[Страна],
			[Индекс],
			[Элемент],
			[Очередность],
			NULL AS Города,
			NULL AS Города_Уровень
		FROM Details

			UNION ALL

		SELECT DISTINCT
			[row_id],
			[Лицевой],
			[Договор],
			[АдресСтрока],
			[АдресXML],
			[Страна],
			[Индекс],
			'РФ',
			0,
			1303592,
			1
		FROM Details
	) AS T;
END

DECLARE @level INT = 1,
		@limit INT = 3 -- (SELECT MAX(Очередность) FROM #addresses);

WHILE @level <= @limit
BEGIN
	WITH Элементы AS (
		SELECT 
			A.row_id,
			A.Лицевой,
			A.Элемент,
			A.Города,
			R.Города AS Корень,
			R.Города_уровень
		FROM #addresses AS A
		CROSS APPLY (
			SELECT TOP(1) 
				Города,
				Города_уровень
			FROM #addresses
			WHERE row_id = A.row_id
			  AND Города IS NOT NULL
			ORDER BY Очередность DESC
		) AS R
		WHERE A.Очередность = @level
	), Сопоставление AS (
		SELECT 
			row_id AS Счет,
			Корень AS row_id,
			CAST(NULL AS VARCHAR(256)) AS Название,
			0 AS Уровень
		FROM Элементы 

			UNION ALL 

		SELECT 
			P.Счет,
			C.row_id,
			C.Название,
			P.Уровень + 1
		FROM Сопоставление AS P
		JOIN [stack].[Города] AS C ON C.Города = P.row_id
		WHERE P.Уровень <= 1
	) 
	--SELECT *
	--FROM #addresses AS A
	--LEFT JOIN Сопоставление AS S ON S.Счет=A.row_id
	
	SELECT * 
	FROM Сопоставление

	SET @level = @level + 1;
	
END
--SELECT  *
--FROM (	SELECT A.row_id, 
--			   A.Лицевой,
--			   A.Договор, 
--			   A.АдресXML,
--			   A.АдресСтрока,
--			   A.Страна,
--			   A.Индекс,
--			   A.Элемент,
--			   A.Очередность,  
--			   A.Города, 
--			   A.Города_Уровень 
--		FROM #addresses AS A) AS A
--PIVOT 
--( 
--	MAX(A.Элемент) FOR A.Очередность IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
--) AS pvt

--WHERE Элемент IS NOT NULL AND Элемент!=''


