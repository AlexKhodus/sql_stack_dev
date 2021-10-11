	DECLARE @date    datetime = '20200901',
		    @Лицевые NVARCHAR(MAX) = 635992;
			--1054;

	DECLARE @ПараметрТипСтроения INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ТИПСТРОЙ'),
            @ПараметрСостояние   INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'СОСТОЯНИЕ'),
            @ПараметрЮрЛицо      INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ЮРЛИЦО'),
		    @ПараметрИндекс      INT = (SELECT TOP (1) row_id FROM stack.[Виды параметров] WHERE Название = 'ИНДЕКС');

   IF OBJECT_ID(N'tempdb..#TypeEnter', N'U') IS NOT NULL
      DROP TABLE #TypeEnter

   CREATE TABLE #TypeEnter
      (flags INT PRIMARY KEY,
      Typename NVARCHAR(30) NOT NULL)
      INSERT INTO #TypeEnter
      VALUES	 (0  , 'КП')
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
      ROW_ID					INT,
      НомерЛС					BIGINT,
      Филиал					NVARCHAR(256),
	  Адрес						NVARCHAR(MAX),
	  Район						NVARCHAR(MAX),
	  НасПункт					NVARCHAR(MAX),
	  Улица						NVARCHAR(MAX),
	  Дом						NVARCHAR(MAX),
	  Квартира					INT,
	  ФИО						NVARCHAR(MAX),
	  Телефон					NVARCHAR(MAX),
	  EMAIL						NVARCHAR(MAX),
	  НомерУслуги				NVARCHAR(MAX),
	  ИмяУслуги					NVARCHAR(MAX),
	  Тариф						FLOAT,
	  ТипПУ						NVARCHAR(MAX),
	  НомерПУ					NVARCHAR(MAX),
	  Разрядность				INT,
	  Тарифность				INT,
	  КТрансформ				INT,
	  ТипРасчета				NVARCHAR(MAX),
	  ДатаПредПокДень			DATE,
	  ПредПокДень				INT,
	  ТипПредПокДень			NVARCHAR(MAX),
	  ДатаПредПокНочь			DATE,
	  ПредПокНочь				INT,
	  ТипПредПокНочь			NVARCHAR(MAX),
	  ДатаПредПокППик			DATE,
	  ПредПокППик				INT,
	  ТипПредПокППик			NVARCHAR(MAX),
	  ДатаПослПокДень			DATE,
	  ПослПокДень				INT,
	  ТипПослПокДень			NVARCHAR(MAX),
	  ДатаПослПокНочь			DATE,
	  ПослПокНочь				INT,
	  ТипПослПокНочь			NVARCHAR(MAX),
	  ДатаПослПокППик			DATE,
	  ПослПокППик				INT,
	  ТипПослПокППик			NVARCHAR(MAX),
	  ВСальдо_100				FLOAT,
	  ВСальдо_300				FLOAT,
	  ИсхСальдо_100				FLOAT,
	  ИсхСальдо_300				FLOAT,
	  Стоимость_100				FLOAT,
	  Стоимость_300				FLOAT,
	  СтоимИндПотреб			FLOAT,
	  ОбъемИндПотреб			FLOAT,
	  СПерерасчет				FLOAT,
	  ОПерерасчет				FLOAT,
	  ПлатУслуга_100			FLOAT,
	  ПлатУслуга_300			FLOAT,
	  ПлатСуммарный				FLOAT,
	  ПлатДата					DATE,
	  Списание_100				FLOAT,
	  Списание_300				FLOAT,
	  БУСтоимость				FLOAT,		
	  БУОбъем					FLOAT,
	  УКНомДог					BIGINT,
	  УКНаименование			NVARCHAR(MAX),
	  ВариантРасчета			NVARCHAR(MAX),
	  НаличиеОДПУ				NVARCHAR(MAX),
	  СтоимостьОДН				FLOAT,
	  ОбъемОДН					FLOAT,
	  Сост_ЛС					NVARCHAR(MAX),
	  Юр_лицо					NVARCHAR(MAX),
	  Индекс					NVARCHAR(MAX),
	  ТипСтроения				NVARCHAR(MAX),
	  Прописан					INT,
	  Комнаты					INT,
	  Площадь					NVARCHAR(MAX),
	  Имяпоставщика				NVARCHAR(MAX)
   );

   INSERT INTO #Result(ROW_ID, НомерЛС, Филиал)
   SELECT
      LS.ROW_ID,
      LS.Номер,
      LB.Фамилия 
   FROM stack.[Лицевые иерархия] AS LI
   JOIN stack.[Лицевые счета] AS LS ON LS.row_id = LI.Потомок
   JOIN [stack].[Лицевые иерархия] AS LHB ON LI.Потомок = LHB.Потомок AND LHB.РодительТип=0
   JOIN stack.[Лицевые счета] AS LB ON LHB.Родитель=LB.ROW_ID
   WHERE LI.ПотомокТип = 5
     AND LI.Родитель IN (SELECT * FROM [stack].[CLR_Split](@Лицевые));

   CREATE INDEX NCI_ROW_ID ON #Result (ROW_ID);
   
        WITH ADDRES	AS (
			SELECT  pvt_adrs.Потомок,
					[0]+' '+[1]+' '+[13] AS Район,
					[12] AS [Наимпенование НП],
					[2]  AS [Наименоваие улицы],
					[3]  AS [Дом, корпус],
					[4]  AS Квартира,
					IIF([4] IS NOT NULL,([0]+' '+[1]+','+' '+[13]+','+' '+[12] + ','+' '+ [2]+ ','+' '+[3] +','+' '+[4]),
										([0]+' '+[1]+','+' '+[13]+','+' '+[12] + ','+' '+ [2]+ ','+' '+[3])) AS Адрес		
         FROM(
            SELECT	
                  LI.РодительТип,
                  LI.Потомок,
                  CASE 
                     WHEN LI.РодительТип=0 THEN LS.Фамилия
                     WHEN LI.РодительТип=1 THEN ORG.Название
                     WHEN LI.РодительТип IN (12,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение
                     WHEN LI.РодительТип IN (12,2) AND CY.До_после=0 THEN CY.Сокращение + ' ' + CY.Название 
                     WHEN LI.РодительТип IN (11,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение 
                     WHEN LI.РодительТип IN (11,2) AND CY.До_после=0 THEN CY.Сокращение + ' ' + CY.Название
                     WHEN LI.РодительТип IN (13,2) AND CY.До_после=1 THEN CY.Название + ' ' + CY.Сокращение
                     WHEN LI.РодительТип IN (13,2) AND CY.До_после=0 THEN CY.Сокращение + ' ' + CY.Название   
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
               ) AS pvt_adrs)
			
          UPDATE R
          SET  Район    = A.Район,
	            НасПункт = A.[Наимпенование НП],
	            Улица    = A.[Наименоваие улицы],
               Дом      = A.[Дом, корпус],
               Квартира = A.Квартира,
               Адрес    = A.Адрес

      FROM #Result AS R
      JOIN ADDRES AS A ON R.ROW_ID = A.Потомок;

      UPDATE R
      SET ФИО = F.ФИО 
      FROM #Result AS R
      JOIN stack.[Карточки регистрации] AS F ON R.ROW_ID = F.[Счет-Наниматель];

   WITH PHONE AS (
			SELECT 
					[stack].[CLR_Concat](PH.Номер) AS Телефон,
               PH.[Счет-Телефон] AS Потомок
			FROM  stack.[Телефоны] AS PH
			WHERE  PH.Флаги!=4 
			GROUP BY PH.[Счет-Телефон]
   )   
   UPDATE R
   SET Телефон = PH.Телефон 
   FROM #Result AS R
   JOIN PHONE   AS PH ON R.ROW_ID = PH.Потомок;

   WITH  EMAILS
	AS
		(
			SELECT 
					[stack].[CLR_Concat](EM.Номер) AS [E-MAIL]
					, EM.[Счет-Телефон] AS Потомок
			FROM stack.[Телефоны] AS EM
			WHERE EM.Флаги=4
			GROUP BY EM.[Счет-Телефон] 
		)
      UPDATE R
      SET email = EM.[E-MAIL] 
      FROM #Result AS R
      JOIN EMAILS AS EM ON R.ROW_ID = EM.Потомок;

   WITH  USLUGA
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
			, T.Значение)

      UPDATE R
      SET НомерУслуги = U.[Номер услуги],
      ИмяУслуги = U.[Тип домохозяйства],
      Тариф = U.Тариф
      FROM #Result AS R
      JOIN USLUGA AS U ON R.ROW_ID = U.Потомок;

   WITH SCHETCHIK 
	AS
		(
			SELECT  SO.[Объекты-Счет] AS Потомок
					, NR.Наименование AS [Тип ПУ]
					, SO.ЗаводскойНомер AS [Номер ПУ]
					, SO.Тарифность
					, SO.Разрядность
               , SO.[Коэффициент трансформации]
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
         )

      UPDATE R
      SET ТипПУ       = SC.[Тип ПУ],
          НомерПУ     = SC.[Номер ПУ],
          Разрядность = SC.Тарифность,
          Тарифность  = SC.Разрядность,
          КТрансформ  = SC.[Коэффициент трансформации],
          ТипРасчета  = SC.[Тип расчета]
      FROM #Result AS R
      JOIN SCHETCHIK AS SC ON R.ROW_ID = SC.Потомок;

   WITH POKAZANIYA 
	AS 
		(
		SELECT
				PREDPOK1.Показание AS [ПредПокДень]
				,PREDPOK1.Дата AS [ДатаПредПокДень]
				,TEPRED1.Typename AS [ТипПредПокДень]
				,PREDPOK2.Показание AS [ПредПокНочь]
				,PREDPOK2.Дата AS [ДатаПредПокНочь]
				,TEPRED2.Typename AS [ТипПредПокНочь]				
				,PREDPOK3.Дата AS [ДатаПредПокППик]
				,PREDPOK3.Показание AS [ПредПокППик]
				,TEPRED3.Typename AS [ТипПредПокППик]
            ,OL.[Объекты-Счет] AS Потомок		
				,POK1.Показание AS [ПослПокДень]
				,POK1.Дата AS [ДатаПослПокДень]
				,TE1.Typename AS [ТипПослПокДень]
				,POK2.Показание AS [ПослПокНочь]
				,POK2.Дата AS [ДатаПослПокНочь]
				,TE2.Typename AS [ТипПослПокНочь]
				,POK3.Показание AS [ПослПокППик]
				,POK3.Дата AS [ДатаПослПокППик]
				,TE3.Typename AS [ТипПослПокППик]
		FROM stack.[Список объектов] AS OL 
		LEFT JOIN stack.Номенклатура AS NR 
			ON OL.[Номенклатура-Объекты]=NR.ROW_ID
		OUTER APPLY
			(
         SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода
			FROM stack.[Показания счетчиков] AS TS
			WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
			AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
			ORDER BY TS.Дата DESC
         ) AS POK1
      OUTER APPLY
         (
         SELECT TOP 1 TS.Показание,TS.Дата, TS.ТипВвода
         FROM stack.[Показания счетчиков] AS TS
         WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
         AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
         ORDER BY TS.Дата DESC
         ) AS POK2
      OUTER APPLY
         (
         SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода
         FROM stack.[Показания счетчиков] AS TS
         WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
         AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
         ORDER BY TS.Дата DESC
         ) AS POK3
--предпоследние
      OUTER APPLY
         (
         SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
         FROM stack.[Показания счетчиков] AS TS
         WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
         AND TS.Тариф=0 AND TS.[Объект-Показания]=OL.ROW_ID
         AND POK1.Дата!=TS.Дата
         ORDER BY TS.Дата DESC
         ) AS PREDPOK1
      OUTER APPLY
         (
         SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
         FROM stack.[Показания счетчиков] AS TS
         WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
         AND TS.Тариф=1 AND TS.[Объект-Показания]=OL.ROW_ID
         AND POK2.Дата!=TS.Дата
         ORDER BY TS.Дата DESC
         ) AS PREDPOK2
      OUTER APPLY
         (
         SELECT TOP 1 TS.Показание, TS.Дата, TS.ТипВвода 
         FROM stack.[Показания счетчиков] AS TS
         WHERE TS.[Показания-Счет]=OL.[Объекты-Счет] AND TS.Тип=1 
         AND TS.Тариф=2 AND TS.[Объект-Показания]=OL.ROW_ID
         AND POK3.Дата!=TS.Дата
         ORDER BY TS.Дата DESC
         ) AS PREDPOK3
      LEFT JOIN #TypeEnter AS TE1     ON TE1.flags     =  POK1.ТипВвода
      LEFT JOIN #TypeEnter AS TE2     ON TE2.flags     =  POK2.ТипВвода
      LEFT JOIN #TypeEnter AS TE3     ON TE3.flags     =  POK3.ТипВвода
      LEFT JOIN #TypeEnter AS TEPRED1 ON TEPRED1.flags =  PREDPOK1.ТипВвода
      LEFT JOIN #TypeEnter AS TEPRED2 ON TEPRED2.flags =  PREDPOK2.ТипВвода
      LEFT JOIN #TypeEnter AS TEPRED3 ON TEPRED3.flags =  PREDPOK3.ТипВвода
      WHERE @date BETWEEN OL.ДатНач AND OL.ДатКнц
      )

      UPDATE R
      SET ПослПокДень     = POK.[ПослПокДень],
          ДатаПослПокДень = POK.[ДатаПослПокДень],
          ТипПослПокДень  = POK.ТипПослПокДень,
          ПослПокНочь     = POK.ПослПокНочь,
          ТипПослПокНочь  = POK.[ТипПослПокНочь],
          ДатаПослПокНочь = POK.[ДатаПослПокНочь],
          ПослПокППик     = POK.[ПослПокППик],
          ДатаПослПокППик = POK.[ДатаПослПокППик],
          ТипПослПокППик  = POK.ТипПослПокППик,
          ПредПокДень     = POK.ПредПокДень,
          ДатаПредПокДень = POK.[ДатаПредПокДень],
          ТипПредПокДень  = POK.[ТипПредПокДень],
          ПредПокНочь     = POK.ПредПокНочь,
          ДатаПредПокНочь = POK.[ДатаПредПокНочь],
          ТипПредПокНочь  = POK.[ТипПредПокНочь],
          ДатаПредПокППик = POK.ДатаПредПокППик,
          ПредПокППик     = POK.[ПредПокППик],
          ТипПредПокППик  = POK.[ТипПредПокППик]
      FROM #Result AS R
      JOIN POKAZANIYA AS POK ON R.ROW_ID = POK.Потомок;

   WITH SALDO_VHOD_100
	AS (
			SELECT SUM(S.Summa) AS Сальдо_100,
					S.Счет AS Потомок
			FROM(
				   SELECT NS.Счет
						  , SUM(NS.Сумма) AS Summa
		      	FROM stack.НСальдо AS NS
					WHERE  NS.[Месяц расчета]=DATEADD(mm, -1, @date) 
						AND NS.[Номер услуги]  BETWEEN 100 AND 199
						OR  NS.[Номер услуги]  BETWEEN 400 AND 499
					GROUP BY NS.Счет
				) AS S
			GROUP BY S.Счет
		)

      UPDATE R
      SET  ВСальдо_100 = SV_100.[Сальдо_100]
      FROM #Result AS R
      JOIN SALDO_VHOD_100 AS SV_100 ON R.ROW_ID = SV_100.Потомок;

   WITH SALDO_VHOD_300
	AS (
		SELECT  SUM(S.Summa) AS Сальдо_300,
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
		)
		
      UPDATE R
      SET  ВСальдо_300 = SV_300.[Сальдо_300]
      FROM #Result AS R
      JOIN SALDO_VHOD_300 AS SV_300 ON R.ROW_ID = SV_300.Потомок;

   WITH SALDO_ISHOD_100
	AS (
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
		)
		
      UPDATE R
      SET  ИсхСальдо_100 = IS_100.[ИсхСальдо_100]
      FROM #Result AS R
      JOIN SALDO_ISHOD_100 AS IS_100 ON R.ROW_ID = IS_100.Потомок;

  WITH SALDO_ISHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS ИсхСальдо_300,
					 S.Счет AS Потомок
			FROM(
					SELECT NS.Счет
							 , SUM(NS.Сумма) AS Summa
					FROM stack.НСальдо AS NS
					WHERE  NS.[Месяц расчета] = @date
					   AND NS.[Номер услуги] BETWEEN 300 AND 399
						OR NS.[Номер услуги]  BETWEEN 3700 AND 3799
						OR NS.[Номер услуги]  BETWEEN 3800 AND 3899
						OR NS.[Номер услуги]  BETWEEN 3900 AND 3999
						GROUP BY NS.Счет
				) AS S
			GROUP BY S.Счет
		)
      UPDATE R
      SET  ИсхСальдо_300 = IS_300.[ИсхСальдо_300]
      FROM #Result AS R
      JOIN SALDO_ISHOD_300 AS IS_300 ON R.ROW_ID = IS_300.Потомок;

  WITH NACH_100
	AS 
		(
		SELECT	NT.Счет AS Потомок 
				, SUM(NT.Сумма) AS Стоимость_100
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		AND NT.[Номер услуги]  BETWEEN 100 AND 199
		OR NT.[Номер услуги]  BETWEEN 400 AND 499
		GROUP BY NT.Счет, NT.[Месяц расчета]
		)
		
      UPDATE R
      SET  Стоимость_100 = N_100.[Стоимость_100]
      FROM #Result AS R
      JOIN NACH_100 AS N_100 ON R.ROW_ID = N_100.Потомок;

  WITH NACH_300
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
		)
		
      UPDATE R
      SET  Стоимость_300 = N_300.[Стоимость_300]
      FROM #Result AS R
      JOIN NACH_300 AS N_300 ON R.ROW_ID = N_300.Потомок;

   WITH NACHISLENO
	AS 
		(SELECT	NT.Счет AS Потомок 
		, SUM(NT.Сумма) AS [СтоимИндПотреб]
		, SUM(NT.Объем) AS [ОбъемИндПотреб]
		FROM  stack.НТариф AS NT
		WHERE  NT.[Месяц расчета]=@date
		GROUP BY NT.Счет, NT.[Месяц расчета]
		)
      UPDATE R
      SET  СтоимИндПотреб = N.[СтоимИндПотреб],
           ОбъемИндПотреб = N.ОбъемИндПотреб
      FROM #Result AS R
      JOIN NACHISLENO AS N ON R.ROW_ID = N.Потомок;

   WITH PERERASCH
	AS
		(
		SELECT NP.Счет AS Потомок
            , SUM(NP.Сумма) AS [сумма перерасчета]
			   , SUM(NP.Объем) AS [Объем перерасчета]
			   
		FROM stack.НПТариф AS NP
		WHERE NP.[Месяц расчета]=@date
		GROUP BY NP.Счет
		)
		
      UPDATE R
      SET   СПерерасчет = PERE.[сумма перерасчета],
            ОПерерасчет = PERE.[Объем перерасчета]
      FROM #Result AS R
      JOIN PERERASCH AS PERE ON R.ROW_ID = PERE.Потомок;

	WITH PLATEJ
	AS
		(
         SELECT TOP (1) WITH TIES 
                  SO.Дата AS [дата последней оплаты] 
                  ,SO.[Счет-Оплата] AS Потомок
         FROM stack.[Список оплаты] AS SO
         ORDER BY row_number() OVER (ORDER BY SO.Дата DESC)
		)
		
      UPDATE R
      SET  ПлатДата = PL.[дата последней оплаты]
      FROM #Result AS R
      JOIN PLATEJ AS PL ON R.ROW_ID = PL.Потомок;

   WITH SPIS_SALDO
	AS(
		SELECT
			KR.[Счет-Коррекция] AS Потомок,
			SUM(IIF(TU.[Номер услуги] - TU.[Номер услуги] % 100 IN (100, 400), KS.Сумма, 0)) AS Списание_100400,
			SUM(IIF(TU.[Номер услуги] - TU.[Номер услуги] % 100 IN (300, 3700, 3800, 3900), KS.Сумма, 0)) AS Списание_300
		FROM stack.[Коррекция заголовок] AS KR 
		JOIN stack.[Коррекция список] AS KS ON KS.[КорЗаголовок-Список] = KR.row_id
		JOIN stack.[Типы услуг] AS TU ON TU.ROW_ID = KS.[Услуга-Коррекция]
		WHERE ISNULL(KR.Тип, 0) != 1
		  AND KR.РасчМесяц = @date
		GROUP BY KR.[Счет-Коррекция]
		)
   UPDATE R
   SET Списание_100 = SPS.Списание_100400,
       Списание_300 = SPS.Списание_300
   FROM #Result AS R
   JOIN SPIS_SALDO AS SPS ON R.Row_ID = SPS.Потомок;

   WITH BU
	AS 
	(
		SELECT SUM(NT.Сумма) AS [Стоимость по Акту БУ]
			   ,SUM(NT.Объем) AS [объем по акту БУ]
			   ,NT.Счет AS Потомок
		FROM stack.НТариф AS NT
		WHERE NT.[Номер услуги]=(
		SELECT TOP 1 TU.[Номер услуги]
		FROM stack.[Типы услуг] AS TU
		WHERE TU.Наименование='Безучетное потребление'
		) AND NT.[Месяц расчета]=@date
		GROUP BY  NT.Счет, NT.[Месяц расчета]
	)
		
      UPDATE R
      SET   БУСтоимость = BU.[Стоимость по Акту БУ],
            БУОбъем     = BU.[объем по акту БУ]
      FROM #Result AS R
      JOIN BU ON R.ROW_ID = BU.Потомок;

   WITH  DOG_NUM
	AS (
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
		)  
      UPDATE R
      SET УКНомДог       = DN.[Номер договора],
          УКНаименование = DN.[действующая управляющая компания],
          ВариантРасчета = DN.[Вариант расчета]
      FROM #Result AS R
      JOIN DOG_NUM AS DN ON R.ROW_ID = DN.Потомок;

   WITH ODPU
	AS (			
		SELECT 
			CASE 
				WHEN doc.Номер IS NOT NULL THEN 'Да'
				WHEN doc.Номер IS NULL     THEN 'Нет'
			END AS [Наличие ОДПУ]
			,LI.Потомок
		FROM stack.[Лицевые иерархия] LI
		JOIN [stack].[Показания счетчиков] ps ON LI.Родитель = ps.[Показания-Счет]  AND  LI.РодительТип=3
		JOIN [stack].[Документ] doc  on doc.[ROW_ID] = ps.[Показания-Документ] AND doc.[Тип документа] = 77 AND ps.Тип = 6 AND doc.ВидСчета = 0
		JOIN stack.[Состояние счетчика] AS SS
			ON SS.[Счет-Счетчика состояние]=LI.Потомок AND SS.Состояние!=3 
			AND @date BETWEEN SS.ДатНач AND SS.ДатКнц
		)
   
    UPDATE R
      SET НаличиеОДПУ = ODPU.[Наличие ОДПУ]
      FROM #Result AS R
      JOIN ODPU  ON R.ROW_ID = ODPU.Потомок;

   WITH ODN
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
		)
   
    UPDATE R
      SET СтоимостьОДН = ODN.Расход
      FROM #Result AS R
      JOIN ODN  ON R.ROW_ID = ODN.Потомок;

   WITH SOST_LS
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
		)
   
   UPDATE R
   SET  Сост_ЛС = SLS.[состояние лицевого (или сезонность)]
   FROM #Result AS R
   JOIN SOST_LS AS SLS ON R.ROW_ID = SLS.Потомок;

   WITH TYPE_UL
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
		)
   
   UPDATE R
   SET  Юр_лицо = TUL.ЮРЛИЦО
   FROM #Result AS R
   JOIN TYPE_UL AS TUL ON R.ROW_ID = TUL.Потомок;

   WITH INDEX_
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
		)
   
   UPDATE R
   SET  Индекс = INDEX_.Индекс
   FROM #Result AS R
   JOIN INDEX_  ON R.ROW_ID = INDEX_.Потомок;

   WITH TYPE_STROY
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
		)
   
   UPDATE R
   SET  ТипСтроения = TPS.[Тип строения]
   FROM #Result AS R
   JOIN TYPE_STROY AS TPS  ON R.ROW_ID = TPS.Потомок;

   WITH PROPISAN
	AS
		(
			SELECT OP.[Счет-Параметры] AS Потомок
					,OP.Значение AS Прописано
			FROM stack.Свойства AS OP 
			WHERE OP.[Виды-Параметры]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ПРОП') 
			AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		)
   
   UPDATE R
   SET  Прописан = PR.Прописано
   FROM #Result  AS R
   JOIN PROPISAN AS PR  ON R.ROW_ID = PR.Потомок;

   WITH ROOMS
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
		)
   
   UPDATE R
   SET  Комнаты = RM.Комнат
   FROM #Result AS R
   JOIN ROOMS AS RM  ON R.ROW_ID = RM.Потомок;

   WITH SQUARE_
	AS
		(
			SELECT OP.[Счет-Параметры] AS Потомок
					,OP.Значение AS Площадь
			FROM  stack.Свойства AS OP 
			WHERE OP.[Виды-Параметры]=(
					 SELECT  TOP 1 VP.ROW_ID
					 FROM stack.[Виды параметров] AS VP
					 WHERE VP.Название='ОБЩПЛОЩАДЬ') 
			AND (@date BETWEEN OP.ДатНач AND OP.ДатКнц)
		)
   
   UPDATE R
   SET  Площадь = SQ.Площадь
   FROM #Result AS R
   JOIN SQUARE_ AS SQ  ON R.ROW_ID = SQ.Потомок;

   WITH POSTAV_NAME
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
		)
   UPDATE R
   SET Имяпоставщика = PN.[Наименование поставщика]
   FROM #Result AS R
   JOIN POSTAV_NAME AS PN ON R.ROW_ID = PN.Потомок;

   SELECT
      *     
   FROM #Result AS LS