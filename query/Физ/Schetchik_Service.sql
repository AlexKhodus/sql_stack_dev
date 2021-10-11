USE tns_kuban_fl_dev

SELECT	PA.Номер,
		OL.ЗаводскойНомер, 
		NR.Наименование,
		POK1.Показание,
		POK2.Показание, 
		POK3.Показание, 
		PPOK.Показание,
		OI.Наименование,
ISNULL(TU.Наименование,TUD.Наименование) AS [Название услуги]
FROM stack.[Лицевые счета] AS PA
	LEFT JOIN stack.[Список объектов] AS OL 
		ON OL.[Объекты-Счет]=PA.ROW_ID AND
		GETDATE() BETWEEN OL.ДатНач AND OL.ДатКнц
	LEFT JOIN stack.Номенклатура AS NR 
		ON OL.[Номенклатура-Объекты]=NR.ROW_ID
	LEFT JOIN stack.Свойства AS OP 
		ON OP.[Счет-Параметры]=PA.ROW_ID AND OP.[Виды-Параметры]=76  AND 
		GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц AND OP.Значение!=2
	JOIN stack.[Состояние счетчика] AS SS
		ON SS.[Счет-Счетчика состояние]=PA.ROW_ID AND SS.Состояние!=3 AND
		GETDATE() BETWEEN SS.ДатНач AND SS.ДатКнц
	OUTER APPLY
		(SELECT TOP 1 TS.Показание, TS.Дата
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
		(
		SELECT TOP 1 TS.Показание
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=PA.[ROW_ID] AND TS.Тип=1 
		AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK3
--предпоследние
	OUTER APPLY
	(
		SELECT TOP 1 TS.Показание 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=PA.[ROW_ID] AND TS.Тип=1 
		AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK1.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PPOK
		
--Лицевые Иерархии
	LEFT JOIN [stack].[Лицевые иерархия] AS LI 
		ON  PA.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--для ЛС
	LEFT JOIN stack.[Список услуг] AS SU
		ON SU.[Счет-Услуги]=PA.ROW_ID 
		AND SU.Состояние=0
	LEFT JOIN stack.[Типы услуг] AS TU
		ON TU.ROW_ID=SU.[Вид-Услуги]
	LEFT JOIN stack.[Поставщики] AS PO
		ON PO.[Счет-Список поставщиков]=PA.ROW_ID
	LEFT JOIN stack.[Организации] AS OI
		ON OI.ROW_ID=PO.[Поставщики-Список]
--для Дома
	LEFT JOIN stack.[Список услуг] AS SUD
		ON SUD.[Счет-Услуги]=LI.[Родитель]
			AND SUD.Состояние=0
	LEFT JOIN stack.[Типы услуг] AS TUD
		ON TUD.ROW_ID=SUD.[Вид-Услуги]
	LEFT JOIN stack.[Поставщики] AS POD
		ON POD.[Счет-Список поставщиков]=LI.[Родитель]
	LEFT JOIN stack.[Организации] AS OID
		ON OID.ROW_ID=POD.[Поставщики-Список]
WHERE  PA.ROW_ID=366006



--SELECT	*
--FROM	stack.[Показания счетчиков]
