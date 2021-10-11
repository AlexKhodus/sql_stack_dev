DECLARE @date datetime='20200401';
WITH
--начисления
--NACHISLENO
--	AS 
--		(
--		SELECT	NT.Счет AS Потомок 
--				, SUM(NT.Сумма) AS [Стоимость индивидуального потребления]
--				, SUM(NT.Объем) AS [Объем индивидуального потребления]
--		FROM  stack.НТариф AS NT
--		WHERE  NT.[Месяц расчета]=@date
--		GROUP BY NT.Счет
--		),
----сальдо входящее
--SALDO_VHOD
--	AS
--		(
--		DECLARE @date datetime='20200401';
--		SELECT (	
--					(
--						SELECT SUM(NS.Сумма) AS Sum100
--						FROM stack.НСальдо AS NS
--						WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) AND (NS.[Номер услуги] BETWEEN 100 AND 199)
--					--) +
--					--(
--					--	SELECT SUM(NS.Сумма) AS Sum400
--					--	FROM stack.НСальдо AS NS
--					--	WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) AND (NS.[Номер услуги] BETWEEN 400 AND 499) 
--					--)
--				) AS [Сальдо на конец месяца 100,400]
--		FROM stack.НСальдо AS NS
--		WHERE NS.Счет=164180
--		),
----сальдо исходящее
--SALDO_ISHOD
--	AS
--		(
--		SELECT NS.Счет AS Потомок
--				,SUM(NS.Сумма) AS [Сальдо на начало месяца 100,400]
--		FROM stack.НСальдо AS NS
--		WHERE NS.[Месяц расчета]=@date AND (NS.[Номер услуги] BETWEEN 100 AND 199) OR (NS.[Номер услуги] BETWEEN 400 AND 499) 
--		GROUP BY NS.Счет
--		),
		PLATEJ
	AS
		(
			SELECT   SO.Дата
			,SO.[Счет-Оплата] AS Потомок
			FROM stack.[Список оплаты] AS SO
			WHERE SO.ROW_ID=140338880
		)
SELECT LS.Номер
		,PL.Дата
		--,NACH.[Объем индивидуального потребления]
		--,NACH.[Стоимость индивидуального потребления]
		--,SV.[Сальдо на конец месяца 100,400]
		--,SI.[Сальдо на начало месяца 100,400]
FROM stack.[Лицевые счета] AS LS
LEFT JOIN PLATEJ AS PL ON PL.Потомок=LS.ROW_ID
--LEFT JOIN NACHISLENO AS NACH ON NACH.Потомок=LS.ROW_ID
--LEFT JOIN SALDO_VHOD AS SV ON SV.Потомок=LS.ROW_ID
--LEFT JOIN SALDO_ISHOD AS SI ON SI.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=164180 

SELECT	*
FROM	stack.[Список оплаты]
Where	ROW_ID = 140338880

with
D AS(
			SELECT TOP 1 SO.Дата, SO.Сумма
			,SO.[Счет-Оплата] AS Потомок
			FROM stack.[Список оплаты] AS SO
			WHERE SO.[Счет-Оплата]=164180
			ORDER BY  SO.Дата DESC)
SELECT LS.Номер,
		D.Дата,
		D.Сумма
FROM stack.[Лицевые счета] AS LS
LEFT JOIN D ON D.Потомок=LS.ROW_ID
WHERE LS.ROW_ID=164180

