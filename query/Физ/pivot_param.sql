DECLARE @date datetime ='20200801';

WITH PARAMETRS AS (

SELECT 
		PVT.Счет AS Потомок
		,CASE
			WHEN PVT.СОСТОЯНИЕ=0 THEN 'Используется' 
			WHEN PVT.СОСТОЯНИЕ=1 THEN 'Не проживает' 
			WHEN PVT.СОСТОЯНИЕ=2 THEN 'Закрыт' 
			ELSE 'Не заполнено'
		END AS СОСТОЯНИЕ
		,CASE 
			WHEN PVT.ЮРЛИЦО IS NULL THEN 'Нет'
			WHEN PVT.ЮРЛИЦО IS NOT NULL THEN 'Да'
			ELSE 'Не заполнено'
		END AS ЮРЛИЦО 
		,CASE
			WHEN PVT.ТИПСТРОЙ=0 THEN 'Многоквартирный'
			WHEN PVT.ТИПСТРОЙ=1 THEN 'Частный'
			WHEN PVT.ТИПСТРОЙ=2 THEN 'Общежитие'
			WHEN PVT.ТИПСТРОЙ=3 THEN 'Дача'
			WHEN PVT.ТИПСТРОЙ=4 THEN 'Гараж'
			WHEN PVT.ТИПСТРОЙ=5 THEN 'Баня'
			WHEN PVT.ТИПСТРОЙ=6 THEN 'Сарай'
			WHEN PVT.ТИПСТРОЙ=7 THEN 'Прочие'
			WHEN PVT.ТИПСТРОЙ=8 THEN 'Гаражи отдельностоящие'
			ELSE 'Не заполнено'
		END AS ТИПСТРОЙ 
		,КОМНАТЫ 
		,ПРОП
		,ИНДЕКС
		,ОБЩПЛОЩАДЬ
	FROM (
		SELECT TOP(1) WITH TIES 
			LH.Потомок AS Счет,
			V.Название,
			O.Значение
		FROM [stack].[Лицевые иерархия] AS LH
		JOIN [stack].[Свойства] AS O 
		  ON O.[Счет-Параметры] = LH.Родитель
			 AND @date BETWEEN O.ДатНач AND   O.ДатКнц
		JOIN [stack].[Виды параметров] AS V ON V.row_id = O.[Виды-Параметры]
		WHERE LH.ПотомокТип = 5
		  AND O.[Виды-Параметры] IN (SELECT row_id FROM [stack].[Виды параметров] WHERE Название IN ('СОСТОЯНИЕ', 'ЮРЛИЦО', 'ТИПСТРОЙ', 'КОМНАТЫ', 'ПРОП', 'ИНДЕКС', 'ОБЩПЛОЩАДЬ'))
		ORDER BY ROW_NUMBER() OVER (PARTITION BY LH.Потомок, O.[Виды-Параметры] ORDER BY LH.Уровень)
	) AS T	
	PIVOT (
		MAX(Значение) FOR Название IN (СОСТОЯНИЕ, ЮРЛИЦО, ТИПСТРОЙ, КОМНАТЫ, ПРОП, ИНДЕКС, ОБЩПЛОЩАДЬ)
	) AS PVT
	)


	UPDATE R
	SET Сост_ЛС = P.СОСТОЯНИЕ,
		Юр_лицо = P.ЮРЛИЦО,
		Индекс = P.ИНДЕКС,
		ТипСтроения = P.ТИПСТРОЙ,
		Прописан = P.ПРОП,
		Комнаты = P.КОМНАТЫ,
		Площадь = P.ОБЩПЛОЩАДЬ
	FROM #Result AS R
	JOIN PARAMETRS AS P ON p.Потомок=R.ROW_ID
