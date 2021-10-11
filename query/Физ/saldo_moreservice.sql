USE tns_kuban_fl_dev;
DECLARE @date datetime='20200301';
SELECT 
		PVT.Счет
	  , PVT.[Номер услуги]
	  , ISNULL(PVT.[3], ' ') AS [Входящее сальдо]
	  , ISNULL(PVT.[1], ' ') AS [Начислено]
	  , ISNULL(PVT.[2], ' ') AS [Исходящее сальдо]
	  , ISNULL(PVT.[4], ' ') AS [Перерасчет]
FROM
	(
		SELECT 		NT.Счет
					, NT.[Номер услуги]
					, NT.Сумма
					, 1 AS _TYPE_
				FROM stack.НТариф AS NT
				WHERE NT.Счет IN (164171) AND NT.[Месяц расчета]=@date
		UNION
				SELECT NS.Счет
					 , NS.[Номер услуги]
					 , SUM(NS.Сумма) AS Summa
					 , 2 AS _TYPE_
				FROM stack.НСальдо AS NS
				WHERE NS.Счет IN (164171) AND NS.[Месяц расчета]=@date
				GROUP BY NS.Счет, NS.[Номер услуги]
		UNION
				SELECT VS.Счет
					 , VS.[Номер услуги]
					 , SUM(VS.Сумма) AS Summa
					 , 3 AS _TYPE_
				FROM stack.НСальдо AS VS
				WHERE VS.Счет IN (164171) AND VS.[Месяц расчета]=DATEADD(mm, -1, @date)
				GROUP BY VS.Счет, VS.[Номер услуги]
		UNION
				SELECT NP.Счет
					 , NP.[Номер услуги]
					 , SUM(NP.Сумма) AS Summa
					 , 4 AS _TYPE_
				FROM stack.НПТариф AS NP
				WHERE NP.[Месяц расчета]=@date AND NP.Счет IN (164171)
				GROUP BY NP.Счет, NP.[Номер услуги], NP.Объем
	) as PVT_SUM
PIVOT (max(PVT_SUM.Сумма)
		FOR _TYPE_ IN ([1], [2], [3], [4])) AS PVT