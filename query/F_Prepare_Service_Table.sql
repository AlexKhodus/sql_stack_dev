/*
    -- �������� �������
    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[ServiceTable_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[ServiceTable_LS_ArtemovAS](
	    [�����] [date] NOT NULL,
	    [�������] [int] NOT NULL,
        [��������] [int] NOT NULL,
	    [������] [int] NOT NULL,
        [���] [int] NOT NULL
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS]
    (
	    [�����] ASC,
        [�������] ASC,
        [��������] ASC,
	    [������] ASC,
        [���] ASC
    )
    GO

    ALTER INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] REBUILD
*/


DECLARE @DateBegin DATE = '20210401',
        @DateEnd   DATE = '20210401';

WITH Volumes AS (
    SELECT
        ����,
        [����� �������] AS �����
    FROM [stack].[������]
    WHERE [����� �������] BETWEEN @DateBegin AND @DateEnd
      AND [����� ������] - [����� ������] % 100 IN (100, 200, 400)
    --  AND ���� IN (SELECT ������� FROM stack.[������� ��������] WHERE �������� = 3272200)

        UNION ALL

    SELECT
        ����,
        [����������] AS �����
    FROM [stack].[�������]
    WHERE [����� �������] BETWEEN @DateBegin AND @DateEnd
      AND [����� ������] - [����� ������] % 100 IN (100, 200, 400)
    --  AND ���� IN (SELECT ������� FROM stack.[������� ��������] WHERE �������� = 3272200)
      --AND ���������� BETWEEN DATEFROMPARTS(DATEPART(YEAR, @DateBegin), 1, 1) AND DATEFROMPARTS(DATEPART(YEAR, @DateBegin), 12, 1) -- ����������� ������� ���
), Accounts AS (
    SELECT DISTINCT ����, �����
    FROM Volumes
), HouseTypePivot AS (
    SELECT 
        ����, �����, COALESCE([5], [4], [3]) AS ���
    FROM (
        SELECT
            A.����, LH.�����������, A.�����, O.��������
        FROM Accounts AS A
        JOIN stack.[������� ��������] AS LH ON A.���� = LH.�������
        JOIN stack.�������� AS O 
	      ON O.[����-���������] = LH.��������
	         AND O.[����-���������] = (SELECT row_id FROM stack.[���� ����������] WHERE �������� = '��������')
             AND A.����� BETWEEN O.������ AND O.������
        WHERE LH.���������� = 5 
          AND LH.����������� IN (3, 4, 5)
    ) AS T
    PIVOT( 
        MAX(��������) FOR ����������� IN ([3], [4], [5])
    ) AS PVT
), ServiceTypePivot AS (
    SELECT 
        ����, �����, COALESCE([5], [4], [3]) AS [����� ������]
    FROM (
        SELECT 
            A.����, LH.�����������, A.�����, TU.[����� ������]
        FROM Accounts AS A
        JOIN stack.[������� ��������] AS LH ON A.���� = LH.�������
        JOIN stack.[������ �����] AS SU 
          ON SU.[����-������] = LH.��������
             AND A.����� BETWEEN SU.������ AND SU.������
             AND SU.��������� = 0
        JOIN stack.[���� �����] AS TU ON TU.ROW_ID = SU.[���-������]
        WHERE LH.���������� = 5 
          AND LH.����������� IN (3, 4, 5)   
    ) AS T
    PIVOT( 
        MAX([����� ������]) FOR ����������� IN ([3], [4], [5])
    ) AS PVT
), Parent AS (
    SELECT A.����, MAX(LH.��������) AS ��������
    FROM Accounts AS A
    JOIN stack.[������� ��������] AS LH ON A.���� = LH.�������
    WHERE LH.����������� = 12
      AND LH.���������� = 5
    GROUP BY A.����
)
INSERT INTO [dbo].[ServiceTable_LS_ArtemovAS](�����, �������, ��������, ������, ���)
SELECT
    A.�����, 
    A.����,
    P.��������,
    ISNULL(ST.[����� ������], 100),
    CASE ISNULL(HT.���, 1) 
        WHEN 0 THEN 0
        WHEN 2 THEN 0  
        WHEN 1 THEN 1 
        ELSE 2 
    END
FROM Accounts AS A
JOIN Parent AS P ON P.���� = A.����
LEFT JOIN HouseTypePivot AS HT ON A.���� = HT.���� AND A.����� = HT.�����
LEFT JOIN ServiceTypePivot AS ST ON A.���� = ST.���� AND A.����� = ST.�����
OPTION (RECOMPILE);

ALTER INDEX [IDX_main] ON [dbo].[ServiceTable_LS_ArtemovAS] REBUILD;