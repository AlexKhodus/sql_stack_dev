DECLARE @date datetime='20200301';
WITH
S
AS(
SELECT		NS.���� AS �������,
			(SELECT 
					ISNULL(SUM(NS.�����), 0), 
					NS.����
			FROM stack.������� AS NS
			WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) 
			AND (NS.[����� ������] BETWEEN 100 AND 199)
			GROUP BY NS.����
			) AS s100,			
			(SELECT 
					ISNULL(SUM(NS.�����),0),
					NS.����
			FROM stack.������� AS NS
			WHERE  NS.[����� �������]=DATEADD(mm, -1, @date)
			AND (NS.[����� ������] BETWEEN 400 AND 499)
			GROUP BY NS.����
			) AS s400 
			--(s100+s400) AS [������ �� ������ ������ 100,400]	
FROM stack.������� AS NS
)
SELECT S.s100, s400
FROM stack.[������� �����] AS LS
LEFT JOIN S ON S.�������=LS.ROW_ID
WHERE LS.ROW_ID=164180



SELECT 		NT.����
					, NT.[����� ������]
					, NT.�����
				FROM stack.������ AS NT
				WHERE NT.���� IN (164171) AND NT.[����� �������]=@date
		UNION
				(SELECT NS.����
					 , NS.[����� ������]
					 , SUM(NS.�����) AS Summa
				FROM stack.������� AS NS
				WHERE NS.���� IN (164171) AND NS.[����� �������]=DATEADD(mm, -1, @date) AND NS.[����� ������]  BETWEEN 100 AND 199
				GROUP BY NS.����, NS.[����� ������])
		UNION
				SELECT VS.����
					 , VS.[����� ������]
					 , SUM(VS.�����) AS Summa
				FROM stack.������� AS VS
				WHERE VS.���� IN (164171) AND VS.[����� �������]=DATEADD(mm, -1, @date)
				GROUP BY VS.����, VS.[����� ������]



DECLARE @date datetime='20200301';
			SELECT SUM(S.Summa) AS [������ �� ������ ������ 100,400],
					S.����
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) AND NS.[����� ������]  BETWEEN 100 AND 199
							GROUP BY NS.����, NS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=DATEADD(mm, -1, @date) AND VS.[����� ������]  BETWEEN 400 AND 499
							GROUP BY VS.����, VS.[����� ������]) AS S
LEFT JOIN stack.[������� �����] AS LS
ON LS.ROW_ID=S.����
WHERE LS.ROW_ID=164180
GROUP BY S.����


SELECT *
FROM stack.������������ AS NOM
WHERE NOM.ROW_ID=8378
DECLARE @date datetime='20200301';	
			SELECT	LI.�������
			,T.��������
			,[stack].[CLR_Concat](ISNULL(TU.[����� ������],TUD.[����� ������])) AS [����� ������]
			,[stack].[CLR_Concat](ISNULL(TU.������������,TUD.������������)) AS [��� �������������]
			FROM stack.[������� ��������] AS LI
--��� ��
			LEFT JOIN stack.[������ �����] AS SU
				ON SU.[����-������]=LI.������� 
			LEFT JOIN stack.[���� �����] AS TU
				ON TU.ROW_ID=SU.[���-������]
--��� ����
			LEFT JOIN stack.[������ �����] AS SUD
				ON SUD.[����-������]=LI.�������� 
			LEFT JOIN stack.[���� �����] AS TUD
				ON TUD.ROW_ID=SUD.[���-������]
			LEFT JOIN 	stack.[������] AS T
			ON TU.ROW_ID=T.[���-������] OR TUD.ROW_ID=T.[���-������]
			WHERE LI.�����������=3 AND LI.����������=5 AND LI.�������=164180 AND T.������=(
			SELECT TOP 1 T.������
			FROM stack.[������] AS T			
			WHERE T.[���-������]=TUD.ROW_ID OR TU.ROW_ID=T.[���-������]
			ORDER BY T.������ DESC)
			GROUP BY LI.�������, T.��������
--LEFT JOIN 	stack.[������] AS T
--LEFT JOIN stack.[���� �����] AS TU
--ON TU.ROW_ID=T.[���-������]
--Where	ROW_ID = 1978

SELECT	*
FROM	stack.[������ �����������]
Where	ROW_ID = -1

SELECT	*
FROM	stack.[��������� ���������]
Where	ROW_ID = 424958277

SELECT	*
FROM	stack.[��������� ���������]
Where	ROW_ID = 424160190



SELECT	*
FROM	stack.[���� �����]
Where	ROW_ID = 1517

SELECT TOP 1 *--PS.������
		--,TU.������������
FROM	stack.[��������� ���������] AS PS
LEFT JOIN stack.[������ ��������] AS SO
ON SO.ROW_ID=PS.[������-���������]
LEFT JOIN stack.[���� �����] AS TU
ON TU.ROW_ID=PS.[���������-������]
WHERE  SO.ROW_ID=426208016
		--TU.ROW_ID=14
		SELECT	*
FROM	stack.[��������� ���������]
Where	ROW_ID = 426208016
 
 
 SELECT TOP 1 TU.������������
 FROM stack.[��������� ���������] AS PS
 LEFT JOIN stack.[���� �����] AS TU
 ON TU.ROW_ID=PS.[���������-������]
 WHERE [���������-����]=164180 and PS.[���������-������]=1517
 ORDER BY PS.���� DESC
 WITH D
 AS(
SELECT TOP 1 PS.������,
			PS.[���������-����] AS �������
FROM stack.[��������� ���������] AS PS
--JOIN stack.[������� �����] AS LS
--ON LS.ROW_ID=PS.[���������-����]
JOIN stack.[���� �����] AS TU
 ON TU.ROW_ID=PS.[���������-������]
LEFT JOIN stack.�������� AS DOC
ON DOC.ROW_ID=PS.[���������-��������]
WHERE DOC.[��� ���������]=77
AND PS.[���������-����]=164180
ORDER BY PS.���� DESC
)
SELECT D.������
FROM  stack.[������� �����] AS LS
LEFT JOIN D ON D.�������=LS.ROW_ID
WHERE LS.ROW_ID=164180



 SELECT *
 FROM stack.��������
 WHERE stack.��������.ROW_ID=6379


SELECT	*
FROM	stack.[���� ���������]
Where	ROW_ID = -1

DECLARE @date datetime='20191001';
WITH
V AS(
SELECT RA.[����-������ ����] AS �������
		,SUM(RA.���������) AS [����� �� ���� ��]
		,SUM(RA.���������) AS [��������� �� ���� ��]
FROM	stack.[������ ����] AS RA
Where	 @date=RA.����� 
--AND RA.[����-������ ����]=150403
GROUP BY RA.[����-������ ����]
)
SELECT V.[����� �� ���� ��],
		V.[��������� �� ���� ��]
FROM  stack.[������� �����] AS LS
LEFT JOIN V ON V.�������=LS.ROW_ID
WHERE LS.ROW_ID=150403

SELECT	*
FROM	stack.[������ ����]
Where	ROW_ID = 603804

DECLARE @date datetime='20191001';
			SELECT  LI.�������,
					ISNULL(ORG.��������,ORG_D.��������) AS [������������ ����������]
			FROM 
				 stack.[������� ��������] AS LI
--��� ��
			JOIN stack.���������� AS POS
			ON POS.[����-������ �����������]=LI.�������
			JOIN stack.����������� AS ORG
			ON ORG.ROW_ID=POS.[����������-������]
--��� ����
			JOIN stack.���������� AS POS_D
			ON POS_D.[����-������ �����������]=LI.��������
			JOIN stack.����������� AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[����������-������]
			WHERE LI.�����������=3 AND LI.����������=5 AND (@date BETWEEN POS.������ AND POS.������ OR @date BETWEEN POS_D.������ AND POS_D.������)


SELECT	LS.ROW_ID
FROM stack.[������� �����] AS LS
LEFT JOIN stack.[����������] AS POS
ON POS.[����-������ �����������]=LS.ROW_ID
Where	POS.ROW_ID IS NULL

SELECT	*
FROM	stack.[��������� ���������]
Where	ROW_ID = 8262034

SELECT *
FROM stack.�������� AS Doc
WHERE Doc.ROW_ID=6379


			SELECT TOP 1 SO.���� AS [���� ��������� ������]
			,SO.[����-������] AS �������
			FROM stack.[������ ������] AS SO
			JOIN stack.[������� �����] AS LS
			ON LS.ROW_ID=SO.[����-������]
			WHERE LS.ROW_ID=164180
			ORDER BY  SO.���� DESC

WITH F
AS(
			Select DOC.ROW_ID,
					SO.[�������-����] AS �������
			FROM stack.[������ ��������] AS SO
			LEFT JOIN stack.�������� AS DOC
			ON DOC.ROW_ID=SO.[�������-���������]
			WHERE SO.ROW_ID=3443664
)
SELECT 
		CASE
			WHEN F.ROW_ID IS NULL THEN '���'
			WHEN F.ROW_ID IS NOT NULL THEN '��'
		END AS [������� ���� 1 - ��, 0 - ���]
FROM stack.[������� �����] AS LS
LEFT JOIN F ON F.�������=LS.ROW_ID
WHERE LS.ROW_ID=134829

		DECLARE @date datetime='20191001';
		SELECT RA.[����-������ ����] AS �������
			,RA.��������� AS [����� �� ���� ��]
			,SUM(RA.���������) AS [��������� �� ���� ��]
		FROM	stack.[������ ����] AS RA
		Where	RA.�����='20191001' AND RA.[����-������ ����]=150403
		GROUP BY RA.[����-������ ����], RA.���������


		SELECT *
		FROM stack.[���� �����] AS TU
		WHERE TU.������������='���������� �����������'
		

		SELECT *
		FROM stack.[������� �����] AS LS
		LEFT JOIN stack.[������ ����] AS RA ON
		RA.[����-������ ����]=LS.ROW_ID
		WHERE LS.ROW_ID
	--��������������������� ����� ����������
		SELECT SUM(NT.�����) [��������� �� ���� ��],
			   NT.���� AS �������
		FROM stack.������ AS NT
		WHERE NT.[����� ������]=(
		SELECT TOP 1 TU.[����� ������]
		FROM stack.[���� �����] AS TU
		WHERE TU.������������='���������� �����������'
		) AND NT.[����� �������]='20191001' AND  NT.����=150403
		GROUP BY  NT.����

		
		
		
		SELECT
		FROM stack.[��������� ���������] AS PS
		LEFT JOIN stack.�������� AS DOC
		ON DOC.ROW_ID=PS.[���������-��������] AND DOC.[��� ���������]=77 AND DOC.�������� = 0
		JOIN [stack].[������ ��������] AS SO ON SO.[�������-���������] = DOC.ROW_ID AND @date BETWEEN SO.������ AND SO.������ 
		join [stack].[������������] nom on so.[������������-�������]=nom.ROW_ID