 IF OBJECT_ID(N'tempdb..#TypePayments', N'U') IS NOT NULL
      DROP TABLE #TypePayments

   CREATE TABLE #TypePayments
				 (
				[Лицевой счет]		BIGINT,
				Сумма				FLOAT
					  );

INSERT INTO #TypePayments 
SELECT 
    LC, 
	SUM
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=g:\Bulk\20210813AP1.xlsx',
    'select * from [20210813AP1$]')
	 

WITH Оплаты AS (
SELECT LS.Номер,V.ROW_ID As Выписка, D.ROW_ID AS Пачка,SO.ROW_ID, SO.Сумма, SO.Дата
FROM [stack].[Документ] AS V
JOIN [stack].[Документ] AS D ON D.[Платеж-Выписка] = V.row_id
JOIN [stack].[Список оплаты] AS SO ON SO.[Платеж-Список] = D.row_id
JOIN stack.[Лицевые счета] AS LS ON LS.ROW_ID=SO.[Счет-Оплата]
WHERE V.row_id = 2968142
GROUP By LS.Номер,V.ROW_ID , D.ROW_ID ,SO.ROW_ID, SO.Сумма, SO.Дата
)
SELECT  *
FROM Оплаты AS O
JOIN #TypePayments AS P ON P.[Дата платежа]=O.Дата AND P.[Лицевой счет клиента]=O.Номер AND P.Сумма=O.Сумма

WITH Оплаты AS (
SELECT LS.Номер, SO.Сумма, SO.Дата
FROM [stack].[Документ] AS V
JOIN [stack].[Документ] AS D ON D.[Платеж-Выписка] = V.row_id
JOIN [stack].[Список оплаты] AS SO ON SO.[Платеж-Список] = D.row_id
JOIN stack.[Лицевые счета] AS LS ON LS.ROW_ID=SO.[Счет-Оплата]
LEFT JOIN [stack].[Показания счетчиков] AS PS ON PS.[Платеж-Счетчики] = SO.row_id
--WHERE V.row_id = 2968142
)
SELECT  *
FROM Оплаты AS O
JOIN #TypePayments AS P ON P.[Дата платежа]=O.Дата AND P.[Лицевой счет клиента]=O.Номер AND P.Сумма=O.Сумма


SELECT *
FROM stack.Документ
WHERE ROW_ID=2968142

SELECT *
FROM #TypePayments
