DECLARE @Дата datetime='20200601'
DECLARE @ПараметрТипСтроения INT = (SELECT TOP (1) ROW_ID FROM stack.[Виды параметров] WHERE Название='ТИПСТРОЙ');
DECLARE @ТолькоИстекшие BIT = 0;
WITH ОДПУ (Номер, Тип, Лицевой, Родитель) AS (
	SELECT
		D.Номер,
		0, 
		LI.Потомок,
		LI.Родитель
	FROM [stack].[Документ] AS D 
	JOIN [stack].[Показания счетчиков] PS 
	  ON D.[ROW_ID] = ps.[Показания-Документ]
		 AND PS.Тип = 6
	JOIN stack.[Лицевые иерархия] LI ON LI.Родитель = ps.[Показания-Счет]
	JOIN [stack].[Список объектов] AS SO ON D.row_id = SO.[Объекты-Групповой]
	JOIN [stack].[Номенклатура] AS N ON N.row_id = SO.[Номенклатура-Объекты]
	JOIN [stack].[Состояние счетчика] AS SS ON SO.row_id = SS.[Объект-Состояние]
	WHERE D.[Тип документа] = 77
		AND D.Папки_ADD = 1
		AND ISNULL(D.ИсправлениеНомер, 0) = 0
		AND ISNULL(D.ВидСчета, 0) = 0
		AND ISNULL(N.Идентификатор, 0) = 0
		AND GETDATE() BETWEEN SO.ДатНач AND SO.ДатКнц
		AND GETDATE() BETWEEN SS.ДатНач AND SS.ДатКнц
		AND SS.Состояние = 1  
		
		UNION ALL
	
	SELECT 
		D.Номер,
		1,
		LI.Потомок,
		LI.Родитель
	FROM [stack].[Документ] AS D
	JOIN [stack].[Показания счетчиков] PS 
	  ON D.[ROW_ID] = ps.[Показания-Документ]
		AND PS.Тип = 6
	JOIN stack.[Лицевые иерархия] LI ON LI.Родитель = ps.[Показания-Счет]
	JOIN [stack].[Свойства] AS O 
	  ON O.[Документ-Параметры] = D.row_id
		AND GETDATE() BETWEEN O.ДатНач AND O.ДатКнц
		AND O.[Виды-Параметры] = (SELECT TOP(1) row_id FROM [stack].[Виды параметров] WHERE Название = 'СОСТОЯНИЕ')
		AND O.Значение = 0
	LEFT JOIN stack.Свойства PP
		ON PP.[Документ-Параметры]=D.ROW_ID 
		AND @Дата BETWEEn PP.ДатНач AND PP.ДатКнц
	WHERE D.[Тип документа] = 77
		AND D.Папки_ADD = 1
		AND ISNULL(D.ИсправлениеНомер, 0) = 1
		AND ISNULL(D.ВидСчета, 0) = 0
		AND LI.ПотомокТип = 5
		AND PP.Значение!=2
), Лицевые AS (
	SELECT DISTINCT
		D.Номер,
		D.Тип,
		D.Лицевой,
		D.Родитель,
		O.Значение
	FROM ОДПУ AS D
	OUTER APPLY (
		SELECT TOP(1) O.Значение
		FROM [stack].[Лицевые иерархия] AS LI
		JOIN [stack].[Свойства] AS O 
		  ON O.[Счет-Параметры] = LI.Родитель
		   AND O.[Виды-Параметры] = @ПараметрТипСтроения
			AND @Дата BETWEEN O.ДатНач AND O.ДатКнц
		WHERE LI.Потомок = D.Лицевой
		ORDER BY Уровень 
	) AS O
	WHERE O.Значение IN (0, 2)
),
Адрес AS(
 SELECT				pvt_adrs.Потомок AS Потомок,
					[0]  AS Филиал,
					[1] AS Участок,
					CITY.Сокращение AS [Тип НП],
					CITY.Название AS [Населенный пункт],
					STREET.Сокращение AS [Тип улицы],
					STREET.Название AS Улица,
					HOUSE.Номер AS Дом,
					HOUSE.Фамилия AS Корпус,
					FLAT.Номер AS Квартира,
					FLAT.Фамилия AS [Литерал квартиры],
					ROOM.Фамилия AS Комната
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
			LEFT JOIN stack.Организации AS ORG
				ON ORG.ROW_ID=LS.[Счет-Линейный участок] 
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
		LEFT JOIN stack.[Лицевые счета] AS ROOM
			ON ROOM.ROW_ID=CAST([5] AS int))
SELECT L.Номер AS Номер_ЛС
,ISNULL(CAST(LS.Номер AS nvarchar(256)),'') AS Код_ОДПУ 
,'Да' Признак_нал_дог
,CASE SLS.Значение
	WHEN 0 THEN 'Используется'
	WHEN 1 THEN 'Не проживает'
ELSE 'Используется'
END [Сост_ЛС]
,CASE LS.Значение
	WHEN 0 THEN 'Многоквартирный'
	WHEN 2 THEN 'Общежитие'
	ELSE ''
END [Тип_строения]
,AD.Филиал
,AD.Участок		
,ISNULL(AD.[Населенный пункт],'') [Населенный_пункт]
,ISNULL(AD.Улица,'') [Улица]
,ISNULL(AD.Дом,'') [Ном_дома]
,ISNULL(AD.Квартира,'') [Ном_квартиры]
,ISNULL(AD.Комната,'') [Ном_комнаты]
,CR.ФИО
,CASE 
	WHEN US.Значение=0 OR US.Значение IS NULL THEN 'Есть'
	WHEN US.Значение=1 THEN 'Нет'
	ELSE ''
END [Возможность_уст_ПУ]
,CASE
	WHEN F.Наименование is null THEN 'Отсутствует ПУ'
	ELSE 'Индивидуальный' END [Вид_ПУ]
,CONVERT(VarChar(50), F.ДатНач, 104) [Дата_установки]
,CASE 
	WHEN F.Состояние = 1 THEN 'Работает'
	WHEN F.Состояние = 2 THEN 'Начисляется по среднему'
	WHEN F.Состояние = 3 THEN 'не работает'
	ELSE ''
  END [Состояние_ПУ]
,F.Наименование [Наименование_ПУ]
,ISNULL(F.ЗаводскойНомер,'') [Номер_ПУ]
,ISNULL(F.Разрядность,'') Разрядность
,ISNULL(F.Тарифность,'') Тарифность
,ISNULL(F.[Коэффициент трансформации],'') [Коэф_трансф]
,ISNULL(CONVERT(VarChar(50), F.ГодВыпуска, 104),'') [Год_выпуска]
,CONVERT(VarChar(50), F.ДатаПоверки, 104) [Дата_пред_поверки]
,ISNULL(PS.МПИ,'') AS МПИ
,ISNULL(CONVERT(VarChar(50), F.ДатаСледующейПоверки, 104),'')  [Дата_след_поверки]
,ISNULL(PS.[Класс точности],'') [Класс_точности]
,ISNULL(PS.ТОК,'') [Ток_пу]
,ISNULL(PS.Фазы,'') [Кол_во_фаз_счетчика]
,ISNULL(PS.НАПРЯЖЕНИЕ,'') [Напр_пу]
,CASE F.[Место установки]
	WHEN 0 THEN 'На опоре'
	WHEN 1 THEN 'Лестничная площадка'
	WHEN 2 THEN 'Квартира'
	WHEN 3 THEN 'Комната'
	WHEN 4 THEN 'Жилой дом'
	WHEN 5 THEN 'Подъезд'
	WHEN 6 THEN 'Гараж'
	WHEN 7 THEN 'Сарай'
	WHEN 8 THEN 'Фасад здания'
	WHEN 9 THEN 'Тумба в подъезде МЖД'
	WHEN 10 THEN 'Веранда'
	WHEN 11 THEN 'ВРУ МКД'
	WHEN 12 THEN 'РУ ТП'
ELSE 'Не указано'
END [Место_установки_ПУ]
,ISNULL(F.НомНомер, '') [Номенкл_номер]
,CASE ASK.Значение
	 WHEN 0 THEN 'Возможность подключения имеется' 
	 WHEN 1 THEN 'Сбор показаний' 
	 WHEN 2 THEN 'Дистанционное ограничение и отключение' 
	 ELSE ''
END [АСКУЭ] 
,ISNULL([stack].[CLR_Concat](SMS.Номер), '') [смс]
,ISNULL([stack].[CLR_Concat](AV.Номер), '') [автообзвон]
,ISNULL([stack].[CLR_Concat](PH.Номер), '') [Телефон]
,ISNULL([stack].[CLR_Concat](EM.Номер), '') [E_MAIL]
,ISNULL(ORG.Название, '')  [Наим_УК]
,ISNULL(CAST(UKDOG_DOM.Номер AS nvarchar(256)),'')  [Ном_Дог_УК]
,F.Примечание [Прим_к_месту_ПУ]
,ISNULL(CONVERT(VarChar(50), P.[Дата установки], 104),'')  [Дата_посл_пломбы]
,CASE
	WHEN P.[Кто установил]=0 THEN 'Сети'
	WHEN P.[Кто установил]=1 THEN 'Сбыт'
	WHEN P.[Кто установил]=2 THEN 'ИКУ'
	WHEN P.[Кто установил]=3 THEN 'Энергоконтроль'
	ELSE ''
END [Орг_проверку_пломбы]
,CASE
	WHEN P.Состояние=0 THEN 'Установлено'
	WHEN P.Состояние=1 THEN 'Не нарушено'
	WHEN P.Состояние=2 THEN 'Нарушено'
	ELSE ''
END [Сост_пломбы]
FROM Лицевые AS LS
JOIN stack.[Лицевые счета] As L ON L.ROW_ID=LS.Лицевой
JOIN Адрес AS AD ON AD.Потомок=LS.Лицевой
JOIN stack.[Карточки регистрации] CR ON CR.[Счет-Наниматель]=LS.Лицевой
LEFT JOIN stack.Свойства TU
	ON TU.[Счет-Параметры]=LS.Лицевой 
				AND TU.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ЮРЛИЦО'
				 )
				AND TU.Значение IS NULL
LEFT JOIN stack.Свойства SLS ON SLS.[Счет-Параметры]=LS.Лицевой
	AND (@Дата BETWEEN SLS.ДатНач AND SLS.ДатКнц)
	AND SLS.[Виды-Параметры]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[Виды параметров] VP
		WHERE VP.Название='СОСТОЯНИЕ'
		 )
LEFT JOIN stack.Свойства US ON US.[Счет-Параметры]=LS.Лицевой
	AND (@Дата BETWEEN US.ДатНач AND US.ДатКнц)
	AND US.[Виды-Параметры]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[Виды параметров] VP
		WHERE VP.Название='НТВ_ИСЧ_ЭЛ'
		 )
OUTER APPLY
(
	SELECT TOP 1 SO.ДатНач, SO.ROW_ID so_row, NOM.ROW_ID  nom_row,
		SS.Состояние, NOM.Наименование,NOM.НомНомер,SO.ЗаводскойНомер,SO.Разрядность,SO.Тарифность,SO.[Коэффициент трансформации],SO.ГодВыпуска ,SO.ДатаПоверки,so.[Место установки],SO.Примечание, SO.ДатаСледующейПоверки  
	FROM stack.[Список объектов] AS SO 
	JOIN stack.[Состояние счетчика] SS
	  ON SS.[Объект-Состояние] = SO.row_id
         AND @Дата BETWEEN SS.ДатНач AND SS.ДатКнц
	JOIN [stack].[Номенклатура] NOM on SO.[Номенклатура-Объекты]=nom.ROW_ID
	WHERE SO.[Объекты-Счет] = LS.Лицевой 
	  AND @Дата BETWEEN SO.ДатНач AND SO.ДатКнц
	  AND ISNULL(NOM.Идентификатор, 0) = 0
	ORDER BY SO.ДатКнц DESC
) AS F
LEFT JOIN stack.Свойства ASK ON ASK.[Объекты-Параметры]=F.so_row
	AND (@Дата BETWEEN ASK.ДатНач AND ASK.ДатКнц)
	AND ASK.[Виды-Параметры]=2395
LEFT JOIN(	SELECT pvt.[60] AS МПИ,pvt.[23] AS [Класс точности], pvt.[28] AS Напряжение ,pvt.[27] AS Ток,pvt.[24] AS Фазы, pvt.Объект AS Потомок
    FROM (            
		SELECT zp.[Параметр-Значения] Название, zp.Значение,zp.[ном-параметры] AS Объект
        FROM stack.[значения параметров] zp
        WHERE zp.[Параметр-Значения] in ( 23,24,27,28,60 )
         ) AS sv
    PIVOT ( max(Значение) FOR Название in ( [28], [27], [24], [60], [23] )
    ) AS pvt ) AS PS ON PS.Потомок=F.nom_row
LEFT JOIN stack.Телефоны PH
	ON PH.[Счет-Телефон]=LS.Лицевой AND PH.Флаги=2
LEFT JOIN stack.Телефоны SMS
	ON SMS.[Счет-Телефон]=LS.Лицевой AND SMS.Флаги=1	
LEFT JOIN stack.Телефоны AV
	ON AV.[Счет-Телефон]=LS.Лицевой AND AV.Флаги=3
LEFT JOIN stack.[Телефоны]  EM
	ON EM.[Счет-Телефон]=LS.Лицевой AND EM.Флаги=4 
LEFT JOIN stack.[Управляющие компании]  UK_DOM
		ON UK_DOM.[Счет-УК]=LS.Родитель 
		AND (@Дата BETWEEN UK_DOM.ДатНач AND UK_DOM.ДатКнц)
LEFT JOIN stack.[УК Договоры]  UKDOG_DOM
	ON UKDOG_DOM.ROW_ID=UK_DOM.[Дом-УКДоговор] AND
	@Дата BETWEEN UKDOG_DOM.ДатНач AND UKDOG_DOM.ДатКнц
LEFT JOIN stack.Организации  ORG
	ON UK_DOM.[Организация-УК]=ORG.ROW_ID
OUTER APPLY(
			SELECT TOP 1  PL.[Пломба-Объект]
			,PL.[Дата установки]
			,PL.[Кто установил]
			,PL.Состояние
			FROM stack.[Пломбы]  PL
			WHERE PL.[Пломба-Объект]=F.so_row 
			ORDER BY PL.[Дата установки] DESC
		) AS P 
WHERE (TU.Значение IS NULL) AND (SLS.Значение IN (0,1) OR SLS.Значение IS NULL) AND (@ТолькоИстекшие=0 OR  (F.so_row IS NOT NULL AND @Дата >= DATEADD (year, CAST(PS.МПИ as int), F.ДатаПоверки))) 
GROUP BY  L.Номер,LS.Номер,US.Значение,LS.Значение,SLS.Значение,AD.Филиал, AD.Участок, AD.[Населенный пункт],AD.Улица,AD.Дом,AD.Квартира,AD.Комната, CR.ФИО,F.Наименование,F.ДатНач,
F.Состояние,F.Наименование,F.ЗаводскойНомер,F.Разрядность,F.Тарифность,F.[Коэффициент трансформации] ,F.ГодВыпуска ,F.ДатаПоверки  ,F.ДатаСледующейПоверки 
,F.[Место установки],F.НомНомер ,ASK.Значение,ORG.Название ,UKDOG_DOM.Номер,F.Примечание 
,P.[Дата установки], P.[Кто установил],P.Состояние, PS.МПИ,PS.[Класс точности],PS.НАПРЯЖЕНИЕ,PS.ТОК,PS.Фазы
UNION ALL
SELECT 
	  LS.Номер [Номер_ЛС]
	  ,ISNULL(CAST(ODPU.Номер AS nvarchar(256)),'') [Код_ОДПУ]
	  ,'Нет' [Признак_нал_дог]
	  ,CASE
			WHEN SLS.Значение=0 THEN 'Используется'
			WHEN SLS.Значение=1 THEN 'Не проживает'
			WHEN SLS.Значение=2 THEN 'Закрыт'
	   END [Сост_ЛС]
	  ,CASE
			WHEN ISNULL(OPTS.Значение,OPTSH.Значение)=0 THEN 'Многоквартирный'
			WHEN ISNULL(OPTS.Значение,OPTSH.Значение)=2 THEN 'Общежитие'
			ELSE ''
	   END [Тип_строения]
		,'' Филиал
		,'' Участок		
		,ISNULL(AD.[Населенный пункт],'') [Населенный_пункт]
		,ISNULL(AD.Улица,'') [Улица]
		,ISNULL(AD.Дом,'') [Ном_дома]
		,ISNULL(AD.Квартира,'') [Ном_квартиры]
		,ISNULL(AD.Комната,'') [Ном_комнаты]
		,CR.ФИО [ФИО]
		,CASE 
			WHEN US.Значение=0 OR US.Значение IS NULL THEN 'Есть'
			WHEN US.Значение=1 THEN 'Нет'
			ELSE ''
		 END [Возможность_уст_ПУ]
		 ,CASE
			WHEN nom.Наименование is null THEN 'Отсутствует ПУ'
			ELSE 'Индивидуальный' END [Вид_ПУ]
		 ,CONVERT(VarChar(50), SO.ДатНач, 104) [Дата_установки]
		 ,CASE 
			
			WHEN SS.Состояние = 1 THEN 'Работает'
			WHEN SS.Состояние = 2 THEN 'Начисляется по среднему'
			WHEN SS.Состояние = 3 THEN 'не работает'		
			ELSE ''
		  END [Состояние_ПУ]
		 ,NOM.Наименование [Наименование_ПУ]
		 ,ISNULL(SO.ЗаводскойНомер,'') [Номер_ПУ]
		 ,ISNULL(SO.Разрядность,'') Разрядность
		 ,ISNULL(SO.Тарифность,'') Тарифность
		 ,ISNULL(SO.[Коэффициент трансформации],'') [Коэф_трансф]
		 ,ISNULL(CONVERT(VarChar(50), SO.ГодВыпуска, 104),'') [Год_выпуска]
		 ,CONVERT(VarChar(50), SO.ДатаПоверки, 104) [Дата_пред_поверки]
		 ,ISNULL(MPI.Значение,'') [МПИ]
		 ,ISNULL(CONVERT(VarChar(50), SO.ДатаСледующейПоверки, 104),'')  [Дата_след_поверки]
		 ,ISNULL(CT.Значение,'') [Класс_точности]
		 ,ISNULL(TOK.Значение,'') [Ток_пу]
		 ,ISNULL(KF.Значение,'') [Кол_во_фаз_счетчика]
		 ,ISNULL(NAPR.Значение,'') [Напр_пу]
			  ,CASE 
				WHEN (SO.[Место установки]=0)  THEN 'На опоре'
				WHEN (SO.[Место установки]=1)  THEN 'Лестничная площадка'
				WHEN (SO.[Место установки]=2)  THEN 'Квартира'
				WHEN (SO.[Место установки]=3)  THEN 'Комната'
				WHEN (SO.[Место установки]=4)  THEN 'Жилой дом'
				WHEN (SO.[Место установки]=5)  THEN 'Подъезд'
				WHEN (SO.[Место установки]=6)  THEN 'Гараж'
				WHEN (SO.[Место установки]=7)  THEN 'Сарай'
				WHEN (SO.[Место установки]=8)  THEN 'Фасад здания'
				WHEN (SO.[Место установки]=9)  THEN 'Тумба в подъезде МЖД'
				WHEN (SO.[Место установки]=10) THEN 'Веранда'
				WHEN (SO.[Место установки]=11) THEN 'ВРУ МКД'
				WHEN (so.[Место установки]=12) THEN 'РУ ТП'
				ELSE 'Не указано'
			 END [Место_установки_ПУ]
			,ISNULL(NOM.НомНомер, '') [Номенкл_номер]
			,CASE
				 WHEN ASK.Значение=0 THEN 'Возможность подключения имеется' 
				 WHEN ASK.Значение=1 THEN 'Сбор показаний' 
				 WHEN ASK.Значение=2 THEN 'Дистанционное ограничение и отключение' 
				 ELSE ''
			 END [АСКУЭ] 
			,ISNULL([stack].[CLR_Concat](SMS.Номер), '') [смс]
			,ISNULL([stack].[CLR_Concat](AV.Номер), '') [автообзвон]
			,ISNULL([stack].[CLR_Concat](PH.Номер), '') [Телефон]
			,ISNULL([stack].[CLR_Concat](EM.Номер), '') [E_MAIL]
			,ISNULL(ORG.Название, '')  [Наим_УК]
			,ISNULL(CAST(UKDOG_DOM.Номер AS nvarchar(256)),'')  [Ном_Дог_УК]
			,SO.Примечание [Прим_к_месту_ПУ]
			,ISNULL(CONVERT(VarChar(50), P.[Дата установки], 104),'')  [Дата_посл_пломбы]
			,CASE
				WHEN P.[Кто установил]=0 THEN 'Сети'
				WHEN P.[Кто установил]=1 THEN 'Сбыт'
				WHEN P.[Кто установил]=2 THEN 'ИКУ'
				WHEN P.[Кто установил]=3 THEN 'Энергоконтроль'
				ELSE ''
			END [Орг_проверку_пломбы]
			,CASE
				WHEN P.Состояние=0 THEN 'Установлено'
				WHEN P.Состояние=1 THEN 'Не нарушено'
				WHEN P.Состояние=2 THEN 'Нарушено'
				ELSE ''
			END [Сост_пломбы]
FROM TNS_Kuban_fl_522.stack.[Лицевые счета] AS LS
JOIN TNS_Kuban_fl_522.stack.[Лицевые иерархия] AS LI ON LI.Потомок=LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Показания счетчиков] PS ON LI.Родитель = ps.[Показания-Счет] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Документ] ODPU  ON ODPU.[ROW_ID] = ps.[Показания-Документ] AND ODPU.[Тип документа] = 77 AND ps.Тип = 6 AND ODPU.ВидСчета = 0
LEFT JOIN TNS_Kuban_fl_522.stack.[Список объектов] SOODPU ON SOODPU.[Объекты-Групповой]=ODPU.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства SLS ON SLS.[Счет-Параметры]=LS.ROW_ID
	AND SLS.[Виды-Параметры]=76
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTS ON OPTS.[Счет-Параметры]=LS.ROW_ID 
	AND OPTS.[Виды-Параметры]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[Виды параметров] AS VPD
		WHERE VPD.Название='ТИПСТРОЙ'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTSH ON OPTSH.[Счет-Параметры]=LI.Родитель 
	AND OPTSH.[Виды-Параметры]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[Виды параметров] AS VPD
		WHERE VPD.Название='ТИПСТРОЙ'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства TU ON TU.[Счет-Параметры]=LS.ROW_ID 
	AND OPTSH.[Виды-Параметры]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[Виды параметров] AS VPD
		WHERE VPD.Название='ЮРЛИЦО'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.[Карточки регистрации] CR ON CR.[Счет-Наниматель]=LS.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства US ON US.[Счет-Параметры]=LS.ROW_ID
	AND US.[Виды-Параметры]=(
	SELECT TOP 1 VP.ROW_ID
	FROM TNS_Kuban_fl_522.stack.[Виды параметров] VP
	WHERE VP.Название='НТВ_ИСЧ_ЭЛ'
	)
LEFT JOIN TNS_Kuban_fl_522.[stack].[Список объектов] SO ON SO.[Объекты-Счет] = LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.[Состояние счетчика] SS
	ON SS.[Счет-Счетчика состояние]=SO.[Объекты-Счет] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Номенклатура] NOM ON SO.[Номенклатура-Объекты]=nom.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства ASK ON ASK.[Объекты-Параметры]=SO.ROW_ID
	AND ASK.[Виды-Параметры]=2395
LEFT JOIN TNS_Kuban_fl_522.stack.[Значения параметров] CT
	ON CT.[Ном-Параметры]=NOM.ROW_ID
	AND CT.[Параметр-Значения]=23
LEFT JOIN TNS_Kuban_fl_522.stack.[Значения параметров] KF
	ON KF.[Ном-Параметры]=NOM.ROW_ID
	AND KF.[Параметр-Значения]=24
LEFT JOIN TNS_Kuban_fl_522.stack.[Значения параметров] TOK
	ON TOK.[Ном-Параметры]=NOM.ROW_ID
	AND TOK.[Параметр-Значения]=27
LEFT JOIN TNS_Kuban_fl_522.stack.[Значения параметров] NAPR
	ON NAPR.[Ном-Параметры]=NOM.ROW_ID
	AND NAPR.[Параметр-Значения]=28
LEFT JOIN TNS_Kuban_fl_522.stack.[Значения параметров] MPI
	ON MPI.[Ном-Параметры]=NOM.ROW_ID
	AND MPI.[Параметр-Значения]=60
LEFT JOIN (
			SELECT pvt_adrs.Потомок AS ROW_ID,
					CITY.Сокращение AS [Тип НП],
					CITY.Название AS [Населенный пункт],
					STREET.Сокращение AS [Тип улицы],
					STREET.Название AS Улица,
					HOUSE.Номер AS Дом,
					HOUSE.Фамилия AS Корпус,
					FLAT.Номер AS Квартира,
					FLAT.Фамилия AS [Литерал квартиры],
					ROOM.Фамилия AS Комната
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
					FROM TNS_Kuban_fl_522.stack.[Лицевые иерархия] AS LI
					JOIN TNS_Kuban_fl_522.stack.[Лицевые счета] AS LS
						ON LI.Родитель=LS.ROW_ID
					LEFT JOIN TNS_Kuban_fl_522.stack.Города AS CY
						ON LS.[Улица-Лицевой счет]=CY.ROW_ID
					LEFT JOIN TNS_Kuban_fl_522.stack.Организации AS ORG
						ON ORG.ROW_ID=LS.[Счет-Линейный участок] 
				) AS pvt_adrs
			PIVOT (
					MAX(Адрес) FOR pvt_adrs.РодительТип IN ([12],[13],[11],[2],[3],[4],[5])
				  ) AS pvt_adrs
					LEFT JOIN TNS_Kuban_fl_522.stack.Города AS CITY
						ON CITY.ROW_ID=CAST([12] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.Города AS STREET
						ON STREET.ROW_ID=CAST([2] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[Лицевые счета] AS HOUSE
						ON HOUSE.ROW_ID=CAST([3] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[Лицевые счета] AS FLAT
						ON FLAT.ROW_ID=CAST([4] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[Лицевые счета] AS ROOM
						ON ROOM.ROW_ID=CAST([5] AS int)) AS AD 
					ON AD.ROW_ID=LS.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.Телефоны PH
	ON PH.[Счет-Телефон]=LS.ROW_ID AND PH.Флаги=2
LEFT JOIN stack.Телефоны AV
	ON AV.[Счет-Телефон]=LS.ROW_ID AND AV.Флаги=3
LEFT JOIN TNS_Kuban_fl_522.stack.Телефоны SMS
	ON SMS.[Счет-Телефон]=LS.ROW_ID AND SMS.Флаги=1
LEFT JOIN TNS_Kuban_fl_522.stack.[Телефоны]  EM
	ON EM.[Счет-Телефон]=LS.ROW_ID AND EM.Флаги=4 
LEFT JOIN TNS_Kuban_fl_522.stack.[Управляющие компании]  UK_DOM
		ON UK_DOM.[Счет-УК]=LI.Родитель 
LEFT JOIN TNS_Kuban_fl_522.stack.[УК Договоры]  UKDOG_DOM
	ON UKDOG_DOM.ROW_ID=UK_DOM.[Дом-УКДоговор] 
LEFT JOIN TNS_Kuban_fl_522.stack.Организации  ORG
	ON UK_DOM.[Организация-УК]=ORG.ROW_ID
OUTER APPLY(
			SELECT TOP 1  PL.[Пломба-Объект]
			,PL.[Дата установки]
			,PL.[Кто установил]
			,PL.Состояние
			FROM TNS_Kuban_fl_522.stack.[Пломбы]  PL
			WHERE PL.[Пломба-Объект]=SO.ROW_ID 
			ORDER BY PL.[Дата установки] DESC
		) AS P 
WHERE LI.ПотомокТип=5 AND (@ТолькоИстекшие = 0
    OR  
   (SO.ROW_ID IS NOT NULL AND @Дата  >= DATEADD (year, CAST(MPI.Значение AS int), SO.ДатаПоверки)))
GROUP BY  LS.Номер,ODPU.Номер,US.Значение,OPTS.Значение,OPTSH.Значение,SLS.Значение,AD.[Населенный пункт],AD.Улица,AD.Дом,AD.Квартира,AD.Комната, CR.ФИО,nom.Наименование,SO.ДатНач,
SS.Состояние,NOM.Наименование,SO.ЗаводскойНомер,SO.Разрядность,SO.Тарифность,SO.[Коэффициент трансформации] ,SO.ГодВыпуска ,SO.ДатаПоверки  ,MPI.Значение ,SO.ДатаСледующейПоверки 
,CT.Значение ,TOK.Значение ,KF.Значение ,NAPR.Значение,so.[Место установки],NOM.НомНомер ,ASK.Значение  ,SMS.Номер ,PH.Номер ,EM.Номер,ORG.Название ,UKDOG_DOM.Номер,SO.Примечание 
,P.[Дата установки], P.[Кто установил],P.Состояние
ORDER BY AD.Филиал, AD.Участок 