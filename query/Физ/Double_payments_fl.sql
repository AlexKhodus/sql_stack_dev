 IF OBJECT_ID(N'tempdb..#TypePayments', N'U') IS NOT NULL
      DROP TABLE #TypePayments

   CREATE TABLE #TypePayments
				 (
				[������� ����]		BIGINT,
				�����				FLOAT
					  );

INSERT INTO #TypePayments 
SELECT 
    LC, 
	SUM
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=g:\Bulk\20210813AP1.xlsx',
    'select * from [20210813AP1$]')
	 

WITH ������ AS (
SELECT LS.�����,V.ROW_ID As �������, D.ROW_ID AS �����,SO.ROW_ID, SO.�����, SO.����
FROM [stack].[��������] AS V
JOIN [stack].[��������] AS D ON D.[������-�������] = V.row_id
JOIN [stack].[������ ������] AS SO ON SO.[������-������] = D.row_id
JOIN stack.[������� �����] AS LS ON LS.ROW_ID=SO.[����-������]
WHERE V.row_id = 2968142
GROUP By LS.�����,V.ROW_ID , D.ROW_ID ,SO.ROW_ID, SO.�����, SO.����
)
SELECT  *
FROM ������ AS O
JOIN #TypePayments AS P ON P.[���� �������]=O.���� AND P.[������� ���� �������]=O.����� AND P.�����=O.�����

WITH ������ AS (
SELECT LS.�����, SO.�����, SO.����
FROM [stack].[��������] AS V
JOIN [stack].[��������] AS D ON D.[������-�������] = V.row_id
JOIN [stack].[������ ������] AS SO ON SO.[������-������] = D.row_id
JOIN stack.[������� �����] AS LS ON LS.ROW_ID=SO.[����-������]
LEFT JOIN [stack].[��������� ���������] AS PS ON PS.[������-��������] = SO.row_id
--WHERE V.row_id = 2968142
)
SELECT  *
FROM ������ AS O
JOIN #TypePayments AS P ON P.[���� �������]=O.���� AND P.[������� ���� �������]=O.����� AND P.�����=O.�����


SELECT *
FROM stack.��������
WHERE ROW_ID=2968142

SELECT *
FROM #TypePayments
