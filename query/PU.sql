			DECLARE @date datetime='20201101',
					--@account int=161408,
					@ПараметрТипСтроения INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ТИПСТРОЙ');
		 
		 SELECT  LS.Номер, COUNT(LS.Номер)
		  , A.[Номер ПУ], A.Потомок
		  FROM stack.[Лицевые иерархия] AS L
		  JOIN stack.[Лицевые счета] AS LS
			ON LS.ROW_ID=L.Потомок
		  CROSS APPLY
			(
				SELECT   TOP (1)
						SO.[Объекты-Счет] AS Потомок
						, NR.Наименование AS [Тип ПУ]
						, SO.ЗаводскойНомер AS [Номер ПУ]
						, SO.Тарифность
						, SO.Разрядность
						, SO.[Коэффициент трансформации] AS [Коэф.трансф]
						,CASE
							WHEN SS.Состояние = 0 THEN 'Неизвестно'
							WHEN SS.Состояние = 1 THEN 'ИПУ'
							WHEN SS.Состояние = 2 THEN 'средний'
							WHEN SS.Состояние = 3 THEN 'Норматив'
						END AS [Тип расчета]
				FROM stack.[Список объектов] AS SO 
				JOIN stack.Номенклатура AS NR 
					ON SO.[Номенклатура-Объекты]=NR.ROW_ID 
				JOIN stack.[Состояние счетчика] AS SS
					ON SS.[Счет-Счетчика состояние]=SO.[Объекты-Счет] AND SS.Состояние!=3 AND
					@date BETWEEN SS.ДатНач AND SS.ДатКнц
				WHERE @date BETWEEN SO.ДатНач AND SO.ДатКнц
				AND ISNULL(NR.Идентификатор, 0) = 0
				AND L.Потомок=SO.[Объекты-Счет]
			  ORDER BY SO.ДатКнц DESC
			  ) AS A
			  WHERE L.ПотомокТип=5 AND L.РодительТип=3
			  GROUP BY LS.Номер
			  , A.[Номер ПУ], A.Потомок
			  Having COUNT(LS.Номер) > 1
