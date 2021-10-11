USE tns_kuban_fl_dev;
DECLARE @date datetime='20200401';
	CREATE TABLE #TypeEnter
	(flags INT PRIMARY KEY,
     Typename NVARCHAR(30) NOT NULL)
	 INSERT INTO #TypeEnter
	 VALUES			(0 , 'КП')
					,(1 , 'Аб')
					,(2 , 'ДС')
					,(3 , 'ДМ')
					,(4 , 'Установка')
					,(5 , 'Снятие')
					,(6 , 'КП/П')
					,(7 , 'Коррекция')
					,(8 , 'Банк')
					,(9 , 'WEB')
					,(10 , 'OUT')
					,(11 , 'АСКУЭ')
					,(12 , 'Старший')
					,(13 , 'Откл')
					,(14 , 'Подкл')
					,(15 , 'Телефон')
					,(16 , 'SMS')
					,(17 , 'Огр')
					,(18 , 'ГИС')
		--SELECT *
		--FROM #TypeEnter
		SELECT
				OL.[Объекты-Счет]			
				,POK1.Показание AS [Последние показания день]
				,POK1.Дата AS [Дата последних показаний день]
				,TE1.Typename AS [Тип последнего показания день]
				,POK2.Показание AS [Последние показания ночь]
				,POK2.Дата AS [Дата последних показаний ночь]
				,TE2.Typename AS [Тип последнего показания ночь]
				,POK3.Показание AS [Последние показания ППик]
				,POK3.Дата AS [Дата последних показаний ППик]
				,TE3.Typename AS [Тип последнего показания ППик]
				,PREDPOK1.Показание AS [предыдущие показания день]
				,PREDPOK1.Дата AS [Дата предпоследних показаний день]
				,TEPRED1.Typename AS [Тип предпоследнего показания день]
				,PREDPOK2.Показание AS [предыдущие показания ночь]
				,PREDPOK2.Дата AS [Дата предыдущих показаний ночь]
				,TEPRED2.Typename AS [Тип предпоследнего показания ночь]				
				,PREDPOK3.Дата AS [Дата предыдущих показаний ППик]
				,PREDPOK3.Показание AS [предыдущие показания ППик]
				,TEPRED3.Typename AS [Тип предпоследнего показания ППик]
	FROM 
		stack.[Список объектов] AS OL 
	LEFT JOIN stack.Номенклатура AS NR 
		ON OL.[Номенклатура-Объекты]=NR.ROW_ID
	OUTER APPLY
		(SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK1
	OUTER APPLY
		(SELECT TOP 1 TS.Показание,TS.Дата, TS.ТипВвода
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK2
	OUTER APPLY
		(
		SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK3
--предпоследние
	OUTER APPLY
	(
		SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK1.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PREDPOK1
	OUTER APPLY
	(
		SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK2.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PREDPOK2
	OUTER APPLY
	(
		SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK3.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PREDPOK3
	LEFT JOIN #TypeEnter AS TE1
		ON TE1.flags=POK1.ТипВвода
	LEFT JOIN #TypeEnter AS TE2
		ON TE2.flags=POK2.ТипВвода
	LEFT JOIN #TypeEnter AS TE3
		ON TE3.flags=POK3.ТипВвода
	LEFT JOIN #TypeEnter AS TEPRED1
		ON TEPRED1.flags=PREDPOK1.ТипВвода
	LEFT JOIN #TypeEnter AS TEPRED2
		ON TEPRED2.flags=PREDPOK2.ТипВвода
	LEFT JOIN #TypeEnter AS TEPRED3
		ON TEPRED3.flags=PREDPOK3.ТипВвода
WHERE (@date BETWEEN OL.ДатНач AND OL.ДатКнц)
DROP TABLE #TypeEnter