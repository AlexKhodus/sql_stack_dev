--убрать двойные пробелы адресах ТУ действующих,  по всем категориям
DECLARE @Дата  DATE = '20210527';
IF OBJECT_ID(N'tempdb..#temp_address', N'U') IS NOT NULL
      DROP TABLE #temp_address
CREATE TABLE #temp_address(
	НомерТУ bigint,
	Адрес   NVARCHAR(max)
)
INSERT INTO #temp_address(НомерТУ, Адрес)

SELECT	L.Номер,
		(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(L.АдресЛС, ' ', '<>'), '><', ''), '<>', ' '), ' ,', ',')))) AS АдресЛС
FROM [stack].[Лицевые счета] AS L
	JOIN stack.[Лицевые договора] AS LD ON LD.Лицевой=L.ROW_ID AND @Дата BETWEEN LD.ДатНач AND LD.ДатКнц
	JOIN stack.Договор AS D ON LD.Договор=D.ROW_ID 



SELECT *
FROM #temp_address

--UPDATE stack.[Лицевые счета]
--SET АдресЛС=T.Адрес
--OUTPUT deleted.Номер,
--	   deleted.АдресЛС
--INTO  [dbo].[addressTU_khodusAL_16062021]
--FROM #temp_address  AS T
--WHERE Номер=T.НомерТУ

