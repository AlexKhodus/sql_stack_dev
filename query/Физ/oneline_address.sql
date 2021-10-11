WITH
ADDRES
		AS
		(
			SELECT ([12] + ' '+ [2]+' '+ [3] +' ') AS Адрес
			CASE
				WHEN [4]=NULL THEN ([12] + ' '+ [2]+' '+ [3] +' ')
			END AS Адрес
FROM(
SELECT	
		LI.РодительТип,
		LI.Потомок,
	CASE 
		WHEN LI.РодительТип=0 THEN LS.Фамилия
		WHEN LI.РодительТип=1 THEN ORG.Название
		WHEN LI.РодительТип IN (12,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение
		WHEN LI.РодительТип IN (12,2) AND CY.До_после=0 THEN CY.Сокращение + ' ' + CY.Название  
		WHEN LI.РодительТип IN (11,2) AND CY.До_после=0 THEN CY.Сокращение + ' ' + CY.Название 
		WHEN LI.РодительТип IN (11,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение 
		WHEN LI.РодительТип IN (13,2) AND CY.До_после=1 THEN CY.Сокращение + ' ' + CY.Название  
		WHEN LI.РодительТип IN (13,2) AND CY.До_после=0 THEN CY.Название + ' ' + CY.Сокращение 
		WHEN LI.РодительТип=3 THEN CAST(LS.Номер AS nvarchar(12)) + ' ' + LS.Фамилия
		WHEN LI.РодительТип=4 THEN CAST(LS.Номер AS nvarchar(12)) + ' ' + LS.Фамилия
		WHEN LI.РодительТип=5 THEN CAST(LS.Номер AS nvarchar(12))
	END AS Адрес
FROM stack.[Лицевые иерархия] AS LI
JOIN stack.[Лицевые счета] AS LS
	ON LI.Родитель=LS.ROW_ID
LEFT JOIN stack.Города AS CY
	ON LS.[Улица-Лицевой счет]=CY.ROW_ID
--Участок
LEFT JOIN stack.Организации AS ORG
	ON ORG.ROW_ID=LS.[Счет-Линейный участок] 
WHERE LI.Потомок=366006
--формирование пивот-таблицы
) AS pvt_adrs
PIVOT (
			MAX(Адрес) FOR pvt_adrs.РодительТип IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
	   ) AS pvt_adrs)
SELECT *
FROM ADDRES