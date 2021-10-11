DECLARE @����           DATE = '20200601',
        @�������������� BIT  = 0;

DECLARE @������������������� INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '��������'),
        @�����������������   INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '���������'),
        @��������������      INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '������'),
        @�����������         INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '���_���_��'),
        @�������������       INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '�����');


IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
    DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    �����_��  BIGINT, 
    ���_����  VARCHAR(256),
    ���       BIT,
    �������   INT,
    ���       VARCHAR(256),
    ��������� INT,
    ���       INT,
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
	WHERE LI.���������� = 5
	ORDER BY ROW_NUMBER() OVER (PARTITION BY LI.������� ORDER BY �������)
), ������� AS (
    SELECT DISTINCT
        D.�����,
        D.���,
        LI.������� AS �������,
        SLS.�������� AS ���������
    FROM ���� AS D
    JOIN [stack].[��������� ���������] AS PS 
      ON PS.[���������-��������] = D.���������
         AND PS.��� = 6
    JOIN [stack].[������� ��������] AS LI ON LI.�������� = PS.[���������-����]
    LEFT JOIN stack.�������� AS TU
      ON TU.[����-���������] = LI.�������
	     AND @���� BETWEEN TU.������ AND TU.������
         AND TU.[����-���������] = @��������������
    LEFT JOIN stack.�������� AS SLS
      ON SLS.[����-���������] = LI.�������
	     AND @���� BETWEEN SLS.������ AND SLS.������
         AND SLS.[����-���������] = @�����������������
    WHERE LI.���������� = 5
      AND TU.row_id IS NULL
      AND ISNULL(SLS.��������, 0) != 2
)
INSERT INTO #temp_accounts (�����_��, ���_����, ���, �������, ���, ���������, ���, ��������)
SELECT
    L.�����,
    LS.�����, 
    LS.���, 
    LS.�������,
    CR.���,
    LS.���������,
    US.��������,
    T.��������
FROM ������� AS LS
JOIN stack.[������� �����] AS L ON L.ROW_ID = LS.�������
JOIN stack.[�������� �����������] CR ON CR.[����-����������] = LS.�������
LEFT JOIN ����������� AS T ON T.������� = LS.�������
LEFT JOIN stack.�������� AS US
  ON US.[����-���������] = LS.�������
	 AND @���� BETWEEN US.������ AND US.������
     AND US.[����-���������] = @�����������
	 
WHERE L.����� IN (230202366337, 230206663699, 230206663699, 230202328489, 230405000685,230201932516);

CREATE INDEX NCI_������� ON #temp_accounts (�������);

IF OBJECT_ID(N'tempdb..#temp_counters', N'U') IS NOT NULL
    DROP TABLE #temp_counters;

CREATE TABLE #temp_counters (
	[�������]                   INT,
	[����_���������]            DATE,
	[���������]                 INT,
	[��������������]            VARCHAR(256),
	[�����������]               TINYINT,
	[����������]                INT,
	[����������� �������������] FLOAT,
	[����������]                DATE,
	[�����������]               DATE,
	[����� ���������]           INT,
	[����������]                VARCHAR(256),
	[��������������������]      DATE,
	[������������]              VARCHAR(256),
	[��������]                  VARCHAR(256),
	[���]                       VARCHAR(256),
	[����� ��������]            VARCHAR(256),
	[����������]                VARCHAR(256),
	[���]                       VARCHAR(256),
	[����]                      VARCHAR(256),
    [�����]                     INT,
    [����������������]          BIT,
    [���� ���������]            DATE,
    [��� ���������]             INT,  
    [��������� ������]          INT
);

WITH ����������������� AS (
    SELECT 
        ������������,
        [60] AS ���,
        [23] AS [����� ��������], 
        [28] AS ����������,
        [27] AS ���,
        [24] AS ����
    FROM (            
		SELECT 
            [���-���������] AS ������������,
            [��������-��������] AS ��������, 
            ��������
        FROM stack.[�������� ����������]
        WHERE [��������-��������] IN (23, 24, 27, 28, 60)
    ) AS T
    PIVOT ( 
        MAX(��������) FOR �������� IN ([28], [27], [24], [60], [23])
    ) AS PVT
)
INSERT INTO #temp_counters (
    [�������], [����_���������], [���������], [��������������],
	[�����������], [����������], [����������� �������������], [����������], [�����������], [����� ���������],
	[����������], [��������������������], [������������], [��������],
	[���], [����� ��������], [����������], [���], [����], [�����], [����������������],
    [���� ���������], [��� ���������], [��������� ������]
)
SELECT 
    A.�������,
    F.������, 
	F.���������, 
    F.��������������,
    F.�����������, 
    F.����������,
    F.[����������� �������������],
    F.����������,
    F.�����������,
    F.[����� ���������],
    F.����������,
    F.��������������������,
    F.������������,
    F.��������,
    PS.���,
    PS.[����� ��������],
    PS.����������, 
    PS.���,
    PS.����,
    ASK.��������,
    IIF(@���� >= DATEADD (YEAR, CAST(PS.��� AS INT), F.�����������), 1, 0),
    PL.[���� ���������],
    PL.[��� ���������],
    PL.���������
FROM #temp_accounts AS A
CROSS APPLY
(
	SELECT TOP (1)
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
	WHERE SO.[�������-����] = A.������� 
	  AND @���� BETWEEN SO.������ AND SO.������
	  AND ISNULL(NOM.�������������, 0) = 0
	ORDER BY SO.������ DESC
) AS F
LEFT JOIN ����������������� AS PS ON PS.������������ = F.nom_row
LEFT JOIN stack.[��������] AS ASK 
  ON ASK.[�������-���������]=F.so_row
     AND @���� BETWEEN ASK.������ AND ASK.������
	 AND ASK.[����-���������] = @�������������
OUTER APPLY (
	SELECT TOP (1)
        PL.[���� ���������],
        PL.[��� ���������],
        PL.���������
	FROM stack.[������] AS PL
	WHERE PL.[������-������] = F.so_row 
	ORDER BY PL.[���� ���������] DESC
) AS PL;

IF OBJECT_ID(N'tempdb..#temp_phones', N'U') IS NOT NULL
    DROP TABLE #temp_phones;

CREATE TABLE #temp_phones (
	[�������]  INT,
    ���        VARCHAR(MAX),
    ���������� VARCHAR(MAX),
    �������    VARCHAR(MAX),
    [E_MAIL]   VARCHAR(MAX)
);

WITH �������� AS (
    SELECT DISTINCT 
        A.�������,
        T.�����,
        T.�����
    FROM #temp_accounts AS A
    JOIN [stack].[��������] AS T ON T.[����-�������] = A.�������
    WHERE T.����� IN (1, 2, 3, 4)
)
INSERT INTO #temp_phones ([�������], ���, ����������, �������, [E_MAIL])
SELECT
    �������,
    [stack].[CLR_Concat](IIF(����� = 1, �����, NULL)) AS [�������],
    [stack].[CLR_Concat](IIF(����� = 2, �����, NULL)) AS [���],
    [stack].[CLR_Concat](IIF(����� = 3, �����, NULL)) AS [����������],
    [stack].[CLR_Concat](IIF(����� = 4, �����, NULL)) AS [E_MAIL]
FROM ��������
GROUP BY �������;

CREATE INDEX NCI_������� ON #temp_phones (�������);

WITH ����� AS(
    SELECT 
        PVT.[�������] AS row_id,  
        PVT.[0] AS [������],
        PVT.[1] AS [�������],
        PVT.[12] AS [���������� �����], 
        PVT.[2] AS [�����], 
        PVT.[3] AS [���],
        PVT.[4] AS [��������]
	FROM (
        SELECT
			LI.�������,
			LI.�����������,
			CASE WHEN LI.����������� = 0        THEN L.�������
				 WHEN LI.����������� = 1        THEN O.��������
				 WHEN LI.����������� IN (12, 2) THEN IIF(C.��_����� = 1, CONCAT(C.��������, ' ', C.����������), CONCAT(C.����������, ' ', C.��������))
				 WHEN LI.����������� IN (3, 4)  THEN CAST(L.����� AS NVARCHAR(12)) 
			END AS �����
	    FROM stack.[������� ��������] AS LI
	    JOIN stack.[������� �����] AS L ON LI.�������� = L.row_id
	    LEFT JOIN stack.[������] AS C ON L.[�����-������� ����] = C.row_id
	    LEFT JOIN stack.[�����������] AS O ON O.row_id = L.[����-�������� �������]
	    WHERE LI.���������� = 5 AND ����������� IN (0, 1, 12, 2, 3, 4)
	) AS T
	PIVOT
	(
		MAX(�����) FOR ����������� IN([0], [1], [12], [2], [3], [4])
	) AS PVT
), ������������������� AS (
    SELECT 
        A.�������,
        MAX(O.��������) AS [����_��],
        MAX(CAST(D.����� AS VARCHAR(256))) AS [���_���_��]
	FROM #temp_accounts AS A
    JOIN [stack].[������� ��������] AS LI ON LI.������� = A.�������
	JOIN [stack].[����������� ��������] AS U 
      ON U.[����-��] = LI.��������
		 AND @���� BETWEEN U.������ AND U.������
    JOIN stack.����������� AS O ON U.[�����������-��] = O.row_id
    LEFT JOIN stack.[�� ��������] AS D 
      ON D.row_id = U.[���-���������] 
         AND @���� BETWEEN D.������ AND D.������
    GROUP BY A.�������
)   
SELECT 
    LS.�����_��,
    LS.���_����, 
    '��' AS �������_���_���,
    IIF(ISNULL(LS.���������, 0) = 0, '������������', '�� ���������') AS [����_��],
    CASE LS.�������� 
        WHEN 0 THEN '���������������'		
		WHEN 1 THEN '�������'				
		WHEN 2 THEN '���������'
		WHEN 3 THEN '����'
		WHEN 4 THEN '�����'
		WHEN 5 THEN '����'
		WHEN 6 THEN '�����'
		WHEN 7 THEN '������'
		WHEN 8 THEN '������ ���������������'
    END AS [���_��������],
    AD.������,
    AD.�������,
    AD.[���������� �����] AS [����������_�����],
    AD.����� AS [�����],
    AD.��� AS [���_����],
    AD.�������� AS [���_��������],
    K.������� AS [���_�������],
    LS.���,
    CASE LS.��� 
        WHEN 0 THEN '����'
        WHEN 1 THEN '���'
    END AS [�����������_���_��],
    IIF(C.������������ IS NULL, '����������� ��', '��������������') AS [���_��],
    FORMAT(C.[����_���������], 'dd.MM.yyyy') AS [����_���������],
    CHOOSE(C.���������, '��������', '����������� �� ��������', '�� ��������') AS [���������_��],
    C.������������ AS [������������_��],
    C.�������������� AS [�����_��],
	CONVERT( nvarchar, C.�����������) �����������, 
    CONVERT( nvarchar, C.����������) ����������,
    CONVERT( nvarchar, C.[����������� �������������]) AS [����_������],
    FORMAT(C.����������, 'dd.MM.yyyy') AS [���_�������],
    FORMAT(C.�����������, 'dd.MM.yyyy') AS [����_����_�������],
    C.��� AS ���,
    FORMAT(C.��������������������, 'dd.MM.yyyy') AS [����_����_�������],
    C.[����� ��������] AS [�����_��������],
    C.��� AS [���_��],
    C.���� AS [���_��_���_��������],
    C.���������� AS [����_��],
    CASE C.[����� ���������] 
        WHEN 0  THEN '�� �����'
	    WHEN 1  THEN '���������� ��������'
	    WHEN 2  THEN '��������'
	    WHEN 3  THEN '�������'
	    WHEN 4  THEN '����� ���'
	    WHEN 5  THEN '�������'
	    WHEN 6  THEN '�����'
	    WHEN 7  THEN '�����'
	    WHEN 8  THEN '����� ������'
	    WHEN 9  THEN '����� � �������� ���'
	    WHEN 10 THEN '�������'
	    WHEN 11 THEN '��� ���'
	    WHEN 12 THEN '�� ��'
                ELSE '�� �������'
    END [�����_���������_��],
    C.�������� AS [�������_�����],
    CASE C.����� 
        WHEN 0 THEN '����������� ����������� �������' 
	    WHEN 1 THEN '���� ���������' 
	    WHEN 2 THEN '������������� ����������� � ����������' 
    END [�����],
    T.���,
    T.����������,
    T.�������,
    T.[E_MAIL],
    U.[����_��],
    U.[���_���_��],
    C.���������� AS [����_�_�����_��],
    FORMAT(C.[���� ���������], 'dd.MM.yyyy') AS [����_����_������],
    CASE C.[��� ���������]
        WHEN 0 THEN '����'
	    WHEN 1 THEN '����'
	    WHEN 2 THEN '���'
	    WHEN 3 THEN '��������������'
    END AS [���_��������_������],
    CASE C.[��������� ������] 
        WHEN 0 THEN '�����������'  
        WHEN 1 THEN '�� ��������'
	    WHEN 2 THEN '��������'
    END [����_������]
FROM #temp_accounts AS LS
LEFT JOIN #temp_counters AS C ON C.������� = LS.�������
LEFT JOIN #temp_phones AS T ON T.������� = LS.�������
LEFT JOIN ����� AS AD ON AD.row_id = LS.�������
LEFT JOIN ������������������� AS U ON U.������� = LS.�������
LEFT JOIN [stack].[������� ��������] AS LK 
  ON LK.������� = LS.�������
     AND LK.����������� = 4
LEFT JOIN [stack].[������� �����] AS K ON K.row_id = LK.��������
WHERE @�������������� = 0 
   OR C.���������������� = 1

   UNION ALL

SELECT 
	LS.����� AS [�����_��],
	CAST(ODPU.����� AS VARCHAR(256)) AS [���_����],
	'���' AS [�������_���_���],
	CASE SLS.��������
        WHEN 0 THEN '������������'
		WHEN 1 THEN '�� ���������'
		WHEN 2 THEN '������'
	END [����_��],
	CASE ISNULL(OPTS.��������, OPTSH.��������)
        WHEN 0 THEN '���������������'
		WHEN 2 THEN '���������'
	END [���_��������],
    AD.������,
    AD.�������,
    AD.[���������� �����],
    AD.�����,
    AD.���,
    AD.��������,
    K.������� AS [���_�������],
	CR.���,
	CASE ISNULL(US.��������, 0)	
        WHEN 0 THEN '����'
		WHEN 1 THEN '���'
    END [�����������_���_��],
    IIF(NOM.������������ IS NULL, '����������� ��', '��������������') AS [���_��],
	FORMAT(SO.������, 'dd.MM.yyyy') AS[����_���������],
	CHOOSE(SS.���������, '��������', '����������� �� ��������', '�� ��������') AS [���������_��],
    NOM.������������ AS [������������_��],
    SO.�������������� AS [�����_��],
	SO.�����������,
	SO.����������,
	SO.[����������� �������������] AS [����_������],
	FORMAT(SO.����������, 'dd.MM.yyyy') AS [���_�������],
	FORMAT(SO.�����������, 'dd.MM.yyyy') AS [����_����_�������],
	SP.���,
    FORMAT(SO.��������������������, 'dd.MM.yyyy') AS [����_����_�������],
	SP.[����� ��������],
	SP.���,
	SP.����,
	SP.����������,
    CASE SO.[����� ���������] 
        WHEN 0  THEN '�� �����'
		WHEN 1  THEN '���������� ��������'
		WHEN 2  THEN '��������'
		WHEN 3  THEN '�������'
		WHEN 4  THEN '����� ���'
		WHEN 5  THEN '�������'
		WHEN 6  THEN '�����'
		WHEN 7  THEN '�����'
		WHEN 8  THEN '����� ������'
		WHEN 9  THEN '����� � �������� ���'
		WHEN 10 THEN '�������'
		WHEN 11 THEN '��� ���'
		WHEN 12 THEN '�� ��'
		        ELSE '�� �������'
	END [�����_���������_��],
	NOM.�������� AS [�������_�����],
	CASE ASK.��������
        WHEN 0 THEN '����������� ����������� �������' 
		WHEN 1 THEN '���� ���������' 
		WHEN 2 THEN '������������� ����������� � ����������' 
    END [�����], 
	PH.���,
    PH.����������,
    PH.�������,
    PH.[E_MAIL],
	ORG.�������� AS [����_��],
	CAST(UKDOG_DOM.����� AS VARCHAR(256)) AS [���_���_��],
	SO.���������� AS [����_�_�����_��],
	FORMAT(P.[���� ���������], 'dd.MM.yyyy') AS [����_����_������],
	CASE P.[��� ���������]
        WHEN 0 THEN '����'
		WHEN 1 THEN '����'
		WHEN 2 THEN '���'
		WHEN 3 THEN '��������������'
	END [���_��������_������],
	CASE P.���������
		WHEN 0 THEN '�����������'
		WHEN 1 THEN '�� ��������'
		WHEN 2 THEN '��������'
	END [����_������]
FROM TNS_Kuban_fl_522.stack.[������� �����] AS LS
JOIN TNS_Kuban_fl_522.stack.[������� ��������] AS LI ON LI.������� = LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.[stack].[��������� ���������] AS PS ON LI.�������� = PS.[���������-����] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[��������] AS ODPU 
  ON ODPU.[ROW_ID] = ps.[���������-��������] 
     AND ODPU.[��� ���������] = 77 
     AND PS.��� = 6 
     AND ODPU.�������� = 0
LEFT JOIN TNS_Kuban_fl_522.stack.[������ ��������] AS SOODPU ON SOODPU.[�������-���������] = ODPU.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.�������� AS SLS 
 ON SLS.[����-���������] = LS.ROW_ID
	 AND SLS.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '���������')
LEFT JOIN TNS_Kuban_fl_522.stack.�������� OPTS 
  ON OPTS.[����-���������] = LS.ROW_ID 
	 AND OPTS.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '��������')
LEFT JOIN TNS_Kuban_fl_522.stack.�������� OPTSH 
  ON OPTSH.[����-���������] = LI.�������� 
	 AND OPTSH.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '��������')
LEFT JOIN TNS_Kuban_fl_522.stack.�������� TU 
  ON TU.[����-���������] = LS.ROW_ID 
	AND OPTSH.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '������')
LEFT JOIN [TNS_Kuban_fl_522].[stack].[��������] US 
  ON US.[����-���������]=LS.ROW_ID 
	 AND US.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '���_���_��')
LEFT JOIN [TNS_Kuban_fl_522].[stack].[�������� �����������] CR ON CR.[����-����������] = LS.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[������ ��������] SO ON SO.[�������-����] = LS.ROW_ID 
LEFT JOIN [TNS_Kuban_fl_522].[stack].[��������� ��������] SS ON SS.[����-�������� ���������] = SO.[�������-����] 
LEFT JOIN [TNS_Kuban_fl_522].[stack].[������������] NOM ON SO.[������������-�������]=nom.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[��������] AS ASK 
  ON ASK.[�������-���������] = SO.ROW_ID
	 AND ASK.[����-���������] = (SELECT TOP (1) row_id FROM [TNS_Kuban_fl_522].[stack].[���� ����������] WHERE �������� = '�����')
LEFT JOIN (
    SELECT 
        ������������,
        [60] AS ���,
        [23] AS [����� ��������], 
        [28] AS ����������,
        [27] AS ���,
        [24] AS ����
    FROM (            
	    SELECT 
            [���-���������] AS ������������,
            [��������-��������] AS ��������, 
            ��������
        FROM [TNS_Kuban_fl_522].[stack].[�������� ����������]
        WHERE [��������-��������] IN (23, 24, 27, 28, 60)
    ) AS T
    PIVOT ( 
        MAX(��������) FOR �������� IN ([28], [27], [24], [60], [23])
    ) AS PVT
) AS SP ON SP.������������ = NOM.row_id
LEFT JOIN (
     SELECT 
        PVT.[�������] AS row_id,  
        PVT.[0] AS [������],
        PVT.[1] AS [�������],
        PVT.[12] AS [���������� �����], 
        PVT.[2] AS [�����], 
        PVT.[3] AS [���],
        PVT.[4] AS [��������]
	FROM (
        SELECT
			LI.�������,
			LI.�����������,
			CASE WHEN LI.����������� = 0        THEN L.�������
				 WHEN LI.����������� = 1        THEN O.��������
				 WHEN LI.����������� IN (12, 2) THEN IIF(C.��_����� = 1, CONCAT(C.��������, ' ', C.����������), CONCAT(C.����������, ' ', C.��������))
				 WHEN LI.����������� IN (3, 4)  THEN CAST(L.����� AS NVARCHAR(12)) 
			END AS �����
	    FROM [TNS_Kuban_fl_522].[stack].[������� ��������] AS LI
	    JOIN [TNS_Kuban_fl_522].[stack].[������� �����] AS L ON LI.�������� = L.row_id
	    LEFT JOIN [TNS_Kuban_fl_522].[stack].[������] AS C ON L.[�����-������� ����] = C.row_id
	    LEFT JOIN [TNS_Kuban_fl_522].[stack].[�����������] AS O ON O.row_id = L.[����-�������� �������]
	    WHERE LI.���������� = 5 AND ����������� IN (0, 1, 12, 2, 3, 4)
	) AS T
	PIVOT
	(
		MAX(�����) FOR ����������� IN([0], [1], [12], [2], [3], [4])
	) AS PVT
) AS AD ON AD.ROW_ID = LS.ROW_ID
LEFT JOIN [TNS_Kuban_fl_522].[stack].[������� ��������] AS LK 
  ON LK.������� = LS.row_id
     AND LK.����������� = 4
LEFT JOIN [TNS_Kuban_fl_522].[stack].[������� �����] AS K ON K.row_id = LK.��������
LEFT JOIN (
    SELECT 
        T.[����-�������],
        [stack].[CLR_Concat](DISTINCT IIF(T.����� = 1, T.�����, NULL)) AS [�������],
        [stack].[CLR_Concat](DISTINCT IIF(T.����� = 2, T.�����, NULL)) AS [���],
        [stack].[CLR_Concat](DISTINCT IIF(T.����� = 3, T.�����, NULL)) AS [����������],
        [stack].[CLR_Concat](DISTINCT IIF(T.����� = 4, T.�����, NULL)) AS [E_MAIL]
    FROM (
        SELECT
            T.[����-�������],
            T.�����,
            T.�����
        FROM TNS_Kuban_fl_522.[stack].[��������] AS T
        WHERE T.����� IN (1, 2, 3, 4)
    ) AS T
    GROUP BY T.[����-�������]
) AS PH ON PH.[����-�������] = LS.row_id 
LEFT JOIN TNS_Kuban_fl_522.stack.[����������� ��������] AS UK_DOM ON UK_DOM.[����-��] = LI.�������� 
LEFT JOIN TNS_Kuban_fl_522.stack.[�� ��������] AS UKDOG_DOM	ON UKDOG_DOM.ROW_ID = UK_DOM.[���-���������] 
LEFT JOIN TNS_Kuban_fl_522.stack.����������� AS ORG ON UK_DOM.[�����������-��] = ORG.ROW_ID
OUTER APPLY(
    SELECT TOP (1)
        [���� ���������],
        [��� ���������],
        ���������
	FROM TNS_Kuban_fl_522.stack.[������]
	WHERE [������-������] = SO.ROW_ID 
	ORDER BY [���� ���������] DESC
) AS P 
WHERE LI.���������� = 5  AND LI.�����������=3
 AND (@�������������� = 0
    OR (SO.ROW_ID IS NOT NULL AND @����  >= DATEADD (year, CAST(SP.��� AS int), SO.�����������))
 );