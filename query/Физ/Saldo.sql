USE tns_kuban_fl_dev;
DECLARE @date datetime = '20200301';
SELECT	LS.Номер
		, NT.[Номер услуги]
		, NT.Сумма
		, NT.Объем
		, NS.Summa AS [Исходящее сальдо]
		, VS.Summa AS [Входящее сальдо]
		, NP.Summa AS [Перерасчет]
		, NP.Объем AS [Перерасчет объем]
FROM stack.[Лицевые счета] AS LS
LEFT JOIN stack.НТариф AS NT ON NT.Счет=LS.ROW_ID
LEFT JOIN (
		SELECT NS.Счет, NS.[Номер услуги], SUM(NS.Сумма) AS Summa
		FROM stack.НСальдо AS NS
		WHERE NS.[Месяц расчета]=@date
		GROUP BY NS.Счет, NS.[Номер услуги]
		) AS NS ON LS.ROW_ID=NS.Счет AND NS.[Номер услуги]=NT.[Номер услуги]
LEFT JOIN (
		SELECT VS.Счет, VS.[Номер услуги], SUM(VS.Сумма) AS Summa
		FROM stack.НСальдо AS VS
		WHERE VS.[Месяц расчета]=DATEADD(mm, -1, @date)
		GROUP BY VS.Счет, VS.[Номер услуги]
		) AS VS ON LS.ROW_ID=VS.Счет AND VS.[Номер услуги]=NT.[Номер услуги]
LEFT JOIN (
		SELECT NP.Счет, NP.[Номер услуги], NP.Объем, SUM(NP.Сумма) AS Summa
		FROM stack.НПТариф AS NP
		WHERE NP.[Месяц расчета]=@date
		GROUP BY NP.Счет, NP.[Номер услуги], NP.Объем
		) AS NP ON LS.ROW_ID=NP.Счет AND NP.[Номер услуги]=NT.[Номер услуги]
WHERE LS.ROW_ID=164171 AND NT.[Месяц расчета]=@date