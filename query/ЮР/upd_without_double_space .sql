--������ ������� ������� ������� �� �����������,  �� ���� ����������
DECLARE @����  DATE = '20210527';
IF OBJECT_ID(N'tempdb..#temp_address', N'U') IS NOT NULL
      DROP TABLE #temp_address
CREATE TABLE #temp_address(
	������� bigint,
	�����   NVARCHAR(max)
)
INSERT INTO #temp_address(�������, �����)

SELECT	L.�����,
		(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(L.�������, ' ', '<>'), '><', ''), '<>', ' '), ' ,', ',')))) AS �������
FROM [stack].[������� �����] AS L
	JOIN stack.[������� ��������] AS LD ON LD.�������=L.ROW_ID AND @���� BETWEEN LD.������ AND LD.������
	JOIN stack.������� AS D ON LD.�������=D.ROW_ID 



SELECT *
FROM #temp_address

--UPDATE stack.[������� �����]
--SET �������=T.�����
--OUTPUT deleted.�����,
--	   deleted.�������
--INTO  [dbo].[addressTU_khodusAL_16062021]
--FROM #temp_address  AS T
--WHERE �����=T.�������

