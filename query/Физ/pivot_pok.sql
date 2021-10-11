DECLARE @date datetime ='20200801';

SELECT POK1.Показание, POK1.Дата
FROM stack.[Список объектов] AS OL
LEFT JOIN (
SELECT PVT.[0] AS День
	  ,PVT.[1] Ночь
	  ,PVT.[2] ППик
	  ,PVT.[Показания-Счет]
	  ,PVT.Дата
FROM(
		SELECT TOP(1) WITH TIES 
			TS.Показание, TS.Дата, TS.ТипВвода, TS.[Показания-Счет], TS.[Объект-Показания], Тариф 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]= 164180 AND TS.Тип=1 
		ORDER BY (ROW_NUMBER() OVER (PARTITION BY Тариф, [Показания-счет] ORDER BY Дата DESC, row_id DESC) -1)
        ) AS POK1 
		 PIVOT (
		MAX(POK1.Показание) FOR Тариф IN ([0], [1], [2])
	) AS PVT) AS POK
		 ON POK.[Показания-Счет]=OL.[Объекты-Счет] 
			AND POK1.[Объект-Показания]=OL.ROW_ID
LEFT JOIN stack.Номенклатура AS NR ON OL.[Номенклатура-Объекты]=NR.ROW_ID
WHERE OL.[Объекты-Счет] = 164180 AND @date BETWEEN OL.ДатНач AND OL.ДатКнц
ORDER BY POK1.Дата DESC