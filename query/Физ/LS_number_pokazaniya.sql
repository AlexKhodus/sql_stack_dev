SELECT PA.Номер, OL.ЗаводскойНомер, NR.Наименование, POK1.Показание
FROM stack.[Лицевые счета] AS PA
LEFT JOIN stack.[Список объектов] AS OL 
	ON OL.[Объекты-Счет]=PA.ROW_ID
LEFT JOIN stack.Номенклатура AS NR 
	ON OL.[Номенклатура-Объекты]=NR.ROW_ID
LEFT JOIN stack.Свойства AS OP 
	ON OP.[Счет-Параметры]=OP.ROW_ID AND OP.[Виды-Параметры]=76  AND 
	GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц AND OP.Значение!=2
OUTER APPLY
	(SELECT TOP 1 TS.Показание
	FROM stack.[Показания счетчиков] AS TS
	WHERE TS.[Показания-Счет]=PA.[ROW_ID] AND TS.Тип=1 
	AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
	ORDER BY TS.Дата DESC) AS POK1
OUTER APPLY
	(SELECT TOP 1 TS.Показание
	FROM stack.[Показания счетчиков] AS TS
	WHERE TS.[Показания-Счет]=PA.[ROW_ID] AND TS.Тип=1 
	AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
	ORDER BY TS.Дата DESC) AS POK2
OUTER APPLY
	(SELECT TOP 1 TS.Показание
	FROM stack.[Показания счетчиков] AS TS
	WHERE TS.[Показания-Счет]=PA.[ROW_ID] AND TS.Тип=1 
	AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
	ORDER BY TS.Дата DESC) AS POK3
WHERE PA.Тип=5 AND PA.ROW_ID=31422
