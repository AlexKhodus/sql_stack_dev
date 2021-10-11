
DECLARE @date datetime='20200601'
SELECT 
	  LS.Номер [Номер_ЛС]
	  ,ISNULL(ODPU.Номер,'') [Код_ОДПУ]
	  ,'Да' [Признак_нал_дог]
	  ,CASE
			WHEN SLS.Значение=0 THEN 'Используется'
			WHEN SLS.Значение=1 THEN 'Не проживает'
	   END [Сост_ЛС]
	  ,CASE
			WHEN ISNULL(OPTS.Значение,OPTSH.Значение)=0 THEN 'Многоквартирный'
			WHEN ISNULL(OPTS.Значение,OPTSH.Значение)=2 THEN 'Общежитие'
			ELSE ''
	   END [Тип_строения]
		,AD.Филиал
		,AD.Участок		
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
			WHEN SS.Состояние = 0 THEN 'Не используется'
			WHEN SS.Состояние = 1 THEN 'Работает'
			WHEN SS.Состояние = 2 THEN 'Начисляется по среднему'
			WHEN SS.Состояние = 3 THEN 'Отключен ввод'
			ELSE ''
		  END [Состояние_ПУ]
		 ,NOM.Наименование [Наименование_ПУ]
		 ,ISNULL(SO.ЗаводскойНомер,'') [Номер_ПУ]
		 ,ISNULL(SO.Разрядность,'') Разрядность
		 ,ISNULL(SO.Тарифность,'') Тарифность
		 ,ISNULL(SO.[Коэффициент трансформации],'') [Коэф_трансф]
		 ,ISNULL(SO.ГодВыпуска,'') [Год_выпуска]
		 ,CONVERT(VarChar(50), SO.ДатаПоверки, 104) [Дата_пред_поверки]
		 ,ISNULL(MPI.Значение,'') [МПИ]
		 ,CONVERT(VarChar(50), SO.ДатаСледующейПоверки, 104)  [Дата_след_поверки]
		 ,ISNULL(CT.Значение,'') [Класс_точности]
		 ,ISNULL(TOK.Значение,'') [Ток_пу]
		 ,ISNULL(KF.Значение,'') [Кол_во_фаз_счетчика]
		 ,ISNULL(NAPR.Значение,'') [Напр_пу]
			  ,CASE 
				WHEN (SO.[Место установки]=0) THEN 'На опоре'
				WHEN (SO.[Место установки]=1) THEN 'Лестничная площадка'
				WHEN (SO.[Место установки]=2) THEN 'Квартира'
				WHEN (SO.[Место установки]=3) THEN 'Комната'
				WHEN (SO.[Место установки]=4) THEN 'Жилой дом'
				WHEN (SO.[Место установки]=5) THEN 'Подъезд'
				WHEN (SO.[Место установки]=6) THEN 'Гараж'
				WHEN (SO.[Место установки]=7) THEN 'Сарай'
				WHEN (SO.[Место установки]=8) THEN 'Фасад здания'
				WHEN (SO.[Место установки]=9) THEN 'Тумба в подъезде МЖД'
				WHEN (SO.[Место установки]=10) THEN 'Веранда'
				WHEN (SO.[Место установки]=11) THEN 'ВРУ МКД'
				WHEN (so.[Место установки]=12) THEN 'РУ ТП'
				ELSE 'Не указано'
			 end [Место_установки_ПУ]
			,ISNULL(NOM.НомНомер, '') [Номенкл_номер]
			,CASE
				 WHEN ASK.Значение=0 THEN 'Возможность подключения имеется' 
				 WHEN ASK.Значение=1 THEN 'Сбор показаний' 
				 WHEN ASK.Значение=2 THEN 'Дистанционное ограничение и отключение' 
				 ELSE ''
			 END [АСКУЭ] 
			,[stack].[CLR_Concat]
			(ISNULL(SMS.Номер, '')) [смс]
			,[stack].[CLR_Concat]
			(ISNULL(AV.Номер, '')) [автообзвон]
			,[stack].[CLR_Concat]
			(ISNULL(PH.Номер, '')) [Телефон]
			,[stack].[CLR_Concat]
			(ISNULL(EM.Номер, '')) [E_MAIL]
			,ISNULL(ORG.Название, '')  [Наим_УК]
			,ISNULL(UKDOG_DOM.Номер,'')  [Ном_Дог_УК]
			,SO.Примечание [Прим_к_месту_ПУ]
			,CONVERT(VarChar(50), P.[Дата установки], 104)  [Дата_посл_пломбы]
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
FROM stack.[Лицевые счета] LS
JOIN stack.[Лицевые иерархия] LI ON LI.Потомок=LS.ROW_ID AND LI.РодительТип=3
JOIN [stack].[Показания счетчиков] PS ON LI.Родитель = ps.[Показания-Счет] 
LEFT JOIN [stack].[Документ] ODPU  ON ODPU.[ROW_ID] = ps.[Показания-Документ] AND ODPU.[Тип документа] = 77 AND ps.Тип = 6 AND ODPU.ВидСчета = 0
JOIN (	SELECT SOODPU.[Объекты-Групповой]
		FROM stack.[Список объектов] SOODPU 
		WHERE @date BETWEEN SOODPU.ДатНач AND SOODPU.ДатКнц 
		GROUP BY SOODPU.[Объекты-Групповой]) SOODPU ON SOODPU.[Объекты-Групповой]=ODPU.ROW_ID
JOIN stack.Свойства SLS ON SLS.[Счет-Параметры]=LS.ROW_ID
	AND (@date BETWEEN SLS.ДатНач AND SLS.ДатКнц)
	AND SLS.[Виды-Параметры]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[Виды параметров] VP
		WHERE VP.Название='СОСТОЯНИЕ'
		 )
	AND SLS.Значение!=2
LEFT JOIN stack.Свойства OPTS
				ON OPTS.[Счет-Параметры]=LS.ROW_ID 
				AND OPTS.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ТИПСТРОЙ'
				 )
				 AND OPTS.Значение=2 OR OPTS.Значение=0
LEFT JOIN stack.Свойства OPTSH
				ON OPTSH.[Счет-Параметры]=LI.Родитель 
				AND OPTSH.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ТИПСТРОЙ'
				 )
				 AND OPTSH.Значение=2 OR OPTSH.Значение=0
JOIN stack.[Карточки регистрации] CR ON CR.[Счет-Наниматель]=LS.ROW_ID
LEFT JOIN stack.Свойства US ON US.[Счет-Параметры]=LS.ROW_ID
	AND (@date BETWEEN US.ДатНач AND US.ДатКнц)
	AND US.[Виды-Параметры]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[Виды параметров] VP
		WHERE VP.Название='НТВ_ИСЧ_ЭЛ'
		 )
LEFT JOIN [stack].[Список объектов] SO ON SO.[Объекты-Счет] = LS.ROW_ID AND SO.ДатКнц >= @date AND SO.ДатНач  <= @date 
LEFT JOIN stack.[Состояние счетчика] SS
				ON SS.[Счет-Счетчика состояние]=SO.[Объекты-Счет]
				AND @date BETWEEN SS.ДатНач AND SS.ДатКнц
LEFT JOIN [stack].[Номенклатура] NOM on SO.[Номенклатура-Объекты]=nom.ROW_ID
LEFT JOIN stack.Свойства ASK ON ASK.[Объекты-Параметры]=SO.ROW_ID
	AND (@date BETWEEN ASK.ДатНач AND ASK.ДатКнц)
	AND ASK.[Виды-Параметры]=2395
LEFT JOIN stack.[Значения параметров] CT
	ON CT.[Ном-Параметры]=NOM.ROW_ID
	AND CT.[Параметр-Значения]=23
LEFT JOIN stack.[Значения параметров] KF
	ON KF.[Ном-Параметры]=NOM.ROW_ID
	AND KF.[Параметр-Значения]=24
LEFT JOIN stack.[Значения параметров] TOK
	ON TOK.[Ном-Параметры]=NOM.ROW_ID
	AND TOK.[Параметр-Значения]=27
LEFT JOIN stack.[Значения параметров] NAPR
	ON NAPR.[Ном-Параметры]=NOM.ROW_ID
	AND NAPR.[Параметр-Значения]=28
LEFT JOIN stack.[Значения параметров] MPI
	ON MPI.[Ном-Параметры]=NOM.ROW_ID
	AND MPI.[Параметр-Значения]=60
JOIN (SELECT pvt_adrs.Потомок AS ROW_ID,
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
			LEFT JOIN stack.[Лицевые счета] AS ROOM
			ON ROOM.ROW_ID=CAST([5] AS int)) AS AD ON AD.ROW_ID=LS.ROW_ID
LEFT JOIN stack.Телефоны PH
	ON PH.[Счет-Телефон]=LS.ROW_ID AND PH.Флаги=2
LEFT JOIN stack.Телефоны SMS
	ON SMS.[Счет-Телефон]=LS.ROW_ID AND SMS.Флаги=1	
LEFT JOIN stack.Телефоны AV
	ON AV.[Счет-Телефон]=LS.ROW_ID AND AV.Флаги=3
LEFT JOIN stack.[Телефоны]  EM
	ON EM.[Счет-Телефон]=LS.ROW_ID AND EM.Флаги=4 
LEFT JOIN stack.[Управляющие компании]  UK_DOM
		ON UK_DOM.[Счет-УК]=LI.Родитель AND LI.[РодительТип]=3 
		AND (@date BETWEEN UK_DOM.ДатНач AND UK_DOM.ДатКнц)
LEFT JOIN stack.[УК Договоры]  UKDOG_DOM
	ON UKDOG_DOM.ROW_ID=UK_DOM.[Дом-УКДоговор] AND
	@date BETWEEN UKDOG_DOM.ДатНач AND UKDOG_DOM.ДатКнц
LEFT JOIN stack.Организации  ORG
	ON UK_DOM.[Организация-УК]=ORG.ROW_ID
OUTER APPLY(
			SELECT TOP 1  PL.[Пломба-Объект]
			,PL.[Дата установки]
			,PL.[Кто установил]
			,PL.Состояние
			FROM stack.[Пломбы]  PL
			WHERE PL.[Пломба-Объект]=SO.ROW_ID 
			ORDER BY PL.[Дата установки] DESC
		) AS P 
--WHERE LS.ROW_ID IN (164171)
GROUP BY LS.Номер,ODPU.Номер,US.Значение,OPTS.Значение,OPTSH.Значение,SLS.Значение,AD.Филиал, AD.Участок, AD.[Населенный пункт],AD.Улица,AD.Дом,AD.Квартира,AD.Комната, CR.ФИО,nom.Наименование,SO.ДатНач,
SS.Состояние,NOM.Наименование,SO.ЗаводскойНомер,SO.Разрядность,SO.Тарифность,SO.[Коэффициент трансформации] ,SO.ГодВыпуска ,SO.ДатаПоверки  ,MPI.Значение ,SO.ДатаСледующейПоверки 
,CT.Значение ,TOK.Значение ,KF.Значение ,NAPR.Значение,so.[Место установки],NOM.НомНомер ,ASK.Значение,ORG.Название ,UKDOG_DOM.Номер,SO.Примечание 
,P.[Дата установки], P.[Кто установил],P.Состояние
UNION ALL
SELECT 
	  LS.Номер [Номер_ЛС]
	  ,ISNULL(ODPU.Номер,'') [Код_ОДПУ]
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
			WHEN SS.Состояние = 0 THEN 'Не используется'
			WHEN SS.Состояние = 1 THEN 'Работает'
			WHEN SS.Состояние = 2 THEN 'Начисляется по среднему'
			WHEN SS.Состояние = 3 THEN 'Отключен ввод'
			ELSE ''
		  END [Состояние_ПУ]
		 ,NOM.Наименование [Наименование_ПУ]
		 ,ISNULL(SO.ЗаводскойНомер,'') [Номер_ПУ]
		 ,ISNULL(SO.Разрядность,'') Разрядность
		 ,ISNULL(SO.Тарифность,'') Тарифность
		 ,ISNULL(SO.[Коэффициент трансформации],'') [Коэф_трансф]
		 ,ISNULL(SO.ГодВыпуска,'') [Год_выпуска]
		 ,CONVERT(VarChar(50), SO.ДатаПоверки, 104) [Дата_пред_поверки]
		 ,ISNULL(MPI.Значение,'') [МПИ]
		 ,CONVERT(VarChar(50), SO.ДатаСледующейПоверки, 104)  [Дата_след_поверки]
		 ,ISNULL(CT.Значение,'') [Класс_точности]
		 ,ISNULL(TOK.Значение,'') [Ток_пу]
		 ,ISNULL(KF.Значение,'') [Кол_во_фаз_счетчика]
		 ,ISNULL(NAPR.Значение,'') [Напр_пу]
			  ,CASE 
				WHEN (SO.[Место установки]=0) THEN 'На опоре'
				WHEN (SO.[Место установки]=1) THEN 'Лестничная площадка'
				WHEN (SO.[Место установки]=2) THEN 'Квартира'
				WHEN (SO.[Место установки]=3) THEN 'Комната'
				WHEN (SO.[Место установки]=4) THEN 'Жилой дом'
				WHEN (SO.[Место установки]=5) THEN 'Подъезд'
				WHEN (SO.[Место установки]=6) THEN 'Гараж'
				WHEN (SO.[Место установки]=7) THEN 'Сарай'
				WHEN (SO.[Место установки]=8) THEN 'Фасад здания'
				WHEN (SO.[Место установки]=9) THEN 'Тумба в подъезде МЖД'
				WHEN (SO.[Место установки]=10) THEN 'Веранда'
				WHEN (SO.[Место установки]=11) THEN 'ВРУ МКД'
				WHEN (so.[Место установки]=12) THEN 'РУ ТП'
				ELSE 'Не указано'
			 end [Место_установки_ПУ]
			,ISNULL(NOM.НомНомер, '') [Номенкл_номер]
			,CASE
				 WHEN ASK.Значение=0 THEN 'Возможность подключения имеется' 
				 WHEN ASK.Значение=1 THEN 'Сбор показаний' 
				 WHEN ASK.Значение=2 THEN 'Дистанционное ограничение и отключение' 
				 ELSE ''
			 END [АСКУЭ] 
			,[stack].[CLR_Concat]
			(ISNULL(SMS.Номер, '')) [смс]
			,[stack].[CLR_Concat]
			(ISNULL(AV.Номер, '')) [автообзвон]
			,[stack].[CLR_Concat]
			(ISNULL(PH.Номер, '')) [Телефон]
			,[stack].[CLR_Concat]
			(ISNULL(EM.Номер, '')) [E_MAIL]
			,ISNULL(ORG.Название, '')  [Наим_УК]
			,ISNULL(UKDOG_DOM.Номер,'')  [Ном_Дог_УК]
			,SO.Примечание [Прим_к_месту_ПУ]
			,CONVERT(VarChar(50), P.[Дата установки], 104)  [Дата_посл_пломбы]
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
JOIN TNS_Kuban_fl_522.stack.[Лицевые иерархия] AS LI
	ON LI.Потомок=LS.ROW_ID AND LI.РодительТип=3
LEFT JOIN TNS_Kuban_fl_522.[stack].[Показания счетчиков] PS ON LI.Родитель = ps.[Показания-Счет] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[Документ] ODPU  ON ODPU.[ROW_ID] = ps.[Показания-Документ] AND ODPU.[Тип документа] = 77 AND ps.Тип = 6 AND ODPU.ВидСчета = 0
LEFT JOIN TNS_Kuban_fl_522.stack.[Список объектов] SOODPU ON SOODPU.[Объекты-Групповой]=ODPU.ROW_ID 
JOIN TNS_Kuban_fl_522.stack.Свойства SLS ON SLS.[Счет-Параметры]=LS.ROW_ID
	AND SLS.[Виды-Параметры]=76
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTS
				ON OPTS.[Счет-Параметры]=LS.ROW_ID 
				AND OPTS.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM TNS_Kuban_fl_522.stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ТИПСТРОЙ'
				 )
LEFT JOIN TNS_Kuban_fl_522.stack.Свойства OPTSH
				ON OPTSH.[Счет-Параметры]=LI.Родитель 
				AND OPTSH.[Виды-Параметры]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM TNS_Kuban_fl_522.stack.[Виды параметров] AS VPD
					WHERE VPD.Название='ТИПСТРОЙ'
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
LEFT JOIN TNS_Kuban_fl_522.[stack].[Номенклатура] NOM on SO.[Номенклатура-Объекты]=nom.ROW_ID
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
LEFT JOIN (SELECT pvt_adrs.Потомок AS ROW_ID,
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
--Участок
			LEFT JOIN TNS_Kuban_fl_522.stack.Организации AS ORG
				ON ORG.ROW_ID=LS.[Счет-Линейный участок] 
--формирование пивот-таблицы
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
			ON ROOM.ROW_ID=CAST([5] AS int)) AS AD ON AD.ROW_ID=LS.ROW_ID
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
--WHERE LS.ROW_ID IN (1342,1344)
GROUP BY  LS.Номер,ODPU.Номер,US.Значение,OPTS.Значение,OPTSH.Значение,SLS.Значение,AD.[Населенный пункт],AD.Улица,AD.Дом,AD.Квартира,AD.Комната, CR.ФИО,nom.Наименование,SO.ДатНач,
SS.Состояние,NOM.Наименование,SO.ЗаводскойНомер,SO.Разрядность,SO.Тарифность,SO.[Коэффициент трансформации] ,SO.ГодВыпуска ,SO.ДатаПоверки  ,MPI.Значение ,SO.ДатаСледующейПоверки 
,CT.Значение ,TOK.Значение ,KF.Значение ,NAPR.Значение,so.[Место установки],NOM.НомНомер ,ASK.Значение  ,SMS.Номер ,PH.Номер ,EM.Номер,ORG.Название ,UKDOG_DOM.Номер,SO.Примечание 
,P.[Дата установки], P.[Кто установил],P.Состояние
ORDER BY AD.Филиал, AD.Участок 