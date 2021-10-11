USE tns_kuban_fl_dev
SELECT DISTINCT LS.Номер AS [№ лицевого счета],
				CR.ФИО,
				(LF.Фамилия +' '+ ORG.Название) AS [Структурное подразделение],
				(LFNP.Фамилия +' '+  'ул.'+ LFU.Фамилия+ ' '+ 'д.'+ CONVERT(varchar, LFD.Номер)+' '+ 'кв.'+CONVERT(varchar, LFKV.Номер)) AS [Адрес],
				PH.Номер AS Контакт
				--проверка флага
				--!!!разнести флаги по отдельным столбцам
				/*CASE 
				WHEN PH.Флаги=1 THEN '+' 
				WHEN PH.Флаги=2 THEN 'АВТООБЗВОН'
				WHEN PH.Флаги=3 THEN 'АВТООБЗВОН и СМС'
				END AS 'Коммуникация'*/
FROM stack.[Лицевые счета] AS LS
JOIN [stack].[Лицевые иерархия] AS LI 
	ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=0 
JOIN stack.[Лицевые счета] AS LF ON LI.Родитель=LF.ROW_ID 
JOIN stack.[Лицевые иерархия] AS LU 
	ON LU.Потомок=LS.ROW_ID AND LU.[РодительТип]=1 
--проверка действующих ЛС
LEFT JOIN stack.Свойства AS OP 
	ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=76 AND GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц AND OP.Значение!=2
--ФИО
JOIN stack.[Карточки регистрации] AS CR
	ON CR.[Счет-Наниматель]=LS.ROW_ID
--телефон
JOIN stack.[Телефоны] AS PH
	ON PH.[Счет-Телефон]=LS.ROW_ID
LEFT JOIN stack.Организации AS ORG
ON ORG.ROW_ID=LS.[Счет-Линейный участок]
--адрес
JOIN [stack].[Лицевые иерархия] AS LIU 
	ON  LS.ROW_ID=LIU.Потомок AND LIU.[РодительТип]=2 
JOIN stack.[Лицевые счета] AS LFU ON LIU.Родитель=LFU.ROW_ID 
JOIN [stack].[Лицевые иерархия] AS LID 
	ON  LS.ROW_ID=LID.Потомок AND LID.[РодительТип]=3 
JOIN stack.[Лицевые счета] AS LFD ON LID.Родитель=LFD.ROW_ID 
JOIN [stack].[Лицевые иерархия] AS LIKV 
	ON  LS.ROW_ID=LIKV.Потомок AND LIKV.[РодительТип]=4 
JOIN stack.[Лицевые счета] AS LFKV ON LIKV.Родитель=LFKV.ROW_ID 
JOIN [stack].[Лицевые иерархия] AS LINP 
	ON  LS.ROW_ID=LINP.Потомок AND LINP.[РодительТип]=12 
JOIN stack.[Лицевые счета] AS LFNP ON LINP.Родитель=LFNP.ROW_ID 
WHERE LS.Тип=5 AND LFD.ROW_ID=1322457

/*USE tns_kuban_fl_dev
SELECT LI.РодительТип,
	   LI.Потомок,
CASE 
	WHEN LI.РодительТип=0 THEN LS.Фамилия
	WHEN LI.РодительТип=1 THEN ORG.Название
	WHEN LI.РодительТип IN (12,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип IN (12,2) AND CY.До_после=0 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип IN (11,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип IN (11,2) AND CY.До_после=0 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип IN (13,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип IN (13,2) AND CY.До_после=0 THEN CY.Название + ' ' + CY.Сокращение 
	WHEN LI.РодительТип=3 THEN CAST(LS.Номер AS nvarchar(12)) + ' ' + LS.Фамилия
	WHEN LI.РодительТип=4 THEN CAST(LS.Номер AS nvarchar(12)) + ' ' + LS.Фамилия
	WHEN LI.РодительТип=5 THEN CAST(LS.Номер AS nvarchar(12))
	END AS Адрес
FROM stack.[Лицевые иерархия] AS LI
JOIN stack.[Лицевые счета] AS LS
	ON LI.РодительТип=LS.ROW_ID
LEFT JOIN stack.Города AS CY
	ON LS.[Улица-Лицевой счет]=CY.ROW_ID
LEFT JOIN stack.Организации AS ORG
	ON ORG.ROW_ID=LS.[Счет-Линейный участок]
WHERE LI.ПотомокТип=5 */
