	USE tns_kuban_fl_dev;			 
			 
			 SELECT pvt_adrs.Потомок AS ROW_ID,
					[5] AS LS,
					[0] + [1] AS Район,
					CITY.Сокращение AS [Тип НП],
					CITY.Название AS [Населенный пункт],
					STREET.Сокращение AS [Тип улицы],
					STREET.Название AS Улица,
					HOUSE.Номер AS Дом,
					HOUSE.Фамилия AS Корпус,
					FLAT.Номер AS Квартира,
					FLAT.Фамилия AS [Литерал квартиры]
			  FROM
				(
					SELECT 
							LI.РодительТип,
							LI.Потомок,
							CASE WHEN LI.РодительТип=0 THEN LS.Фамилия
							     WHEN LI.РодительТип=1 THEN ORG.Название
								 WHEN LI.РодительТип IN (12,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
								 WHEN LI.РодительТип IN (11,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
								 WHEN LI.РодительТип IN (13,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
								 WHEN LI.РодительТип=3 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
								 WHEN LI.РодительТип=4 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
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
				WHERE LI.ПотомокТип=5 AND LI.Потомок=366006

--формирование пивот-таблицы
		) AS pvt_adrs
		PIVOT (
				MAX(Адрес) FOR pvt_adrs.РодительТип IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
			  ) AS pvt_adrs
		LEFT JOIN stack.Города AS CITY
			ON CITY.ROW_ID=CAST([12] AS int)
		LEFT JOIN stack.Города AS STREET
			ON STREET.ROW_ID=CAST([2] AS int)
		LEFT JOIN stack.[Лицевые счета] AS HOUSE
			ON HOUSE.ROW_ID=CAST([3] AS int)
		LEFT JOIN stack.[Лицевые счета] AS FLAT
			ON FLAT.ROW_ID=CAST([4] AS int)
