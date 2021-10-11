DECLARE @date datetime='20200301';
WITH
S
AS(
SELECT		NS.Счет AS Потомок,
			(SELECT 
					ISNULL(SUM(NS.Сумма), 0), 
					NS.Счет
			FROM stack.НСальдо AS NS
			WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) 
			AND (NS.[Номер услуги] BETWEEN 100 AND 199)
			GROUP BY NS.Счет
			) AS s100,			
			(SELECT 
					ISNULL(SUM(NS.Сумма),0),
					NS.Счет
			FROM stack.НСальдо AS NS
			WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date)
			AND (NS.[Номер услуги] BETWEEN 400 AND 499)
			GROUP BY NS.Счет
			) AS s400 
			--(s100+s400) AS [Сальдо на начало месяца 100,400]	
FROM stack.НСальдо AS NS
)
SELECT S.s100, s400
FROM stack.[Лицевые счета] AS LS
LEFT JOIN S ON S.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=164180



SELECT 		NT.Счет
					, NT.[Номер услуги]
					, NT.Сумма
				FROM stack.НТариф AS NT
				WHERE NT.Счет IN (164171) AND NT.[Месяц расчета]=@date
		UNION
				(SELECT NS.Счет
					 , NS.[Номер услуги]
					 , SUM(NS.Сумма) AS Summa
				FROM stack.НСальдо AS NS
				WHERE NS.Счет IN (164171) AND NS.[Месяц расчета]=DATEADD(mm, -1, @date) AND NS.[Номер услуги]  BETWEEN 100 AND 199
				GROUP BY NS.Счет, NS.[Номер услуги])
		UNION
				SELECT VS.Счет
					 , VS.[Номер услуги]
					 , SUM(VS.Сумма) AS Summa
				FROM stack.НСальдо AS VS
				WHERE VS.Счет IN (164171) AND VS.[Месяц расчета]=DATEADD(mm, -1, @date)
				GROUP BY VS.Счет, VS.[Номер услуги]



DECLARE @date datetime='20200301';
			SELECT SUM(S.Summa) AS [Сальдо на начало месяца 100,400],
					S.Счет
			FROM(
						  SELECT NS.Счет
								 , SUM(NS.Сумма) AS Summa
							FROM stack.НСальдо AS NS
							WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) AND NS.[Номер услуги]  BETWEEN 100 AND 199
							GROUP BY NS.Счет, NS.[Номер услуги]
						UNION
							SELECT VS.Счет
								 , SUM(VS.Сумма) AS Summa
							FROM stack.НСальдо AS VS
							WHERE   VS.[Месяц расчета]=DATEADD(mm, -1, @date) AND VS.[Номер услуги]  BETWEEN 400 AND 499
							GROUP BY VS.Счет, VS.[Номер услуги]) AS S
LEFT JOIN stack.[Лицевые счета] AS LS
ON LS.ROW_ID=S.Счет
WHERE LS.ROW_ID=164180
GROUP BY S.Счет


SELECT *
FROM stack.Номенклатура AS NOM
WHERE NOM.ROW_ID=8378
DECLARE @date datetime='20200301';	
			SELECT	LI.Потомок
			,T.Значение
			,[stack].[CLR_Concat](ISNULL(TU.[Номер услуги],TUD.[Номер услуги])) AS [Номер услуги]
			,[stack].[CLR_Concat](ISNULL(TU.Наименование,TUD.Наименование)) AS [Тип домохозяйства]
			FROM stack.[Лицевые иерархия] AS LI
--для ЛС
			LEFT JOIN stack.[Список услуг] AS SU
				ON SU.[Счет-Услуги]=LI.Потомок 
			LEFT JOIN stack.[Типы услуг] AS TU
				ON TU.ROW_ID=SU.[Вид-Услуги]
--для дома
			LEFT JOIN stack.[Список услуг] AS SUD
				ON SUD.[Счет-Услуги]=LI.Родитель 
			LEFT JOIN stack.[Типы услуг] AS TUD
				ON TUD.ROW_ID=SUD.[Вид-Услуги]
			LEFT JOIN 	stack.[Тарифы] AS T
			ON TU.ROW_ID=T.[Вид-Тарифы] OR TUD.ROW_ID=T.[Вид-Тарифы]
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5 AND LI.Потомок=164180 AND T.ДатНач=(
			SELECT TOP 1 T.ДатНач
			FROM stack.[Тарифы] AS T			
			WHERE T.[Вид-Тарифы]=TUD.ROW_ID OR TU.ROW_ID=T.[Вид-Тарифы]
			ORDER BY T.ДатНач DESC)
			GROUP BY LI.Потомок, T.Значение
--LEFT JOIN 	stack.[Тарифы] AS T
--LEFT JOIN stack.[Типы услуг] AS TU
--ON TU.ROW_ID=T.[Вид-Тарифы]
--Where	ROW_ID = 1978

SELECT	*
FROM	stack.[Тарифа детализация]
Where	ROW_ID = -1

SELECT	*
FROM	stack.[Показания счетчиков]
Where	ROW_ID = 424958277

SELECT	*
FROM	stack.[Показания счетчиков]
Where	ROW_ID = 424160190



SELECT	*
FROM	stack.[Типы услуг]
Where	ROW_ID = 1517

SELECT TOP 1 *--PS.Расход
		--,TU.Наименование
FROM	stack.[Показания счетчиков] AS PS
LEFT JOIN stack.[Список объектов] AS SO
ON SO.ROW_ID=PS.[Объект-Показания]
LEFT JOIN stack.[Типы услуг] AS TU
ON TU.ROW_ID=PS.[Показания-Услуга]
WHERE  SO.ROW_ID=426208016
		--TU.ROW_ID=14
		SELECT	*
FROM	stack.[Показания счетчиков]
Where	ROW_ID = 426208016
 
 
 SELECT TOP 1 TU.Наименование
 FROM stack.[Показания счетчиков] AS PS
 LEFT JOIN stack.[Типы услуг] AS TU
 ON TU.ROW_ID=PS.[Показания-Услуга]
 WHERE [Показания-Счет]=164180 and PS.[Показания-Услуга]=1517
 ORDER BY PS.Дата DESC
 WITH D
 AS(
SELECT TOP 1 PS.Расход,
			PS.[Показания-Счет] AS Потомок
FROM stack.[Показания счетчиков] AS PS
--JOIN stack.[Лицевые счета] AS LS
--ON LS.ROW_ID=PS.[Показания-Счет]
JOIN stack.[Типы услуг] AS TU
 ON TU.ROW_ID=PS.[Показания-Услуга]
LEFT JOIN stack.Документ AS DOC
ON DOC.ROW_ID=PS.[Показания-Документ]
WHERE DOC.[Тип документа]=77
AND PS.[Показания-Счет]=164180
ORDER BY PS.Дата DESC
)
SELECT D.Расход
FROM  stack.[Лицевые счета] AS LS
LEFT JOIN D ON D.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=164180



 SELECT *
 FROM stack.Документ
 WHERE stack.Документ.ROW_ID=6379


SELECT	*
FROM	stack.[Акты нарушений]
Where	ROW_ID = -1

DECLARE @date datetime='20191001';
WITH
V AS(
SELECT RA.[Счет-Расчет акта] AS Потомок
		,SUM(RA.ОбъемАкта) AS [объем по акту БУ]
		,SUM(RA.СуммаАкта) AS [Стоимость по Акту БУ]
FROM	stack.[Расчет акта] AS RA
Where	 @date=RA.Месяц 
--AND RA.[Счет-Расчет акта]=150403
GROUP BY RA.[Счет-Расчет акта]
)
SELECT V.[объем по акту БУ],
		V.[Стоимость по Акту БУ]
FROM  stack.[Лицевые счета] AS LS
LEFT JOIN V ON V.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=150403

SELECT	*
FROM	stack.[Расчет акта]
Where	ROW_ID = 603804

DECLARE @date datetime='20191001';
			SELECT  LI.Потомок,
					ISNULL(ORG.Название,ORG_D.Название) AS [Наименование поставщика]
			FROM 
				 stack.[Лицевые иерархия] AS LI
--для ЛС
			JOIN stack.Поставщики AS POS
			ON POS.[Счет-Список поставщиков]=LI.Потомок
			JOIN stack.Организации AS ORG
			ON ORG.ROW_ID=POS.[Поставщики-Список]
--для дома
			JOIN stack.Поставщики AS POS_D
			ON POS_D.[Счет-Список поставщиков]=LI.Родитель
			JOIN stack.Организации AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[Поставщики-Список]
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5 AND (@date BETWEEN POS.ДатНач AND POS.ДатКнц OR @date BETWEEN POS_D.ДатНач AND POS_D.ДатКнц)


SELECT	LS.ROW_ID
FROM stack.[Лицевые счета] AS LS
LEFT JOIN stack.[Поставщики] AS POS
ON POS.[Счет-Список поставщиков]=LS.ROW_ID
Where	POS.ROW_ID IS NULL

SELECT	*
FROM	stack.[Показания счетчиков]
Where	ROW_ID = 8262034

SELECT *
FROM stack.Документ AS Doc
WHERE Doc.ROW_ID=6379


			SELECT TOP 1 SO.Дата AS [дата последней оплаты]
			,SO.[Счет-Оплата] AS Потомок
			FROM stack.[Список оплаты] AS SO
			JOIN stack.[Лицевые счета] AS LS
			ON LS.ROW_ID=SO.[Счет-Оплата]
			WHERE LS.ROW_ID=164180
			ORDER BY  SO.Дата DESC

WITH F
AS(
			Select DOC.ROW_ID,
					SO.[Объекты-Счет] AS Потомок
			FROM stack.[Список объектов] AS SO
			LEFT JOIN stack.Документ AS DOC
			ON DOC.ROW_ID=SO.[Объекты-Групповой]
			WHERE SO.ROW_ID=3443664
)
SELECT 
		CASE
			WHEN F.ROW_ID IS NULL THEN 'Нет'
			WHEN F.ROW_ID IS NOT NULL THEN 'Да'
		END AS [Наличие ОДПУ 1 - да, 0 - нет]
FROM stack.[Лицевые счета] AS LS
LEFT JOIN F ON F.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=134829

		DECLARE @date datetime='20191001';
		SELECT RA.[Счет-Расчет акта] AS Потомок
			,RA.ОбъемАкта AS [объем по акту БУ]
			,SUM(RA.СуммаАкта) AS [Стоимость по Акту БУ]
		FROM	stack.[Расчет акта] AS RA
		Where	RA.Месяц='20191001' AND RA.[Счет-Расчет акта]=150403
		GROUP BY RA.[Счет-Расчет акта], RA.ОбъемАкта


		SELECT *
		FROM stack.[Типы услуг] AS TU
		WHERE TU.Наименование='Безучетное потребление'
		

		SELECT *
		FROM stack.[Лицевые счета] AS LS
		LEFT JOIN stack.[Расчет акта] AS RA ON
		RA.[Счет-Расчет акта]=LS.ROW_ID
		WHERE LS.ROW_ID
	--безучетноепотребление через начисления
		SELECT SUM(NT.Сумма) [Стоимость по Акту БУ],
			   NT.Счет AS Потомок
		FROM stack.НТариф AS NT
		WHERE NT.[Номер услуги]=(
		SELECT TOP 1 TU.[Номер услуги]
		FROM stack.[Типы услуг] AS TU
		WHERE TU.Наименование='Безучетное потребление'
		) AND NT.[Месяц расчета]='20191001' AND  NT.Счет=150403
		GROUP BY  NT.Счет

		
		
		
		SELECT
		FROM stack.[Показания счетчиков] AS PS
		LEFT JOIN stack.Документ AS DOC
		ON DOC.ROW_ID=PS.[Показания-Документ] AND DOC.[Тип документа]=77 AND DOC.ВидСчета = 0
		JOIN [stack].[Список объектов] AS SO ON SO.[Объекты-Групповой] = DOC.ROW_ID AND @date BETWEEN SO.ДатКнц AND SO.ДатНач 
		join [stack].[Номенклатура] nom on so.[Номенклатура-Объекты]=nom.ROW_ID