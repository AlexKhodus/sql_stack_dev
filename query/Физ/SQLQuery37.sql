DECLARE @����      DATE = '20200720'


IF OBJECT_ID(N'tempdb..#temp_accounts', N'U') IS NOT NULL
   DROP TABLE #temp_accounts;

CREATE TABLE #temp_accounts (
    [�����_���] VARCHAR(256),
    [���_����]  VARCHAR(256),
	[�������]   VARCHAR(256),
    [���_��]    INT,
	[���_��]    VARCHAR(256),
	[�������]	INT
);
WITH 
�� AS( 
SELECT	
		  DOG.����� AS [���_���]
		, O.������������ AS [���_����]
		, O.�������
		, LS.����� AS [���_��]
		, LS.���������� AS [���_��]
		, LS.ROW_ID As �������
FROM	stack.[�������] AS DOG
JOIN stack.����������� AS O
	ON O.ROW_ID=DOG.����������
JOIN stack.[������� ��������] AS LD
	ON LD.�������=DOG.ROW_ID
JOIN stack.[������� �����] AS LS
	ON LS.ROW_ID=LD.�������
	  --AND ISNULL(NOM.�������������, 0) = 0
)
INSERT INTO #temp_accounts (
    [�����_���],
    [���_����] ,
	[�������]  ,
    [���_��]   ,
	[���_��]   ,
	[�������]  
)
SELECT *
FROM  ��
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
    '' [���_����]
	,LS.�����_���
	,'' [���_���]
	,LS.���_����
	,LS.�������
	,LS.���_��
	,LS.���_��
FROM #temp_accounts AS LS

Where	LS.������� = 8221
