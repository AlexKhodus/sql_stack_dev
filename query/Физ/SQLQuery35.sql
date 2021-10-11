DECLARE @����           DATE = '20200720',
		@�������������� BIT  = 0;

DECLARE @������������������� INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '��������'),
		@�����������������   INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '���������'),
        @�������������       INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '�����');

IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
   DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    ���_����  VARCHAR(256),
    ���       BIT,
    �������   INT,
	��������� INT,
    ��������  INT
);
WITH ���� (���������, �����, ���) AS (
	SELECT
		D.row_id,
        D.�����,
		0
	FROM [stack].[��������] AS D 
	JOIN [stack].[������ ��������] AS SO ON D.row_id = SO.[�������-���������]
	JOIN [stack].[������������] AS N ON N.row_id = SO.[������������-�������]
	JOIN [stack].[��������� ��������] AS SS ON SO.row_id = SS.[������-���������]
	WHERE D.[��� ���������] = 77
	  AND D.�����_ADD = 1
	  AND ISNULL(D.����������������, 0) = 0
	  AND ISNULL(D.��������, 0) = 0
	  AND ISNULL(N.�������������, 0) = 0
	  AND @���� BETWEEN SO.������ AND SO.������
	  AND @���� BETWEEN SS.������ AND SS.������
	  AND SS.��������� = 1  
		
		UNION ALL
	
	SELECT 
		D.row_id,
        D.�����,
		1
	FROM [stack].[��������] AS D
	JOIN [stack].[��������] AS O 
	  ON O.[��������-���������] = D.row_id
		AND @���� BETWEEN O.������ AND O.������
		AND O.[����-���������] = @�����������������
	WHERE D.[��� ���������] = 77
	  AND D.�����_ADD = 1
	  AND ISNULL(D.����������������, 0) = 1
	  AND ISNULL(D.��������, 0) = 0
	  AND O.�������� = 0
), ����������� AS (
    SELECT TOP(1) WITH TIES
        LI.�������,
        O.�������� AS ��������
    FROM [stack].[������� ��������] AS LI
	JOIN [stack].[��������] AS O 
	  ON O.[����-���������] = LI.��������
		 AND O.[����-���������] = @�������������������
		 AND @���� BETWEEN O.������ AND O.������
	WHERE LI.���������� = 3
	ORDER BY ROW_NUMBER() OVER (PARTITION BY LI.������� ORDER BY �������)
), ������� AS (
    SELECT DISTINCT
        D.�����,
		D.���������,
        D.���,
        LI.�������� AS �������
    FROM ���� AS D
    JOIN [stack].[��������� ���������] AS PS 
      ON PS.[���������-��������] = D.���������
         AND PS.��� = 6
    JOIN [stack].[������� ��������] AS LI ON LI.�������� = PS.[���������-����]
    WHERE LI.���������� = 3
	AND LI.�����������=3
)
INSERT INTO #temp_accounts (���_����, ���, �������,���������, ��������)
SELECT
    LS.�����, 
    LS.���, 
    LS.�������,
	LS.���������,
    T.��������
FROM ������� AS LS
LEFT JOIN ����������� AS T ON T.������� = LS.�������
CREATE INDEX NCI_������� ON #temp_accounts (�������);
IF OBJECT_ID(N'tempdb..#temp_counters', N'U') IS NOT NULL
    DROP TABLE #temp_counters;
CREATE TABLE #temp_counters (
	[�������]                   INT,
	[������������]              VARCHAR(256),
	[��������]                  VARCHAR(256),
	[��������������]            VARCHAR(256),
	[����_���������]            DATE,
	[�����������]               DATE,
	[���]                       VARCHAR(256),
	[��������������������]      DATE,
	[����� ��������]            VARCHAR(256),
	[�����������]               TINYINT,
	[����������]                DATE,
	[����������]                INT,
	--�����������
	[����� ���������]           INT,
	--��������� �����������
	[����������]                VARCHAR(256),
	[�����]                     INT,
	[���������]                 INT,
    [����������������]          BIT,
);
WITH ����������������� AS (
    SELECT 
        ������������,
        [60] AS ���,
        [23] AS [����� ��������]
    FROM (            
		SELECT 
            [���-���������] AS ������������,
            [��������-��������] AS ��������, 
            ��������
        FROM stack.[�������� ����������]
        WHERE [��������-��������] IN (23, 60)
    ) AS T
    PIVOT ( 
        MAX(��������) FOR �������� IN ([60], [23])
    ) AS PVT
)
INSERT INTO #temp_counters (
	[�������],
	[������������],
	[��������],
	[��������������],
	[����_���������],
	[�����������],
	[���],
	[��������������������],
	[����� ��������],
	[�����������],
	[����������],
	[����������],
	--�����������
	[����� ���������],
	--��������� �����������
	[����������],
	[�����],
	[���������],
	[����������������]
)
SELECT 
    A.�������,
	F.������������,
	F.��������,
	F.��������������,
    F.������, 
	F.�����������,
	PS.���,
	F.��������������������,
	PS.[����� ��������],
	F.�����������, 
    F.����������,
	F.����������,
	--�����������
	F.[����� ���������],
	--���������
	F.����������,
	ASK.��������,
	F.���������,  
    IIF(@���� >= DATEADD (YEAR, CAST(PS.��� AS INT), F.�����������), 1, 0)
FROM #temp_accounts AS A
CROSS APPLY
(
	SELECT 
        SO.ROW_ID AS so_row,
        SO.������, 
		SS.���������, 
        SO.��������������,
        SO.�����������,
        SO.����������,
        SO.[����������� �������������],
        SO.����������,
        SO.�����������,
        so.[����� ���������],
        SO.����������,
        SO.��������������������,
        NOM.ROW_ID AS nom_row,
        NOM.������������,
        NOM.��������
	FROM stack.[������ ��������] AS SO 
	JOIN stack.[��������� ��������] SS
	  ON SS.[������-���������] = SO.row_id
         AND @���� BETWEEN SS.������ AND SS.������
	JOIN [stack].[������������] NOM ON SO.[������������-�������] = nom.ROW_ID
	WHERE SO.[�������-���������] = A.���������
	  AND @���� BETWEEN SO.������ AND SO.������
	  AND ISNULL(NOM.�������������, 0) = 0
	  --AND NOM.�������������= 1
	--ORDER BY SO.������ DESC
) AS F
OUTER APPLY(
	SELECT TOP (1) SSC.������
	FROM stack.[��������� ��������] AS SSC
	WHERE @����>SSC.������
	AND
	SSC.���������=1 
	AND SSC.[������-���������]=F.so_row
	ORDER BY SSC.������ 
	) AS SSC
LEFT JOIN ����������������� AS PS ON PS.������������ = F.nom_row
LEFT JOIN stack.[��������] AS ASK 
  ON ASK.[�������-���������]=F.so_row
     AND @���� BETWEEN ASK.������ AND ASK.������
	 AND ASK.[����-���������] = @�������������;

WITH ����� AS(
SELECT 
        PVT.[�������] AS row_id,  
        PVT.[0] AS [������],
        PVT.[1] AS [�������],
        PVT.[12] AS [���������� �����], 
        PVT.[2] AS [�����], 
        PVT.[3] AS [���]
	FROM (
        SELECT
			LI.�������,
			LI.�����������,
			CASE WHEN LI.����������� = 0        THEN L.�������
				 WHEN LI.����������� = 1        THEN O.��������
				 WHEN LI.����������� IN (12, 2) THEN IIF(C.��_����� = 1, CONCAT(C.��������, ' ', C.����������), CONCAT(C.����������, ' ', C.��������))
				 WHEN LI.����������� = 3  THEN CAST(L.����� AS NVARCHAR(12)) 
			END AS �����
	    FROM stack.[������� ��������] AS LI
	    JOIN stack.[������� �����] AS L ON LI.�������� = L.row_id
	    LEFT JOIN stack.[������] AS C ON L.[�����-������� ����] = C.row_id
	    LEFT JOIN stack.[�����������] AS O ON O.row_id = L.[����-�������� �������]
	    WHERE LI.���������� = 3 AND ����������� IN (0, 1, 12, 2, 3)
	) AS T
	PIVOT
	(
		MAX(�����) FOR ����������� IN([0], [1], [12], [2], [3])
	) AS PVT),

������������������� AS (
    SELECT 
        A.�������,
        MAX(O.��������) AS [����_��],
        MAX(CAST(D.����� AS VARCHAR(256))) AS [���_���_��],
		MAX(ORG.��������) AS [����_������],
		(O.�������) AS [���_��]
	FROM #temp_accounts AS A
    JOIN [stack].[������� ��������] AS LI ON LI.�������� = A.�������
	JOIN [stack].[����������� ��������] AS U 
      ON U.[����-��] = LI.��������
		 AND @���� BETWEEN U.������ AND U.������
    JOIN stack.����������� AS O ON U.[�����������-��] = O.row_id
    LEFT JOIN stack.[�� ��������] AS D 
      ON D.row_id = U.[���-���������] 
         AND @���� BETWEEN D.������ AND D.������
	LEFT JOIN stack.���������� AS PS
		ON PS.[����-������ �����������]=LI.��������
		AND @���� BETWEEN PS.������ AND PS.������
	JOIN stack.����������� AS ORG ON PS.[����������-������] = ORG.row_id
    GROUP BY A.�������, O.�������
) 
SELECT  LS.���_���� 
		,U.���_���_��
		,U.����_��
		,AD.[���������� �����] AS [���_�����]
		,AD.�����
		,AD.���
		,U.����_������
		,AD.������
		,AD.�������
		,C.������������ AS [������������_��]
		,C.�������� AS [���_�����]
		,C.�������������� AS [���_�����]
		,FORMAT(C.[����_���������], 'dd.MM.yyyy') AS [����_���������]
		,CHOOSE(C.���������, '��������', '����������� �� ��������', '�� ��������') AS [���������_��]
		,CONVERT( nvarchar, C.�����������) �����������
		,CONVERT( nvarchar, C.����������) ����������
		,FORMAT(C.����������, 'dd.MM.yyyy') AS [���_�������]
		,FORMAT(C.�����������, 'dd.MM.yyyy') AS [����_�������]
		,C.��� AS ���
		,FORMAT(C.��������������������, 'dd.MM.yyyy') AS [����_����_�������]
		,C.[����� ��������] AS [�����_��������]
		,C.�����������
		,C.����������
		,C.����������
		,C.[����� ���������]
		,C.����������
		,C.�����
FROM #temp_accounts AS LS
LEFT JOIN #temp_counters AS C ON C.������� = LS.�������
LEFT JOIN ����� AS AD ON AD.row_id = LS.�������
LEFT JOIN ������������������� AS U ON U.������� = LS.�������

ORDER BY LS.���_����