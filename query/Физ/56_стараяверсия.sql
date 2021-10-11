USE tns_kuban_fl_dev;

WITH 
--переменную для даты
--наличие ОДПУ
--номер договора (не работает иерархия), работает корректно, если в LS.ROW_ID передавать ID дома
--переделать через лицевые иерархии
--OR для UKDOG
Dog_num
	AS
		(
					SELECT 							
						   ISNULL(UKDOG.Номер, UKDOG_DOM.Номер) AS [Номер договора]
					FROM stack.[Лицевые счета] AS LS
					JOIN stack.[Лицевые иерархия] AS LI
						ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--для ЛС
					LEFT JOIN stack.[Управляющие компании] AS UK
						ON UK.[Счет-УК]=LS.ROW_ID
					LEFT JOIN stack.[УК Договоры] AS UKDOG
						ON UKDOG.ROW_ID=UK.[Дом-УКДоговор] 
						AND GETDATE() BETWEEN UKDOG.ДатНач AND UKDOG.ДатКнц
--для Дома
					LEFT JOIN stack.[Управляющие компании] AS UK_DOM
						ON UK_DOM.[Счет-УК]=LI.Родитель
					LEFT JOIN stack.[УК Договоры] AS UKDOG_DOM
						ON UKDOG_DOM.ROW_ID=UK_DOM.[Дом-УКДоговор] 
						AND GETDATE() BETWEEN UKDOG_DOM.ДатНач AND UKDOG_DOM.ДатКнц
					WHERE LS.ROW_ID=366006
		),
--тип строения
Type_stroy
	AS
		(
			SELECT	
					CASE
						 WHEN ISNULL(OP.Значение,OPD.Значение)=0 THEN 'Многоквартирный'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=1 THEN 'Частный'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=2 THEN 'Общежитие'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=3 THEN 'Дача'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=4 THEN 'Гараж'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=5 THEN 'Баня'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=6 THEN 'Сарай'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=7 THEN 'Прочие'
						 WHEN ISNULL(OP.Значение,OPD.Значение)=8 THEN 'Гаражи отдельностоящие'
						 ELSE 'Не заполнено'
					 END AS [Тип строения]
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=242 AND 
				GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=242 AND 
				GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
				 WHERE  LS.ROW_ID=366006

		),
--юр лицо
Type_UL
	AS
		(
			SELECT 
				CASE 
				WHEN OP.Значение IS NULL THEN 'Нет'
				WHEN OP.Значение IS NOT NULL THEN 'Да'
				ELSE 'Не заполнено'
				END AS ЮРЛИЦО
			FROM stack.[Лицевые счета] AS LS
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=244 AND 
				GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
				 WHERE  LS.ROW_ID=366006

		),
--информация по ЛС
LS_number 
	AS
		(
			SELECT CR.ФИО AS ФИО,LS.Номер AS [№ лицевого счета]
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Карточки регистрации] AS CR
				ON CR.[Счет-Наниматель]=LS.ROW_ID
			WHERE LS.Тип=5  AND  LS.ROW_ID=366006

		),
--адрес склееный 
ADDRES
		AS
		(
			SELECT ([12] + ' '+ [2]+' '+ [3] +' ') AS Адрес
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
				   ) AS pvt_adrs
		),
--почтовый индекс
Ind
	AS
		(
			SELECT	
					CASE 
					WHEN LS.ИндексДоставки IS NOT NULL 
					THEN ISNULL(OP.Значение,OPD.Значение)
					END AS Индекс
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=11 AND 
				GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=11 AND 
				GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
				 WHERE  LS.ROW_ID=366006
		),
--отделение префиксов
ADDRES_RAZVERN
		AS
		(
		SELECT ([0]+' '+[1]) AS 'Район',[12] AS 'Населенный пункт',[13],[11],[2] AS 'Улица',[3] AS 'Дома',[4] AS 'Квартира',[5]
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
--формирование пивот-таблицы
		) AS pvt_adrs
		PIVOT (
				MAX(Адрес) FOR pvt_adrs.РодительТип IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
			  ) AS pvt_adrs
			  ),
--информация по счетчику	
SCHETCHIK 
	AS
		(
			SELECT NR.Наименование AS [Тип ПУ], SO.ЗаводскойНомер AS [Номер ПУ], SO.Тарифность, SO.Разрядность, SO.[Коэффициент трансформации] AS [Коэф.трансф]
			FROM stack.[Лицевые счета] AS LS
			LEFT JOIN stack.[Список объектов] AS SO 
				ON SO.[Объекты-Счет]=LS.ROW_ID 
			LEFT JOIN stack.Номенклатура AS NR 
				ON SO.[Номенклатура-Объекты]=NR.ROW_ID
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.Значение!=2
			JOIN stack.[Состояние счетчика] AS SS
				ON SS.[Счет-Счетчика состояние]=LS.ROW_ID AND SS.Состояние!=3 AND
				GETDATE() BETWEEN SS.ДатНач AND SS.ДатКнц
				 WHERE  LS.ROW_ID=366006

		),
--информация по показаниям
POKAZANIYA 
	AS 
		(	
		SELECT
			POK1.Дата AS [Дата последнего показания],
			CASE 
				WHEN POK1.ТипВвода=0 THEN 'КП'
				WHEN POK1.ТипВвода=1 THEN 'Аб'
				WHEN POK1.ТипВвода=2 THEN 'ДС'
				WHEN POK1.ТипВвода=3 THEN 'ДМ'
				WHEN POK1.ТипВвода=4 THEN 'Установка'
				WHEN POK1.ТипВвода=5 THEN 'Снятие'
				WHEN POK1.ТипВвода=6 THEN 'КП/П'
				WHEN POK1.ТипВвода=7 THEN 'Коррекция'
				WHEN POK1.ТипВвода=8 THEN 'Банк'
				WHEN POK1.ТипВвода=9 THEN 'WEB'
				WHEN POK1.ТипВвода=10 THEN 'OUT'
				WHEN POK1.ТипВвода=11 THEN 'АСКУЭ'
				WHEN POK1.ТипВвода=12 THEN 'Старший'
				WHEN POK1.ТипВвода=13 THEN 'Откл'
				WHEN POK1.ТипВвода=14 THEN 'Подкл'
				WHEN POK1.ТипВвода=15 THEN 'Телефон'
				WHEN POK1.ТипВвода=16 THEN 'SMS'
				WHEN POK1.ТипВвода=17 THEN 'Огр'
				WHEN POK1.ТипВвода=18 THEN 'ГИС'
			END AS [Тип последнего показания],
			POK1.Показание AS [Последние показания день],
			POK2.Показание AS [Последние показания ночь],
			POK3.Показание AS [Последние показания ППик]
			
	FROM 
		stack.[Лицевые счета] AS LS
	LEFT JOIN stack.[Список объектов] AS OL 
		ON OL.[Объекты-Счет]=LS.ROW_ID AND
		GETDATE() BETWEEN OL.ДатНач AND OL.ДатКнц
	LEFT JOIN stack.Номенклатура AS NR 
		ON OL.[Номенклатура-Объекты]=NR.ROW_ID
	LEFT JOIN stack.Свойства AS OP 
		ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=76  AND 
		GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц AND OP.Значение!=2
	OUTER APPLY
		(SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=LS.[ROW_ID] AND TS.Тип=1 
		AND TS.Тариф=1
		AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK1
	OUTER APPLY
		(SELECT TOP 1 TS.Показание
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=LS.[ROW_ID] AND TS.Тип=1 
		AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK2
	OUTER APPLY
		(SELECT TOP 1 TS.Показание
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=LS.[ROW_ID] AND TS.Тип=1 
		AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
		ORDER BY TS.Дата DESC) AS POK3
		--предыдущие показания
	OUTER APPLY
		(SELECT  MAX(TSP.Показание) AS [Предыдущие показания], 
		MAX(TSP.Дата) AS [Предыдущиая дата]
		FROM stack.[Показания счетчиков] AS TSP
		WHERE TSP.[Показания-Счет]=LS.[ROW_ID] AND TSP.Тип=1 
		AND TSP.[Объект-Показания]=OL.ROW_ID AND
		TSP.Показание < 
			( 
			SELECT  MAX(TSP.Показание)
			FROM stack.[Показания счетчиков] AS TSP
			WHERE TSP.[Показания-Счет]=LS.[ROW_ID] AND TSP.Тип=1 
			AND TSP.[Объект-Показания]=OL.ROW_ID
			)
		AND TSP.Дата < 
		(
			SELECT  MAX(TSP.Дата)
			FROM stack.[Показания счетчиков] AS TSP
			WHERE TSP.[Показания-Счет]=LS.[ROW_ID] AND TSP.Тип=1 
			AND TSP.[Объект-Показания]=OL.ROW_ID
		)
		) AS PREDPOK
		 WHERE  LS.ROW_ID=366006

		),
--площадь дома
SQUARE_parametrs
	AS
		(
			SELECT ISNULL(OP.Значение,OPD.Значение) AS Площадь
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=102 AND 
					GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=102 AND 
					GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
					 WHERE  LS.ROW_ID=366006

		),
--количество комнат
ROOMS_parametrs
	AS
		(
			SELECT ISNULL(OP.Значение,OPD.Значение) AS Комнат
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=92 AND 
					GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=92 AND 
					GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
					 WHERE  LS.ROW_ID=366006

		),
--количество прописанных
Propis_parametrs
	AS
		(
			SELECT ISNULL(OP.Значение,OPD.Значение) AS Прописано
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=83 AND 
					GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=83 AND 
					GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
					 WHERE  LS.ROW_ID=366006

		),
--состояние ЛС
Sost_LS
	AS
		(
			SELECT 
				CASE
				WHEN ISNULL(OP.Значение,OPD.Значение)=0 THEN 'Используется' 
				WHEN ISNULL(OP.Значение,OPD.Значение)=1 THEN 'Не проживает' 
				WHEN ISNULL(OP.Значение,OPD.Значение)=2 THEN 'Закрыт' 
				END AS [состояние лицевого (или сезонность)]
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
	--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LS.ROW_ID AND OP.[Виды-Параметры]=76 AND 
					GETDATE() BETWEEN OP.ДатНач AND OP.ДатКнц
	--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель AND OPD.[Виды-Параметры]=76 AND 
					GETDATE() BETWEEN OPD.ДатНач AND OPD.ДатКнц
					 WHERE  LS.ROW_ID=366006

		),
--поставщик
Postav_name
	AS
		(
			SELECT 
				ISNULL(ORG.Название,ORG_D.Название) AS [Наименование поставщика]
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--для ЛС
			LEFT JOIN stack.Поставщики AS POS
			ON POS.[Счет-Список поставщиков]=LS.ROW_ID
			LEFT JOIN stack.Организации AS ORG
			ON ORG.ROW_ID=POS.[Поставщики-Список]
--для дома
			LEFT JOIN stack.Поставщики AS POS_D
			ON POS_D.[Счет-Список поставщиков]=LI.Родитель
			LEFT JOIN stack.Организации AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[Поставщики-Список]
			 WHERE  LS.ROW_ID=366006

		),
--телефон и e-mail
CONTACTS
	AS
		(
			SELECT LS.Телефон, LS.[E-Mail] 
			FROM stack.[Лицевые счета] AS LS 
			 WHERE  LS.ROW_ID=366006

		)
--Действующая УК

 SELECT *
 --условие для каждого join, row_id в каждом блоке
 FROM
 Dog_num,Type_stroy,Type_UL,LS_number,ADDRES,Ind,SCHETCHIK,POKAZANIYA,SQUARE_parametrs,ROOMS_parametrs,Propis_parametrs,Sost_LS,Postav_name, CONTACTS

