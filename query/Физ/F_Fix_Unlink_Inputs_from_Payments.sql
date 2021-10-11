SELECT *
FROM [stack].[Документ] AS V
JOIN [stack].[Документ] AS D ON D.[Платеж-Выписка] = V.row_id
JOIN [stack].[Список оплаты] AS SO ON SO.[Платеж-Список] = D.row_id
JOIN [stack].[Показания счетчиков] AS PS ON PS.[Платеж-Счетчики] = SO.row_id
WHERE V.row_id = 2897970


UPDATE PS
SET [Платеж-Счетчики] = -1,
    [Показания-Документ] = -1
FROM [stack].[Документ] AS V
JOIN [stack].[Документ] AS D ON D.[Платеж-Выписка] = V.row_id
JOIN [stack].[Список оплаты] AS SO ON SO.[Платеж-Список] = D.row_id
JOIN [stack].[Показания счетчиков] AS PS ON PS.[Платеж-Счетчики] = SO.row_id
WHERE V.row_id = 2897970
