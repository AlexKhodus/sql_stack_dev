DECLARE @date    datetime = '20200901',
	    @Лицевые NVARCHAR(MAX) = 1092, --краснодарский участок
		@ПараметрСостояние   INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'СОСТОЯНИЕ');


SELECT   LS.Номер
		,EM.Номер AS EMAIL
   FROM stack.[Лицевые иерархия] AS LI
   JOIN stack.[Лицевые счета] AS LS ON LS.row_id = LI.Потомок
   JOIN stack.Телефоны AS EM ON EM.[Счет-Телефон]=LS.ROW_ID
   LEFT JOIN stack.Свойства AS S ON S.[Счет-Параметры] = LS.ROW_ID AND S.[Виды-Параметры]=@ПараметрСостояние AND @date BETWEEN S.ДатНач AND S.ДатКнц
WHERE LI.ПотомокТип = 5 
	 AND EM.Флаги=4
	 AND (S.Значение!=2 OR S.Значение IS NULL)
     AND LI.Родитель IN (SELECT * FROM [stack].[CLR_Split](@Лицевые));
