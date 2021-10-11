DECLARE @date datetime='20200401';
WITH
--начисления
NACHISLENO
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS [Стоимость индивидуального потребления]
				, SUM(NT.Объем) AS [Объем индивидуального потребления]
				, NT.ИспользованТариф AS [Тариф день]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		GROUP BY NT.Счет, NT.ИспользованТариф
		),
--перерасчет
PERERASCH
	AS
		(
		SELECT NP.Счет AS Потомок
			   , SUM(NP.Объем) AS [Объем перерасчета]
		FROM stack.НПТариф AS NP
		WHERE NP.[Месяц расчета]=@date
		GROUP BY NP.Счет
		),
--сальдо входящее
SALDO_VHOD
	AS
		(
		SELECT NS.Счет AS Потомок
				,SUM(NS.Сумма) AS [Сальдо на конец месяца 100,400]
		FROM stack.НСальдо AS NS
		WHERE NS.[Месяц расчета]=DATEADD(mm, -1, @date) AND (NS.[Номер услуги] BETWEEN 100 AND 199) OR (NS.[Номер услуги] BETWEEN 400 AND 499) 
		GROUP BY NS.Счет
		),
--сальдо исходящее
--SALDO_ISHOD
--	AS
--		(
--		SELECT NS.Счет AS Потомок
--				,SUM(NS.Сумма) AS [Сальдо на начало месяца 100,400]
--		FROM stack.НСальдо AS NS
--		WHERE NS.[Месяц расчета]=@date AND (NS.[Номер услуги] BETWEEN 100 AND 199) OR (NS.[Номер услуги] BETWEEN 400 AND 499) 
--		),
USLUGA
	AS
		(
			SELECT	LI.Потомок 
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
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5
			GROUP BY LI.Потомок
		),
TARIF
AS
(
		SELECT	NT.Счет AS Потомок 
				, NT.ИспользованТариф AS [Тариф]
		FROM  stack.НТариф AS NT
			LEFT JOIN stack.[Список услуг] AS SU
				ON SU.[Счет-Услуги]=NT.Счет
			LEFT JOIN stack.[Типы услуг] AS TU
				ON TU.ROW_ID=SU.[Вид-Услуги]
		WHERE  NT.[Месяц расчета]=@date AND NT.[Номер услуги]=102
		GROUP BY NT.Счет, NT.ИспользованТариф
)

		SELECT U.[Номер услуги]
				 ,NA.[Объем индивидуального потребления]
		 ,ISNULL(PER.[Объем перерасчета], 0)
		 ,(NA.[Объем индивидуального потребления]+PER.[Объем перерасчета]) AS [Объем всего] 
		 ,NA.[Тариф день]
		 ,NA.[Стоимость индивидуального потребления]
		 ,T.Тариф
		 FROM stack.[Лицевые счета] AS LS
		 LEFT JOIN USLUGA AS U ON LS.ROW_ID=U.Потомок
		 LEFT JOIN NACHISLENO AS NA ON NA.Потомок=LS.ROW_ID
		 LEFT JOIN PERERASCH AS PER ON PER.Потомок=LS.ROW_ID
		 LEFT JOIN TARIF AS T ON T.Потомок=LS.ROW_ID
		 WHERE LS.ROW_ID=164180 