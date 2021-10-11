/*IF OBJECT_ID(N'tempdb..#temp_excel', N'U') IS NOT NULL
   DROP TABLE #temp_excel

   CREATE TABLE #temp_excel
(
	[Соответствие]			INT,
	[номер ЛС]			    BIGINT,
	[номер ПУ]              VARCHAR(256)
	--[Вид ПУ]				VARCHAR(256)
);

CREATE NONCLUSTERED INDEX [NCI_Main] ON #temp_excel ([номер ЛС], [номер ПУ]) ;

WITH Excel AS (
	SELECT
		CAST([Соответствие]	AS INT) AS [Соответствие],
		LOWER(RTRIM(LTRIM(CAST([номер ЛС] AS BIGINT)))) AS [номер ЛС],
        LOWER(RTRIM(LTRIM(CAST([номер ПУ] AS varchar(256))))) AS [номер ПУ]
	--	LOWER(RTRIM(LTRIM(CAST([Вид ПУ] AS varchar(256))))) AS [Вид ПУ]
    FROM OPENROWSET(
        'Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=G:\Bulk\аскуэ.xlsx',
        'Select * from [Лист1$]'
    )) 

INSERT INTO #temp_excel (
	 [Соответствие]			
	,[номер ЛС]      
	,[номер ПУ]			 
)
SELECT *
FROM  Excel;
*/

CREATE TABLE [dbo].[temp_askue_HodusAL_20210218] (
	Соответствие   INT,
	Счет           INT,
	Счетчик        INT,
	Номер          BIGINT,
	ЗаводскойНомер VARCHAR(256)
)

INSERT INTO [dbo].[temp_askue_HodusAL_20210218] (Соответствие, Счет, Счетчик, Номер, ЗаводскойНомер)
SELECT 
	T.Соответствие, 
	LS.ROW_ID,
	SO.ROW_ID,
	LS.Номер, 
	SO.ЗаводскойНомер
FROM stack.[Лицевые счета] LS 
JOIN stack.[Список объектов] SO ON LS.ROW_ID = SO.[Объекты-Счет] 
JOIN #temp_excel AS T 
  ON LS.Номер = T.[номер ЛС]
     AND SO.ЗаводскойНомер = T.[номер ПУ]
LEFT JOIN stack.Свойства S 
 ON S.[Объекты-Параметры] = SO.ROW_ID 
    AND S.[Виды-Параметры] = 2395
	AND '20210201' BETWEEN S.ДатНач AND S.ДатКнц
WHERE ISNULL(S.Значение, 0) != 2
  AND LS.Тип = 5
ORDER BY T.Соответствие

INSERT INTO [stack].[Свойства] (
	[Виды-Параметры], [ДатНач] ,[ДатКнц], [Объекты-Параметры], [Значение], [Знач2], [Знач3], [Примечание]
)
OUTPUT Inserted.row_id INTO [dbo].[temp_askueInserted_HodusAL_20210812]
SELECT 
	2395, '20210218', '20450509', Счетчик, 2, 0, 0, ''
FROM [dbo].[temp_askue_HodusAL_20210218]


SELECT * 
FROM [stack].[Свойства]
WHERE ROW_ID IN (SELECT ROW_ID FROM [dbo].[temp_askueInserted_HodusAL_20210812])




