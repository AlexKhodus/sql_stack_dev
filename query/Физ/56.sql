DECLARE @date datetime='20200501',
		@account int=161408;
IF OBJECT_ID(N'tempdb..#TypeEnter', N'U') IS NOT NULL
   DROP TABLE #TypeEnter


CREATE TABLE #TypeEnter
	(flags INT PRIMARY KEY,
     Typename NVARCHAR(30) NOT NULL)
	 INSERT INTO #TypeEnter
	 VALUES		 (0  , 'КП')
				,(1  , 'Аб')
				,(2  , 'ДС')
				,(3  , 'ДМ')
				,(4  , 'Установка')
				,(5  , 'Снятие')
				,(6  , 'КП/П')
				,(7  , 'Коррекция')
				,(8  , 'Банк')
				,(9  , 'WEB')
				,(10 , 'OUT')
				,(11 , 'АСКУЭ')
				,(12 , 'Старший')
				,(13 , 'Откл')
				,(14 , 'Подкл')
				,(15 , 'Телефон')
				,(16 , 'SMS')
				,(17 , 'Огр')
				,(18 , 'ГИС');

IF OBJECT_ID(N'tempdb..#Result', N'U') IS NOT NULL
    DROP TABLE #Result;

CREATE TABLE #Result(
	ROW_ID				INT,
	НомерЛС				BIGINT
);

INSERT INTO #Result(ROW_ID, НомерЛС)
SELECT   LS.ROW_ID 
		,LS.Номер
FROM stack.[Лицевые счета] AS LS
--WHERE LS.ROW_ID = 164180;
CREATE INDEX NCI_ROW_ID ON #Result (ROW_ID);
WITH DOG_NUM
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
				WHEN doc.Номер IS NULL THEN 'Нет'
			END AS [Наличие ОДПУ]
			,LI.Потомок
		FROM stack.[Лицевые иерархия] LI
		JOIN [stack].[Показания счетчиков] ps ON LI.Родитель = ps.[Показания-Счет]  AND  LI.РодительТип=3
		JOIN [stack].[Документ] doc  on doc.[ROW_ID] = ps.[Показания-Документ] AND doc.[Тип документа] = 77 AND ps.Тип = 6 AND doc.ВидСчета = 0
		JOIN stack.[Состояние счетчика] AS SS
			ON SS.[Счет-Счетчика состояние]=LI.Потомок AND SS.Состояние!=3 
			AND @date BETWEEN SS.ДатНач AND SS.ДатКнц
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
			AND OP.[Виды-Параметры]=@ПараметрТипСтроения
--Для дома
		LEFT JOIN stack.Свойства AS OPD 
			ON OPD.[Счет-Параметры]=LI.Родитель 
			AND (@date BETWEEN OPD.ДатНач AND OPD.ДатКнц)
			AND OPD.[Виды-Параметры]=@ПараметрТипСтроения
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
			WHERE OP.[Виды-Параметры]=@ПараметрЮрЛицо AND @date BETWEEN OP.ДатНач AND OP.ДатКнц
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
			SELECT	pvt_adrs.Потомок AS Потомок
			 		,[0] +' '+ [1] AS Район
					,ISNULL(CITY.Сокращение, ' ') AS [Тип НП]
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
				AND OP.[Виды-Параметры]=@ПараметрИндекс  
--для дома
			LEFT JOIN stack.Свойства AS OPD 
				ON OPD.[Счет-Параметры]=LI.Родитель 
				AND (@date BETWEEN OPD.ДатНач AND OPD.ДатКнц)
				AND OPD.[Виды-Параметры]=@ПараметрИндекс  
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
					END AS [Тип расчета]
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
				,POK1.Показание AS [ПослПокДень]
				,POK1.Дата AS [ДатаПослПокДень]
				,TE1.Typename AS [ТипПослПокДень]
				,POK2.Показание AS [ПослПокНочь]
				,POK2.Дата AS [ДатаПослПокНочь]
				,TE2.Typename AS [ТипПослПокНочь]
				,POK3.Показание AS [ПослПокППик]
				,POK3.Дата AS [ДатаПослПокППик]
				,TE3.Typename AS [ТипПослПокППик]
				,PREDPOK1.Показание AS [ПредПокДень]
				,PREDPOK1.Дата AS [ДатаПредПокДень]
				,TEPRED1.Typename AS [ТипПредПокДень]
				,PREDPOK2.Показание AS [ПредПокНочь]
				,PREDPOK2.Дата AS [ДатаПредПокНочь]
				,TEPRED2.Typename AS [ТипПредПокНочь]				
				,PREDPOK3.Дата AS [ДатаПредПокППик]
				,PREDPOK3.Показание AS [ПредПокППик]
				,TEPRED3.Typename AS [ТипПредПокППик]
		FROM stack.[Список объектов] AS OL 
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
		(SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK1.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PREDPOK1
		OUTER APPLY
		(SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
		FROM stack.[Показания счетчиков] AS TS
		WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
		AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
		AND POK2.Дата!=TS.Дата
		ORDER BY TS.Дата DESC) AS PREDPOK2
		OUTER APPLY
		(SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
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
		(SELECT	NT.Счет AS Потомок 
		, SUM(NT.Сумма) AS [СтоимИндПотреб]
		, SUM(NT.Объем) AS [ОбъемИндПотреб]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		GROUP BY NT.Счет, NT.[Месяц расчета]
		),
--начисления по услугам
NACH_100
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS Стоимость_100
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
				, SUM(NT.Сумма) AS Стоимость_300
		FROM  stack.НТариф AS NT
		WHERE   NT.[Месяц расчета]=@date
			AND NT.[Номер услуги]  BETWEEN 300 AND 399
			OR  NT.[Номер услуги]  BETWEEN 3700 AND 3799
			OR  NT.[Номер услуги]  BETWEEN 3800 AND 3899
			OR  NT.[Номер услуги]  BETWEEN 3900 AND 3999
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
			SELECT SUM(S.Summa) AS Сальдо_100,
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
			SELECT SUM(S.Summa) AS Сальдо_300,
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
			SELECT SUM(S.Summa) AS ИсхСальдо_100,
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
			SELECT SUM(S.Summa) AS ИсхСальдо_300,
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
		 SELECT TOP (1) WITH TIES 
               SO.Дата AS [дата последней оплаты] 
              ,SO.[Счет-Оплата] AS Потомок
         FROM stack.[Список оплаты] AS SO
         ORDER BY row_number() OVER (PARTITION BY SO.[Счет-Оплата] ORDER BY SO.Дата DESC)
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
		) AND NT.[Месяц расчета]=@date AND NT.Счет=150403
		GROUP BY  NT.Счет, NT.[Месяц расчета]
	),
POSTAV_NAME
	AS (
			SELECT LI.Потомок,
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
PARAMETRS AS (

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
	),
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
			, T.Значение),
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
		 LS.НомерЛС
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
		 ,SC.[Тип ПУ]
		 ,SC.[Номер ПУ]
		 ,SC.Тарифность
		 ,SC.Разрядность
		 ,SC.[Коэф.трансф]
		 ,POK.ДатаПослПокДень 
		 ,POK.ПослПокДень 
		 ,POK.ТипПослПокДень 
		 ,POK.ДатаПредПокДень 
		 ,POK.ПредПокДень 
		 ,POK.ТипПредПокДень 
		 ,POK.ДатаПослПокНочь
		 ,POK.ПослПокНочь 
		 ,POK.ТипПослПокНочь 
		 ,POK.ДатаПредПокНочь 
		 ,POK.ПредПокНочь 
		 ,POK.ТипПредПокНочь
		 ,POK.ДатаПослПокППик
		 ,POK.ПослПокППик 
		 ,POK.ТипПослПокППик 
		 ,POK.ДатаПредПокППик
		 ,POK.ПредПокППик 
		 ,POK.ТипПредПокППик 
		 ,ISNULL(NA.[ОбъемИндПотреб], 0) AS [Объем индивидуального потребления]
	     ,ISNULL(PER.[Объем перерасчета], 0) AS [Объем перерасчета]
		 ,PER.[сумма перерасчета]
 		 ,SC.[Тип расчета]
		 ,(NA.СтоимИндПотреб+ISNULL(PEN.ПениНач, 0)) AS [Стоимость индивидуального потребления]
		 ,NACH_100.Стоимость_100
		 ,NACH_300.Стоимость_300
		 ,ODN.Расход
		 ,SV100.Сальдо_100
		 ,SV300.Сальдо_300
		 ,(ISNULL(NA.[ОбъемИндПотреб], 0)+ISNULL(PER.[Объем перерасчета], 0)) AS [Объем всего] 
		 ,U.Тариф
		---- ,(ISNULL(NA.[Стоимость индивидуального потребления], 0) AS [стоимость всего 100,400]
		 ,PL.[дата последней оплаты]
		--,PL.Сумма AS [Платеж сумма]
		 ,BU.[объем по акту БУ]
	     ,BU.[Стоимость по Акту БУ]
		 ,SI100.ИсхСальдо_100
		 ,SI300.ИсхСальдо_300
		 ,P.ЮРЛИЦО
		 ,P.ИНДЕКС
		 ,P.ТИПСТРОЙ [Тип домохозяйства]
		 ,P.ПРОП
		 ,P.КОМНАТЫ
		 ,P.ОБЩПЛОЩАДЬ
		 ,U.[Номер услуги]
		 ,PN.[Наименование поставщика]
		 ,PH.Телефон
		,ISNULL(EM.[E-MAIL], 'Нет') AS [E-Mail]
 --условие для каждого join, row_id в каждом блоке
 FROM #Result AS LS
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
 LEFT JOIN NACH_300 ON NACH_300.Потомок=LS.ROW_ID
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
 LEFT JOIN PARAMETRS AS P ON p.Потомок=LS.ROW_ID
 LEFT JOIN PHONE AS PH ON LS.ROW_ID=PH.[Счет-Телефон]
 LEFT JOIN EMAILS AS EM ON LS.ROW_ID=EM.[Счет-Телефон] 
 LEFT JOIN POSTAV_NAME AS PN ON PN.Потомок=LS.ROW_ID
 LEFT JOIN USLUGA AS U ON LS.ROW_ID = U.Потомок
WHERE LS.ROW_ID IN (@account) 
-- DROP TABLE #TypeEnter
