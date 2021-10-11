DECLARE @����  DATE = '20210527';
IF OBJECT_ID(N'tempdb..#address', N'U') IS NOT NULL
      DROP TABLE #address
CREATE TABLE #address(
	�������		NVARCHAR(256),
	�������		BIGINT,
	����������� NVARCHAR(MAX),
	������		NVARCHAR(256),
	������		INT,
	����_1		NVARCHAR(128),
	�������		NVARCHAR(128),
	����_1		INT,
	����_2		NVARCHAR(128),
	�����		NVARCHAR(128),
	����_2		NVARCHAR(128),
	����_3		NVARCHAR(128),
	�����		NVARCHAR(128),
	����_3		INT,
	����_4		NVARCHAR(128),
	��������	NVARCHAR(128),
	����_4		INT,
	����_5		NVARCHAR(128),
	�����		NVARCHAR(128),
	����_5		INT,
	����_6		NVARCHAR(64),
	����_7		NVARCHAR(64),
	����_8		NVARCHAR(64),
	����_9		NVARCHAR(64)
);
WITH raw AS (
	SELECT 
		L.row_id,
		L.����� AS �������,
		D.����� AS �������,
		L.������� AS �����������,
		CAST(A.����� AS nvarchar(MAX)) AS �����XML,
		ISNULL(X.����.value('.', 'nvarchar(max)'), '') �������,
		X.����.value('for $i in . return count(../*[. << $i]) + 1', 'int') AS �����������
	FROM [stack].[������� �����] AS L
	JOIN stack.[������� ��������] AS LD ON LD.�������=L.ROW_ID AND @���� BETWEEN LD.������ AND LD.������
	JOIN stack.������� AS D ON LD.�������=D.ROW_ID 
	CROSS APPLY (VALUES(
		RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L.�������, ' ', '<>'), '><', ''), '<>', ' '), ' ,', ','), ', ', ',')))
	)) AS E(�����)
	CROSS APPLY (VALUES(CAST(CONCAT('<H>',�REPLACE(E.�����,�',',�'</H><H>'),�'</H>')�AS�XML))) AS A(�����)
	CROSS APPLY A.�����.nodes('H') AS X(����)
	WHERE  D.[���������-��������] IN (252,253.254) AND @���� BETWEEN D.[������ ��������] AND ISNULL(D.���������,'20450509') 
), Details AS (
	SELECT
		row_id,
		�������,
		�������,
		�����������,
		�����XML,
		MAX(IIF(V.������ IS NOT NULL, �������, NULL)) OVER (PARTITION BY row_id) AS ������,
		MAX(IIF(V.������ IS NOT NULL, �������, NULL)) OVER (PARTITION BY row_id) AS ������,
		IIF(����������� IN (MAX(V.������) OVER (PARTITION BY row_id), MAX(V.������) OVER (PARTITION BY row_id)), NULL, �������) AS �������,
		�����������
	FROM raw
	CROSS APPLY (VALUES(
		IIF(����������� IN (1, 2) AND LEN(�������) > 3 AND TRY_CAST(������� AS INT) IS NOT NULL,                �����������, NULL),
		IIF(����������� IN (1, 2) AND RTRIM(LTRIM(LOWER(�������))) IN ('��', '���������� ���������', '������'), �����������, NULL)
	)) AS V(������, ������)
), ����������� AS 
(
	SELECT (Obl.�������� + ' ' + obl.����������) AS ����,
			Obl.ROW_ID
	FROM stack.������ AS Obl
	WHERE Obl.ROW_ID IN (163,261351) AND Obl.���=1
)
, ����� AS
(
	SELECT (ISNULL(RN.��������, '') + ' ' + ISNULL(RN.����������,'')) AS �����,
			RN.���			
	FROM ����������� AS K
	JOIN stack.������ AS RN ON RN.������=K.ROW_ID
)
--���� ����� ����, �� � ������ ������ �� �����
, ����� AS
(
	SELECT (ISNULL(Gor.��������, '') + ' ' + ISNULL(Gor.����������,'')) AS �����,
			Gor.���
	FROM ����������� AS K
	JOIN stack.������ AS RN ON RN.������=K.ROW_ID
	JOIN stack.������ AS Gor ON Gor.������=RN.ROW_ID
)
--���� ���� ����� � �����
,�������� AS
(
	SELECT (ISNULL(NP.��������, '') + ' ' + ISNULL(NP.����������,'')) AS ��������,
			NP.���
	FROM ����������� AS K
	JOIN stack.������ AS RN ON RN.������=K.ROW_ID
	JOIN stack.������ AS Gor ON Gor.������=RN.ROW_ID
	JOIN stack.������ AS NP ON NP.������=Gor.ROW_ID
)
,����� AS
(
	SELECT (ISNULL(UL.��������, '') + ' ' + ISNULL(UL.����������,'')) AS �����,
			UL.���
	FROM ����������� AS K
	JOIN stack.������ AS RN ON RN.������=K.ROW_ID
	JOIN stack.������ AS Gor ON Gor.������=RN.ROW_ID
	JOIN stack.������ AS NP ON NP.������=Gor.ROW_ID
	JOIN stack.������ AS UL ON UL.������=NP.ROW_ID
)
INSERT INTO #address(�������,
					 �������, 
					 �����������, 
					 ������, 
					 ������, 
					 ����_1, 
					 �������, 
					 ����_1, 
					 ����_2, 
					 �����, 
					 ����_2, 
					 ����_3,
					 �����, 
					 ����_3,
					 ����_4, 
					 ��������, 
					 ����_4, 
					 ����_5, 
					 �����, 
					 ����_5, 
					 ����_6, 
					 ����_7, 
					 ����_8, 
					 ����_9)
SELECT	DISTINCT
		pvt.�������,
		pvt.�������,
		pvt.�����������,
		pvt.������,
		pvt.������,
		pvt.[1],
		K.����,
		
		pvt.[2],
		ISNULL(R.�����,'') AS �����, --����-�����
		
		pvt.[3],
		CASE
			WHEN pvt.[2]='' AND pvt.[1]=K.���� THEN ISNULL(G.�����,'')  --����� ��� ������ ������
			WHEN pvt.[2]=R.����� 			   THEN ISNULL(RG.�����,'') --����� � ������
		END AS �����,

		pvt.[4],
		CASE		
			WHEN pvt.[1]=K.���� AND pvt.[2]=R.����� AND pvt.[3]=RG.����� AND pvt.[3]!='' THEN ISNULL(RGNP.��������,'')	--�������-�����-�����-��������
			WHEN pvt.[1]=K.���� AND	pvt.[2]=R.����� AND pvt.[3]=''						 THEN NP.�����		--�������-�����-��������
			WHEN pvt.[1]=K.���� AND pvt.[2]='' AND pvt.[3]!=''   						 THEN ISNULL(KGNP.�����,'')	--�������-�����-��������
		END AS ��������,

		pvt.[5],
		CASE
			WHEN  pvt.[1]=K.���� AND ((pvt.[2]='' AND pvt.[3]!='') OR (pvt.[2]!='' AND pvt.[3]='') AND pvt.[4]='')  THEN OGU.�����
			WHEN  pvt.[1]=K.���� AND ((pvt.[2]!='' AND pvt.[3]!='') AND pvt.[4]='')									THEN OGNPU.��������
			WHEN  pvt.[1]=K.���� AND ((pvt.[2]='' AND pvt.[3]!='') OR (pvt.[2]!='' AND pvt.[3]='') AND pvt.[4]!='') THEN OGNPU.��������
			WHEN  pvt.[1]=K.���� AND pvt.[2]=R.����� AND pvt.[3]=RG.����� AND pvt.[4]=RGNP.��������					THEN UL.�����
		END AS �����,

		pvt.[6],
		pvt.[7],
		pvt.[8],
		pvt.[9]
FROM (
	SELECT 
		row_id,
		�������,
		�������,
		�����������,
		�����XML,
		������,
		������,
		�������,
		ROW_NUMBER() OVER (PARTITION BY row_id ORDER BY �����������) AS �����������
	FROM Details
	WHERE ������� IS NOT NULL
) AS T
PIVOT 
( 
	MAX(T.�������) FOR T.����������� IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
) AS pvt
LEFT JOIN ����������� AS K ON K.����=pvt.[1]
LEFT JOIN ����� AS R	   ON R.�����=pvt.[2]		  AND R.���=3--�����
LEFT JOIN ����� AS G	   ON G.�����=pvt.[3]		  AND G.���=4--������ �� � �������
LEFT JOIN ����� AS RG	   ON RG.�����=pvt.[3]		  AND RG.���=4--����� ������ ������
LEFT JOIN ����� AS NP	   ON NP.�����=pvt.[4]		  AND NP.���=6--�������� ������ ������
LEFT JOIN ����� AS KGNP	   ON KGNP.�����=pvt.[4]	  AND KGNP.���=6 -- ��� ����� ������ ������ ��� ������
LEFT JOIN �������� AS RGNP ON RGNP.��������=pvt.[4]	  AND RGNP.���=6 --���������� ����� ������ ������ 
LEFT JOIN ����� AS OGU ON OGU.�����=pvt.[5]			  AND OGU.���=7 --�������-�����-�����
LEFT JOIN �������� AS OGNPU ON OGNPU.��������=pvt.[5] AND OGNPU.���=7--�������-�����-��������-����� ��� �������-�����-�����-�����
LEFT JOIN �����	As UL ON UL.�����=pvt.[5]			  AND UL.���=7 --�������-�����-�����-��������-�����
--�������-�����-�����
--�������-�����-��������-�����

SELECT  �������,
		�������, 
		�����������, 
		������,
		������, 
		����_1,
		CASE
			WHEN ISNULL(pvt.[1], '')!=ISNULL(K.����,'') THEN 0 --�������������
			WHEN pvt.[1]=K.����							THEN 1 --������������
		END AS ��������,
		CASE
			WHEN ISNULL(pvt.[2], '')!=ISNULL(R.�����, '') THEN 0 --��������������
			WHEN pvt.[2]=R.����� AND pvt.[2] != ''		  THEN 1 --������������, ���� ��������
			WHEN pvt.[2]='' AND ISNULL(R.�����,'')='' AND  pvt.[2]=ISNULL(R.�����,'') AND pvt.[1]=K.���� THEN 2 --������������, ������� ����
			ELSE 0
		END AS ���������,
				CASE
			WHEN ISNULL(G.�����,'')!=ISNULL(pvt.[3],'') AND ISNULL(RG.�����,'')!=ISNULL(pvt.[3],'')	THEN 0 --��������������
			WHEN ((G.�����=pvt.[3]) OR (RG.�����=pvt.[3])) AND pvt.[1]=K.����						THEN 1--�����������
			WHEN ISNULL(RG.�����,'')=ISNULL(pvt.[3],'') AND pvt.[1]=K.���� AND pvt.[2]=R.�����		THEN 2--�����������, ������� ����(���� �����-��� ������)
			ELSE 0
		END AS ���������,
				CASE
			WHEN (ISNULL(NP.�����,'')!=ISNULL(pvt.[4],'')) AND (ISNULL(RGNP.��������,'')!=ISNULL(pvt.[4],'')) AND (ISNULL(KGNP.�����,'')!=ISNULL(pvt.[4],'')) THEN 0 --��� ������������
			WHEN NP.�����=pvt.[4] OR RGNP.��������=pvt.[4] OR KGNP.�����=pvt.[4] THEN 1
			WHEN pvt.[4]='' AND (pvt.[4]=ISNULL(RGNP.��������,'') OR pvt.[4]=ISNULL(KGNP.�����,'') OR pvt.[4]=ISNULL(NP.�����,'')) THEN 2
		ELSE 0
			CASE
			--WHEN 
			WHEN OGU.�����=pvt.[5] OR OGNPU.��������=pvt.[5] OR UL.�����=pvt.[5] THEN 1
			ELSE 0
		END AS ���������,
		END AS ������,
		(ISNULL(CAST(������ as nvarchar),'')+', '
		+(ISNULL(����_1,'')
		+', '+ISNULL(����_2,'')
		+', '+ISNULL(����_3,'')
		+', '+ISNULL(����_4,'')
		+', '+ISNULL(����_5,'')
		+', '+ISNULL(����_6,'')
		+', '+ISNULL(����_7,'')
		+', '+ISNULL(����_8,'')
		+', '+ISNULL(����_9,''))) AS �������
FROM #address AS A
WHERE ����_1!='������������� ����' AND ����_1!='������ ����' 
--OR  ����_1 NOT LIKE ' ������ ����'
--WHERE ����_1!=0 AND ����_2!=0 AND ����_3!=0 AND ����_4!=0 AND ����_5!=0 
--WHERE ����_1 LIKE '����.%'
--����_1=1 AND ����_2!=0 AND ����_3!=0 AND ����_4!=0
--AND ����_2 IN (1,2) AND ����_3=0 AND ����_4=0 AND ����_5=0 
--����_2 IN (1,2) AND ����_3 IN (1,2) AND ����_4 IN (1,2) AND ����_5=1 AND ������ IS NULL

--WHERE pvt.[2]='' OR (pvt.[2]=R.����� AND pvt.[2] != '')
--LEFT JOIN �������� AS N ON N.��������=pvt.[4]
--LEFT JOIN ����� AS U ON U.�����=pvt.[5]


--SELECT RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(' a  b s   u  ', ' ', '<>'), '><', ''), '<>', ' ')))


--WITH Cities AS (
--	SELECT 
--		row_id,
--		CONCAT('//', CAST(�������� AS NVARCHAR(MAX))) AS ����,
--		1 AS �������
--	FROM [stack].[������]
--	WHERE ROW_ID = 1

--		UNION ALL

--	SELECT 
--		C.row_id,
--		CONCAT(P.����, '/', C.��������) AS ����,
--		P.������� + 1
--	FROM Cities AS P
--	JOIN [stack].[������] AS C ON C.������ = P.row_id
--)
--SELECT * 
--FROM Cities