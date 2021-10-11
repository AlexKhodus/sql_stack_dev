
SELECT LF.Фамилия, LL.Фамилия, COUNT(LS.Номер) AS [Количество]
FROM [stack].[Лицевые счета] AS LS 
JOIN [stack].[Лицевые иерархия] AS LI 
	ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=0 
JOIN stack.[Лицевые счета] AS LF ON LI.Родитель=LF.ROW_ID 
JOIN stack.[Лицевые иерархия] AS LU 
	ON LU.Потомок=LS.ROW_ID AND LU.[РодительТип]=1 
JOIN stack.[Лицевые счета] AS LL 
	ON LU.Родитель=LL.ROW_ID 
LEFT JOIN stack.Свойства AS OP 
	ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=76 AND GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц AND OP.Значение!=2
WHERE LS.[Тип]=5 
GROUP BY LF.Фамилия, LL.Фамилия
ORDER BY  LF.Фамилия, LL.Фамилия

SELECT	*
FROM	stack.[Свойства]
Where	ROW_ID = 208135


