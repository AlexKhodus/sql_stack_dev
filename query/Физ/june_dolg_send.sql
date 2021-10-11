DECLARE @date DATE = '20210723',
		@PER DATE = '20210601';
WITH ОПЛАТА AS (
	SELECT SO.[Счет-Оплата],
		   ISNULL(SUM(SO.Сумма),0) AS Сумма
	FROM stack.[Список оплаты] AS SO 
	JOIN stack.Документ As D ON D.ROW_ID=SO.[Платеж-Список]
	JOIN [stack].[Документ] AS V ON D.[Платеж-Выписка] = V.ROW_ID
	WHERE V.Дата > '20210701' 
	GROUP BY SO.[Счет-Оплата]
),
САЛЬДО AS (
	SELECT SUM(ISS.Сумма) AS ИсхСальдо,
			ISS.Счет
	FROM stack.НСальдо AS ISS 
	WHERE  ISS.[Месяц расчета]=@PER  AND ((ISS.[Номер услуги]>=100 and ISS.[Номер услуги]<200) OR (ISS.[Номер услуги]>=400 and ISS.[Номер услуги]<500)) 
	GROUP BY ISS.Счет
),
ДОЛГ AS  (
SELECT S.Счет, (S.ИсхСальдо-O.Сумма) AS Долг
FROM САЛЬДО AS S
JOIN ОПЛАТА AS O ON O.[Счет-Оплата]=S.Счет
),
ПАРАМЕТР AS (
SELECT S.[Счет-Параметры], S.Примечание
FROM  stack.Свойства AS S
WHERE S.[Виды-Параметры]=281 AND @date BETWEEN S.ДатКнц AND S.ДатКнц
),
РАССЫЛКА AS (
SELECT LS.Номер, 
	   round((D.Долг),2,1) AS Долг,
	   ISNULL(P.Примечание,E.Номер) AS EMAIL
FROM stack.[Лицевые счета] AS LS
JOIN ДОЛГ AS D ON D.Счет=LS.ROW_ID
LEFT JOIN ПАРАМЕТР AS P ON P.[Счет-Параметры]=LS.ROW_ID
LEFT JOIN stack.Телефоны AS E ON E.[Счет-Телефон]=LS.ROW_ID AND E.Тип=4
WHERE D.Долг >= 100 
)
SELECT *
FROM РАССЫЛКА
WHERE EMAIL IS NOT NULL
