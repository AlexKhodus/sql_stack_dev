/*IF OBJECT_ID(N'tempdb..#temp_excel', N'U') IS NOT NULL
   DROP TABLE #temp_excel

   CREATE TABLE #temp_excel
(
	[������������]			INT,
	[����� ��]			    BIGINT,
	[����� ��]              VARCHAR(256)
	--[��� ��]				VARCHAR(256)
);

CREATE NONCLUSTERED INDEX [NCI_Main] ON #temp_excel ([����� ��], [����� ��]) ;

WITH Excel AS (
	SELECT
		CAST([������������]	AS INT) AS [������������],
		LOWER(RTRIM(LTRIM(CAST([����� ��] AS BIGINT)))) AS [����� ��],
        LOWER(RTRIM(LTRIM(CAST([����� ��] AS varchar(256))))) AS [����� ��]
	--	LOWER(RTRIM(LTRIM(CAST([��� ��] AS varchar(256))))) AS [��� ��]
    FROM OPENROWSET(
        'Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0;Database=G:\Bulk\�����.xlsx',
        'Select * from [����1$]'
    )) 

INSERT INTO #temp_excel (
	 [������������]			
	,[����� ��]      
	,[����� ��]			 
)
SELECT *
FROM  Excel;
*/

CREATE TABLE [dbo].[temp_askue_HodusAL_20210218] (
	������������   INT,
	����           INT,
	�������        INT,
	�����          BIGINT,
	�������������� VARCHAR(256)
)

INSERT INTO [dbo].[temp_askue_HodusAL_20210218] (������������, ����, �������, �����, ��������������)
SELECT 
	T.������������, 
	LS.ROW_ID,
	SO.ROW_ID,
	LS.�����, 
	SO.��������������
FROM stack.[������� �����] LS 
JOIN stack.[������ ��������] SO ON LS.ROW_ID = SO.[�������-����] 
JOIN #temp_excel AS T 
  ON LS.����� = T.[����� ��]
     AND SO.�������������� = T.[����� ��]
LEFT JOIN stack.�������� S 
 ON S.[�������-���������] = SO.ROW_ID 
    AND S.[����-���������] = 2395
	AND '20210201' BETWEEN S.������ AND S.������
WHERE ISNULL(S.��������, 0) != 2
  AND LS.��� = 5
ORDER BY T.������������

INSERT INTO [stack].[��������] (
	[����-���������], [������] ,[������], [�������-���������], [��������], [����2], [����3], [����������]
)
OUTPUT Inserted.row_id INTO [dbo].[temp_askueInserted_HodusAL_20210812]
SELECT 
	2395, '20210218', '20450509', �������, 2, 0, 0, ''
FROM [dbo].[temp_askue_HodusAL_20210218]


SELECT * 
FROM [stack].[��������]
WHERE ROW_ID IN (SELECT ROW_ID FROM [dbo].[temp_askueInserted_HodusAL_20210812])




