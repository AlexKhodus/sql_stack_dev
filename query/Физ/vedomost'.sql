USE tns_kuban_fl_dev;
DECLARE @data dateTime='20200318';

--номиер выписки, номер и кол-во плат.ведомостей, кол-во оплат
SELECT 
		VP.Номер AS [Ведомость]
		, COUNT(DISTINCT PV.ROW_ID) AS [Выписки]
		, COUNT(SO.ROW_ID) AS [Платежи]
		, SUM(SO.Сумма) AS [Сумма платежей]
		, PV.Кол_во
FROM stack.[Список оплаты] AS SO
JOIN stack.Документ AS PV
ON PV.ROW_ID=SO.[Платеж-Список] AND PV.[Тип документа]=67
JOIN stack.Документ AS VP
ON VP.ROW_ID=PV.[Платеж-Выписка] AND VP.[Тип документа]=3
WHERE VP.ROW_ID=2639315
--VP.Дата=@data
GROUP BY VP.Номер, PV.ROW_ID, PV.Кол_во 



