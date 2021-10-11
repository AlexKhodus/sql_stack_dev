USE tns_kuban_fl_dev;
DECLARE @date datetime='20200501';
DECLARE @account int=161408;
	CREATE TABLE #TypeEnter
	(flags INT PRIMARY KEY,
     Typename NVARCHAR(30) NOT NULL)
	 INSERT INTO #TypeEnter
	 VALUES		(0 , 'КП')
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
					,(18 , 'ГИС');
WITH 
DOG_NUM
	AS
		(
					SELECT LI.Потомок			
						   ,UKDOG_DOM.Номер AS [Номер договора]
						   ,ORG.Название AS [действующая управляющая компания]
						   ,CASE 
								WHEN UK_DOM.[Вариант расчета]=0 THEN ''
								WHEN UK_DOM.[Вариант расчета]=1 THEN 'Агентский полный'
								WHEN UK_DOM.[Вариант расчета]=2 THEN 'Агентский по оплате'
								WHEN UK_DOM.[Вариант расчета]=3 THEN 'Дельта'
								WHEN UK_DOM.[Вариант расчета]=4 THEN 'Норматив ОДН в УК'
							END AS [Вариант расчета]
					FROM  stack.[Лицевые иерархия] AS LI
					LEFT JOIN stack.[Управляющие компании] AS UK_DOM
						ON UK_DOM.[Счет-УК]=LI.Родитель AND LI.[РодительТип]=3 
					JOIN stack.[УК Договоры] AS UKDOG_DOM
						ON UKDOG_DOM.ROW_ID=UK_DOM.[Дом-УКДоговор] AND
						@date BETWEEN UKDOG_DOM.ДатНач AND UKDOG_DOM.ДатКнц
					JOIN stack.Организации AS ORG
						ON UK_DOM.[Организация-УК]=ORG.ROW_ID
		),
--ОДПУ
ODPU
	AS 
		(			
		SELECT 
			CASE 
				WHEN doc.Номер IS NOT NULL THEN 'Да'
				WHEN doc.Номер IS  NULL THEN 'Нет'
			END AS [Наличие ОДПУ]
			,LI.Потомок
		FROM stack.[Лицевые иерархия] LI
		  JOIN [stack].[Показания счетчиков] ps ON LI.Родитель = ps.[Показания-Счет]  AND  LI.РодительТип=3
		  join [stack].[Документ] doc  on doc.[ROW_ID] = ps.[Показания-Документ] AND doc.[Тип документа] = 77 AND ps.Тип = 6 AND doc.ВидСчета = 0
		  JOIN stack.[Состояние счетчика] AS SS
				ON SS.[Счет-Счетчика состояние]=LI.Потомок AND SS.Состояние!=3 AND
				@date BETWEEN SS.ДатНач AND SS.ДатКнц
		),
--тип строения
TYPE_STROY
	AS
		(	
			SELECT	
					LI.Потомок
					,LI.Родитель
					,CASE
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
			FROM stack.[Лицевые иерархия] AS LI
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LI.Потомок 
				AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
				AND OP.[Виды-Параметры]=(
					SELECT TOP 1 VP.ROW_ID
					FROM stack.[Виды параметров] AS VP
					WHERE VP.Название='ТИПСТРОЙ'
				)
--Для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель 
				AND (@date BETWEEN OPD.ДатНач AND OPD.ДатКнц)
				AND OPD.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ТИПСТРОЙ'
				 )
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5
		),
--юр лицо
TYPE_UL
	AS
		(
			SELECT
					OP.[Счет-Параметры] AS Потомок
					,CASE 
						WHEN OP.Значение IS NULL THEN 'Нет'
						WHEN OP.Значение IS NOT NULL THEN 'Да'
						ELSE 'Не заполнено'
					END AS ЮРЛИЦО
			 FROM stack.Свойства AS OP  
			WHERE OP.[Виды-Параметры]=(
					SELECT TOP 1 VP.ROW_ID
					FROM stack.[Виды параметров] AS VP
					WHERE VP.Название='ЮРЛИЦО'
				) AND @date BETWEEN OP.ДатНач AND OP.ДатКнц
		),
--ФИО нанимателя
FIO 
	AS
		(
			SELECT	CR.[Счет-Наниматель],
					CR.ФИО AS ФИО
			FROM	stack.[Карточки регистрации] AS CR
		),
--адреса + с разделение префиксов
ADDRES
	AS
	(
 SELECT				pvt_adrs.Потомок AS Потомок
					,[0] +' '+ [1] AS Район,
					ISNULL(CITY.Сокращение, ' ') AS [Тип НП]
					,ISNULL(CITY.Название, ' ')AS [Населенный пункт]
					,ISNULL(STREET.Сокращение, ' ') AS [Тип улицы]
					,ISNULL(STREET.Название, ' ') AS Улица
					,ISNULL(HOUSE.Номер, ' ') AS Дом
					,ISNULL(HOUSE.Фамилия, ' ') AS Корпус
					,ISNULL(FLAT.Номер, ' ') AS Квартира
					,ISNULL(FLAT.Фамилия, ' ') AS [Литерал квартиры]
					,(ISNULL(CITY.Сокращение+'.'+' '+CITY.Название, ' ') + ' '+ISNULL(STREET.Сокращение+'.'+' '+STREET.Название, ' ')+' '
					+ ISNULL(CAST(HOUSE.Номер AS nvarchar(12)), ' ') + ' '+ISNULL(CAST(HOUSE.Фамилия AS nvarchar(12)), ' ') +' '
					+ISNULL(CAST(FLAT.Номер AS nvarchar(12)), ' ')+' '+ISNULL(CAST(FLAT.Фамилия AS nvarchar(12)), ' ')
					) AS Адрес
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
								 WHEN LI.РодительТип=5 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
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
		LEFT JOIN stack.Города AS CITY
			ON CITY.ROW_ID=CAST([12] AS int)
		LEFT JOIN stack.Города AS STREET
			ON STREET.ROW_ID=CAST([2] AS int)
		LEFT JOIN stack.[Лицевые счета] AS HOUSE
			ON HOUSE.ROW_ID=CAST([3] AS int)
		LEFT JOIN stack.[Лицевые счета] AS FLAT
			ON FLAT.ROW_ID=CAST([4] AS int)
		),
--почтовый индекс
INDEX_
	AS
		(
			SELECT	
					LI.Потомок
					,CASE
						WHEN LS.ИндексДоставки=0 OR LS.ИндексДоставки IS NULL 
						THEN ISNULL(OP.Значение,OPD.Значение)
					END AS Индекс
			FROM stack.[Лицевые счета] AS LS
			JOIN stack.[Лицевые иерархия] AS LI
				ON  LS.ROW_ID=LI.Потомок AND LI.[РодительТип]=3 
--Для ЛС
			LEFT JOIN stack.Свойства AS OP 
				ON OP.[Счет-Параметры]=LI.Потомок 
				AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
				AND OP.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ИНДЕКС'
					 )
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель 
				AND (@date BETWEEN OPD.ДатНач AND OPD.ДатКнц)
				AND OPD.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ИНДЕКС'
					 )
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5
		),
--информация о ПУ
SCHETCHIK 
	AS
		(
			SELECT  SO.[Объекты-Счет] AS Потомок
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
					END AS [Тип расчета (ИПУ, Норматив, средний)]
			FROM stack.[Список объектов] AS SO 
			LEFT JOIN stack.Номенклатура AS NR 
				ON SO.[Номенклатура-Объекты]=NR.ROW_ID
			JOIN stack.[Состояние счетчика] AS SS
				ON SS.[Счет-Счетчика состояние]=SO.[Объекты-Счет] AND SS.Состояние!=3 AND
				@date BETWEEN SS.ДатНач AND SS.ДатКнц
			WHERE @date BETWEEN SO.ДатНач AND SO.ДатКнц

		),
--информация по показаниям
POKAZANIYA 
	AS 
		(
		SELECT
				OL.[Объекты-Счет] AS Потомок		
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
	),
--начисления
NACHISLENO
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS [Стоимость индивидуального потребления]
				, SUM(NT.Объем) AS [Объем индивидуального потребления]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		GROUP BY NT.Счет, NT.[Месяц расчета]
		),
--начисления по услугам
NACH_100
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS [Стоимость индивидуального потребления 100,400]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		AND NT.[Номер услуги]  BETWEEN 100 AND 199
		OR NT.[Номер услуги]  BETWEEN 400 AND 499
		GROUP BY NT.Счет, NT.[Месяц расчета]
		),
NACH_300
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS [Стоимость индивидуального потребления 300,350,3700,3800,3900]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
			AND NT.[Номер услуги] BETWEEN 300 AND 399
			OR NT.[Номер услуги]  BETWEEN 3700 AND 3799
			OR NT.[Номер услуги]  BETWEEN 3800 AND 3899
			OR NT.[Номер услуги]  BETWEEN 3900 AND 3999
		GROUP BY NT.Счет, NT.[Месяц расчета]
		),
--перерасчет
PERERASCH
	AS
		(
		SELECT NP.Счет AS Потомок
			   , SUM(NP.Объем) AS [Объем перерасчета]
			   , SUM(NP.Сумма) AS [сумма перерасчета]
		FROM stack.НПТариф AS NP
		WHERE NP.[Месяц расчета]=@date
		GROUP BY NP.Счет
		),
--сальдо входящее 100,400
SALDO_VHOD_100
	AS
		(
			SELECT SUM(S.Summa) AS [Сальдо на начало месяца 100,400],
					S.Счет AS Потомок
			FROM(
						  SELECT NS.Счет
								 , SUM(NS.Сумма) AS Summa
							FROM stack.НСальдо AS NS
							WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) 
							AND NS.[Номер услуги]  BETWEEN 100 AND 199
							OR NS.[Номер услуги]  BETWEEN 400 AND 499
							GROUP BY NS.Счет
				) AS S
			GROUP BY S.Счет
		),
--сальдо входящее 300,350,3700,3800,3900
SALDO_VHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS [Сальдо на начало месяца 300,350,3700,3800,3900],
				   S.Счет AS Потомок
			FROM(
						  SELECT NS.Счет
								 , SUM(NS.Сумма) AS Summa
							FROM stack.НСальдо AS NS
							WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) 
							AND NS.[Номер услуги] BETWEEN 300 AND 399
							OR NS.[Номер услуги]  BETWEEN 3700 AND 3799
							OR NS.[Номер услуги]  BETWEEN 3800 AND 3899
							OR NS.[Номер услуги]  BETWEEN 3900 AND 3999
							GROUP BY NS.Счет			
							) AS S
					GROUP BY S.Счет
		),
--сальдо исходящее 100
SALDO_ISHOD_100
	AS
		(
			SELECT SUM(S.Summa) AS [Сальдо на конец месяца 100,400],
					S.Счет AS Потомок
			FROM(
						  SELECT NS.Счет
								 , SUM(NS.Сумма) AS Summa
							FROM stack.НСальдо AS NS
							WHERE  NS.[Месяц расчета]= @date 
							AND NS.[Номер услуги] BETWEEN 100 AND 199 
							OR NS.[Номер услуги] BETWEEN 400 AND 499
							GROUP BY NS.Счет
				) AS S
			GROUP BY S.Счет
		),
--сальдо исходящее 300
SALDO_ISHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS [Сальдо на Конец месяца 300,350,3700,3800,3900],
					S.Счет AS Потомок
			FROM(
						    SELECT NS.Счет
								 , SUM(NS.Сумма) AS Summa
							FROM stack.НСальдо AS NS
							WHERE  NS.[Месяц расчета]= @date
							AND NS.[Номер услуги]  BETWEEN 300 AND 399
							OR NS.[Номер услуги]  BETWEEN 3700 AND 3799
							OR NS.[Номер услуги]  BETWEEN 3800 AND 3899
							OR NS.[Номер услуги]  BETWEEN 3900 AND 3999
							GROUP BY NS.Счет
				) AS S
			GROUP BY S.Счет
		),
--пени
PENYANACH
	AS
		(
			SELECT  PN.Счет AS Потомок
					,SUM(PN.Сумма) AS ПениНач
			FROM stack.ПениНачисление AS PN
			WHERE  PN.[Месяц расчета]=@date
			GROUP BY PN.Счет
		),
--пени исходящее
PENYAISALDO
	AS
		(
			SELECT  PSI.Счет AS Потомок 
					,SUM(PSI.Сумма) AS ПеняИсход
			FROM stack.ПениСальдо AS PSI
			WHERE  PSI.[Месяц расчета]=@date
			GROUP BY PSI.Счет
		),
--пени входящее
PENYAVSALDO
	AS
		(
			SELECT  PSV.Счет AS Потомок
					,SUM(PSV.Сумма) AS ПеняВход
			FROM stack.ПениСальдо AS PSV
			WHERE  PSV.[Месяц расчета]=DATEADD(mm, -1, @date)
			GROUP BY PSV.Счет
		),
--платеж
PLATEJ
	AS
		(
			SELECT D.[дата последней оплаты]
					,D.Потомок
					,D.Сумма
			FROM (
			SELECT TOP 1 LI.Потомок
							, SO.Дата AS [дата последней оплаты]
							, SO.Сумма
			FROM stack.[Лицевые иерархия] AS LI
			LEFT JOIN stack.[Список оплаты] AS SO
			ON SO.[Счет-Оплата]=LI.Потомок
			WHERE LI.Потомок=161408
			ORDER BY SO.Дата DESC 
			) AS D
		),
--ОДН
ODN
	AS
		(
		SELECT O.[Показания-Счет] AS Потомок
				,O.Расход
		FROM (SELECT TOP 1 PS.Расход,
			PS.[Показания-Счет] 
		FROM stack.[Показания счетчиков] AS PS
		LEFT JOIN stack.Документ AS DOC
		ON DOC.ROW_ID=PS.[Показания-Документ] AND DOC.[Тип документа]=77 AND DOC.ВидСчета = 0
		LEFT JOIN [stack].[Список объектов] AS SO ON SO.[Объекты-Групповой] = DOC.ROW_ID AND @date BETWEEN SO.ДатКнц AND SO.ДатНач) O
		),
--БУ
BU
	AS 
	(
		SELECT SUM(NT.Сумма) [Стоимость по Акту БУ]
			   ,SUM(NT.Объем) AS [объем по акту БУ]
			   ,NT.Счет AS Потомок
		FROM stack.НТариф AS NT
		WHERE NT.[Номер услуги]=(
		SELECT TOP 1 TU.[Номер услуги]
		FROM stack.[Типы услуг] AS TU
		WHERE TU.Наименование='Безучетное потребление'
		) AND NT.[Месяц расчета]='20191001' AND  NT.Счет=150403
		GROUP BY  NT.Счет, NT.[Месяц расчета]
	),
--номер услуги
USLUGA
	AS
		(
			SELECT	LI.Потомок
			,T.Значение AS Тариф
			,[stack].[CLR_Concat](ISNULL(TU.[Номер услуги],TUD.[Номер услуги])) AS [Номер услуги]
			,[stack].[CLR_Concat](ISNULL(TU.Наименование,TUD.Наименование)) AS [Тип домохозяйства]
			FROM stack.[Лицевые иерархия] AS LI
--для ЛС
			LEFT JOIN stack.[Список услуг] AS SU
				ON SU.[Счет-Услуги]=LI.Потомок 
			LEFT JOIN stack.[Типы услуг] AS TU
				ON TU.ROW_ID=SU.[Вид-Услуги]
--для дома
			LEFT JOIN stack.[Список услуг] AS SUD
				ON SUD.[Счет-Услуги]=LI.Родитель 
			LEFT JOIN stack.[Типы услуг] AS TUD
				ON TUD.ROW_ID=SUD.[Вид-Услуги]
			LEFT JOIN 	stack.[Тарифы] AS T
			ON TU.ROW_ID=T.[Вид-Тарифы] OR TUD.ROW_ID=T.[Вид-Тарифы]
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5 
			AND T.ДатНач=(
			SELECT TOP 1 T.ДатНач
			FROM stack.[Тарифы] AS T			
			WHERE T.[Вид-Тарифы]=TUD.ROW_ID OR TU.ROW_ID=T.[Вид-Тарифы]
			ORDER BY T.ДатНач DESC)
			GROUP BY LI.Потомок
			, T.Значение
		),
--площадь дома
SQUARE_
	AS
		(
			SELECT	OP.[Счет-Параметры] AS Потомок
					,OP.Значение AS Площадь
			FROM  stack.Свойства AS OP 
			WHERE OP.[Виды-Параметры]=(
					 SELECT  TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ОБЩПЛОЩАДЬ') 
			AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		),
--количество комнат
ROOMS
	AS
		(
			SELECT	OP.[Счет-Параметры] AS Потомок
					,OP.Значение AS Комнат
			FROM  stack.Свойства AS OP 
				WHERE OP.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='КОМНАТЫ') 
				AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		),
--количество прописанных
PROPISAN
	AS
		(
			SELECT	OP.[Счет-Параметры] AS Потомок
					,OP.Значение AS Прописано
			FROM stack.Свойства AS OP 
			WHERE OP.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ПРОП') 
			AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		),
--состояние ЛС
SOST_LS
	AS
		(
			SELECT  OP.[Счет-Параметры] AS Потомок
				,CASE
					WHEN OP.Значение=0 THEN 'Используется' 
					WHEN OP.Значение=1 THEN 'Не проживает' 
					WHEN OP.Значение=2 THEN 'Закрыт' 
				END AS [состояние лицевого (или сезонность)]
			FROM stack.Свойства AS OP 
				WHERE OP.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='СОСТОЯНИЕ') 
				AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		),
--поставщик
POSTAV_NAME
	AS
		(
			SELECT  LI.Потомок,
					ISNULL(ORG.Название,ORG_D.Название) AS [Наименование поставщика]
			FROM 
				 stack.[Лицевые иерархия] AS LI
--для ЛС
			LEFT JOIN stack.Поставщики AS POS
			ON POS.[Счет-Список поставщиков]=LI.Потомок
			LEFT JOIN stack.Организации AS ORG
			ON ORG.ROW_ID=POS.[Поставщики-Список]
--для дома
			LEFT JOIN stack.Поставщики AS POS_D
			ON POS_D.[Счет-Список поставщиков]=LI.Родитель
			LEFT JOIN stack.Организации AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[Поставщики-Список]
			WHERE LI.РодительТип=3 AND LI.ПотомокТип=5 AND (@date BETWEEN POS.ДатНач AND POS.ДатКнц OR @date BETWEEN POS_D.ДатНач AND POS_D.ДатКнц)
		),
--телефон и e-mail
PHONE
	AS
		(
			SELECT 
					[stack].[CLR_Concat](PH.Номер) AS Телефон
					,PH.[Счет-Телефон]
			FROM  stack.[Телефоны] AS PH
			WHERE  PH.Тип!=4 
			GROUP BY PH.[Счет-Телефон]
		),
EMAILS
	AS
		(
			SELECT 
					[stack].[CLR_Concat](EM.Номер) AS [E-MAIL]
					, EM.[Счет-Телефон]
			FROM stack.[Телефоны] AS EM
			WHERE EM.Тип=4
			GROUP BY EM.[Счет-Телефон] 
		)
 SELECT	
		 LS.Номер
		 ,DN.[Номер договора]
		 ,DN.[Вариант расчета]
		 ,(iSNULL(ODPU.[Наличие ОДПУ], 'Нет')) AS [Наличие ОДПУ 1 - да, 0 - нет]
		 ,FIO.ФИО
		 ,TS.[Тип строения]
		 ,ISNULL(TU.ЮРЛИЦО, 'Нет') AS [Юрлицо]
		 ,AD.Адрес
		 ,IND.Индекс
		 ,AD.Район
		 ,AD.[Тип НП]
		 ,AD.[Населенный пункт]
		 ,AD.[Тип улицы]
		 ,AD.Улица
		 ,AD.Дом
		 ,AD.Корпус
		 ,AD.Квартира
		 ,AD.[Литерал квартиры]
		 ,SC.[Тип ПУ]
		 ,SC.[Номер ПУ]
		 ,SC.Тарифность
		 ,SC.Разрядность
		 ,SC.[Коэф.трансф]
		 ,POK.[Дата последних показаний день] AS [Дата последних показаний день]
		 ,POK.[Последние показания день] AS [Последние показания день]
		 ,POK.[Тип последнего показания день] AS [Тип последнего показания день]
		 ,POK.[Дата предпоследних показаний день] AS [Дата предпоследних показаний день]
		 ,POK.[предыдущие показания день] AS [предыдущие показания день]
		 ,POK.[Тип предпоследнего показания день] AS [Тип предпоследнего показания день]
		 ,POK.[Дата последних показаний ночь] AS [Дата последних показаний ночь]
		 ,POK.[Последние показания ночь] AS [Последние показания ночь]
		 ,POK.[Тип последнего показания ночь] AS [Тип последнего показания ночь]
		 ,POK.[Дата предыдущих показаний ночь] AS [Дата предыдущих показаний ночь]
		 ,POK.[предыдущие показания ночь] AS [предыдущие показания ночь]
		 ,POK.[Тип предпоследнего показания ночь] AS  [Тип предпоследнего показания ночь]
		 ,POK.[Дата последних показаний ППик] AS [Дата последних показаний ППик]
		 ,POK.[Последние показания ППик] AS [Последние показания ППик]
		 ,POK.[Тип последнего показания ППик] AS [Тип последнего показания ППик]
		 ,POK.[Дата предыдущих показаний ППик] AS [Дата предыдущих показаний ППик]
		 ,POK.[предыдущие показания ППик] AS [предыдущие показания ППик]
		 ,POK.[Тип предпоследнего показания ППик] AS [Тип предпоследнего показания ППик]
		,ISNULL(NA.[Объем индивидуального потребления], 0) AS [Объем индивидуального потребления]
	    ,ISNULL(PER.[Объем перерасчета], 0) AS [Объем перерасчета]
 		,SC.[Тип расчета (ИПУ, Норматив, средний)]
		,(NA.[Стоимость индивидуального потребления]+ISNULL(PEN.ПениНач, 0)) AS [Стоимость индивидуального потребления]
		,NACH_100.[Стоимость индивидуального потребления 100,400]
		--,NACH_300.[Стоимость индивидуального потребления 300,350,3700,3800,3900]
		,ODN.Расход
		 ,SV100.[Сальдо на начало месяца 100,400]
		 ,SV300.[Сальдо на начало месяца 300,350,3700,3800,3900]
		 ,(ISNULL(NA.[Объем индивидуального потребления], 0)+ISNULL(PER.[Объем перерасчета], 0)) AS [Объем всего] 
		,U.Тариф
		---- ,(ISNULL(NA.[Стоимость индивидуального потребления], 0) AS [стоимость всего 100,400]
		,PL.[дата последней оплаты] 
		,BU.[объем по акту БУ]
	    ,BU.[Стоимость по Акту БУ]
		 ,SI100.[Сальдо на конец месяца 100,400]
		 ,SI300.[Сальдо на Конец месяца 300,350,3700,3800,3900]
		,U.[Номер услуги]
		 ,SQ.Площадь
		 ,R.Комнат
		 ,PR.Прописано
		 ,U.[Тип домохозяйства]
		 ,SL.[состояние лицевого (или сезонность)]
		 ,PN.[Наименование поставщика]
		 ,PH.Телефон
		,ISNULL(EM.[E-MAIL], 'Нет') AS [E-Mail]
 --условие для каждого join, row_id в каждом блоке
 FROM stack.[Лицевые счета] AS LS
 LEFT JOIN DOG_NUM AS DN ON LS.ROW_ID=DN.Потомок
 LEFT JOIN ODPU ON ODPU.Потомок=LS.ROW_ID
 LEFT JOIN FIO ON FIO.[Счет-Наниматель]=LS.ROW_ID
 LEFT JOIN TYPE_STROY AS TS ON TS.Потомок=LS.ROW_ID 
 LEFT JOIN TYPE_UL AS TU ON TU.Потомок=LS.ROW_ID
 LEFT JOIN INDEX_ AS IND ON IND.Потомок=LS.ROW_ID
 LEFT JOIN SCHETCHIK AS SC ON SC.Потомок=LS.ROW_ID
 LEFT JOIN POKAZANIYA AS POK ON POK.Потомок=LS.ROW_ID
 LEFT JOIN ADDRES AS AD ON AD.Потомок=LS.ROW_ID
 LEFT JOIN NACHISLENO AS NA ON NA.Потомок=LS.ROW_ID
 LEFT JOIN PENYANACH AS PEN ON PEN.Потомок=LS.ROW_ID
 LEFT JOIN NACH_100 ON NACH_100.Потомок=LS.ROW_ID
-- LEFT JOIN NACH_300 ON NACH_100.Потомок=LS.ROW_ID
 LEFT JOIN PERERASCH AS PER ON PER.Потомок=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_100 AS SV100 ON SV100.Потомок=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_100 AS SI100 ON SI100.Потомок=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_300 AS SV300 ON SV300.Потомок=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_300 AS SI300 ON SI300.Потомок=LS.ROW_ID
 LEFT JOIN PENYAVSALDO AS PSV ON PSV.Потомок=LS.ROW_ID
 LEFT JOIN PENYAISALDO AS PSI ON PSI.Потомок=LS.ROW_ID
 LEFT JOIN PLATEJ AS PL ON PL.Потомок=LS.ROW_ID
 LEFT JOIN BU ON BU.Потомок=LS.ROW_ID
 LEFT JOIN ODN ON ODN.Потомок=LS.ROW_ID
 LEFT JOIN SOST_LS AS SL ON LS.ROW_ID=SL.Потомок
 LEFT JOIN POSTAV_NAME AS PN ON LS.ROW_ID=PN.Потомок
 LEFT JOIN PROPISAN AS PR ON LS.ROW_ID=PR.Потомок
 LEFT JOIN ROOMS AS R ON LS.ROW_ID=R.Потомок
 LEFT JOIN USLUGA AS U ON LS.ROW_ID=U.Потомок
 LEFT JOIN SQUARE_ AS SQ ON LS.ROW_ID=SQ.Потомок
 LEFT JOIN PHONE AS PH ON LS.ROW_ID=PH.[Счет-Телефон]
 LEFT JOIN EMAILS AS EM ON LS.ROW_ID=EM.[Счет-Телефон] 
 WHERE LS.ROW_ID IN (@account) 
 DROP TABLE #TypeEnter
