DECLARE @date datetime='20200501',
		@account int=161408;
IF OBJECT_ID(N'tempdb..#TypeEnter', N'U') IS NOT NULL
   DROP TABLE #TypeEnter


CREATE TABLE #TypeEnter
	(flags INT PRIMARY KEY,
     Typename NVARCHAR(30) NOT NULL)
	 INSERT INTO #TypeEnter
	 VALUES		 (0  , '��')
				,(1  , '��')
				,(2  , '��')
				,(3  , '��')
				,(4  , '���������')
				,(5  , '������')
				,(6  , '��/�')
				,(7  , '���������')
				,(8  , '����')
				,(9  , 'WEB')
				,(10 , 'OUT')
				,(11 , '�����')
				,(12 , '�������')
				,(13 , '����')
				,(14 , '�����')
				,(15 , '�������')
				,(16 , 'SMS')
				,(17 , '���')
				,(18 , '���');

IF OBJECT_ID(N'tempdb..#Result', N'U') IS NOT NULL
    DROP TABLE #Result;

CREATE TABLE #Result(
	ROW_ID				INT,
	�������				BIGINT
);

INSERT INTO #Result(ROW_ID, �������)
SELECT   LS.ROW_ID 
		,LS.�����
FROM stack.[������� �����] AS LS
--WHERE LS.ROW_ID = 164180;
CREATE INDEX NCI_ROW_ID ON #Result (ROW_ID);
WITH DOG_NUM
	AS
		(
					SELECT LI.�������			
						   ,UKDOG_DOM.����� AS [����� ��������]
						   ,ORG.�������� AS [����������� ����������� ��������]
						   ,CASE 
								WHEN UK_DOM.[������� �������]=0 THEN ''
								WHEN UK_DOM.[������� �������]=1 THEN '��������� ������'
								WHEN UK_DOM.[������� �������]=2 THEN '��������� �� ������'
								WHEN UK_DOM.[������� �������]=3 THEN '������'
								WHEN UK_DOM.[������� �������]=4 THEN '�������� ��� � ��'
							END AS [������� �������]
					FROM  stack.[������� ��������] AS LI
					LEFT JOIN stack.[����������� ��������] AS UK_DOM
						ON UK_DOM.[����-��]=LI.�������� AND LI.[�����������]=3 
					JOIN stack.[�� ��������] AS UKDOG_DOM
						ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] AND
						@date BETWEEN UKDOG_DOM.������ AND UKDOG_DOM.������
					JOIN stack.����������� AS ORG
						ON UK_DOM.[�����������-��]=ORG.ROW_ID
		),
--����
ODPU
	AS 
		(			
		SELECT 
			CASE 
				WHEN doc.����� IS NOT NULL THEN '��'
				WHEN doc.����� IS NULL THEN '���'
			END AS [������� ����]
			,LI.�������
		FROM stack.[������� ��������] LI
		JOIN [stack].[��������� ���������] ps ON LI.�������� = ps.[���������-����]  AND  LI.�����������=3
		JOIN [stack].[��������] doc  on doc.[ROW_ID] = ps.[���������-��������] AND doc.[��� ���������] = 77 AND ps.��� = 6 AND doc.�������� = 0
		JOIN stack.[��������� ��������] AS SS
			ON SS.[����-�������� ���������]=LI.������� AND SS.���������!=3 
			AND @date BETWEEN SS.������ AND SS.������
		),
--��� ��������
TYPE_STROY
	AS
		(	
		SELECT	
			LI.�������
			,LI.��������
			,CASE
				WHEN ISNULL(OP.��������,OPD.��������)=0 THEN '���������������'
				WHEN ISNULL(OP.��������,OPD.��������)=1 THEN '�������'
				WHEN ISNULL(OP.��������,OPD.��������)=2 THEN '���������'
				WHEN ISNULL(OP.��������,OPD.��������)=3 THEN '����'
				WHEN ISNULL(OP.��������,OPD.��������)=4 THEN '�����'
				WHEN ISNULL(OP.��������,OPD.��������)=5 THEN '����'
				WHEN ISNULL(OP.��������,OPD.��������)=6 THEN '�����'
				WHEN ISNULL(OP.��������,OPD.��������)=7 THEN '������'
				WHEN ISNULL(OP.��������,OPD.��������)=8 THEN '������ ���������������'
				ELSE '�� ���������'
			 END AS [��� ��������]
		FROM stack.[������� ��������] AS LI
--��� ��
		LEFT JOIN stack.�������� AS OP 
			ON OP.[����-���������]=LI.������� 
			AND (@date BETWEEN OP.������ AND OP.������)
			AND OP.[����-���������]=@�������������������
--��� ����
		LEFT JOIN stack.�������� AS OPD 
			ON OPD.[����-���������]=LI.�������� 
			AND (@date BETWEEN OPD.������ AND OPD.������)
			AND OPD.[����-���������]=@�������������������
		WHERE LI.�����������=3 AND LI.����������=5
		),
--�� ����
TYPE_UL
	AS
		(
			SELECT
				OP.[����-���������] AS �������
			,CASE 
				WHEN OP.�������� IS NULL THEN '���'
				WHEN OP.�������� IS NOT NULL THEN '��'
				ELSE '�� ���������'
			END AS ������
			FROM stack.�������� AS OP  
			WHERE OP.[����-���������]=@�������������� AND @date BETWEEN OP.������ AND OP.������
		),
--��� ����������
FIO 
	AS
		(
			SELECT	CR.[����-����������],
					CR.��� AS ���
			FROM	stack.[�������� �����������] AS CR
		),
--������ + � ���������� ���������
ADDRES
	AS
		(
			SELECT	pvt_adrs.������� AS �������
			 		,[0] +' '+ [1] AS �����
					,ISNULL(CITY.����������, ' ') AS [��� ��]
					,ISNULL(CITY.��������, ' ')AS [���������� �����]
					,ISNULL(STREET.����������, ' ') AS [��� �����]
					,ISNULL(STREET.��������, ' ') AS �����
					,ISNULL(HOUSE.�����, ' ') AS ���
					,ISNULL(HOUSE.�������, ' ') AS ������
					,ISNULL(FLAT.�����, ' ') AS ��������
					,ISNULL(FLAT.�������, ' ') AS [������� ��������]
					,(ISNULL(CITY.����������+'.'+' '+CITY.��������, ' ') + ' '+ISNULL(STREET.����������+'.'+' '+STREET.��������, ' ')+' '
					+ ISNULL(CAST(HOUSE.����� AS nvarchar(12)), ' ') + ' '+ISNULL(CAST(HOUSE.������� AS nvarchar(12)), ' ') +' '
					+ISNULL(CAST(FLAT.����� AS nvarchar(12)), ' ')+' '+ISNULL(CAST(FLAT.������� AS nvarchar(12)), ' ')
					) AS �����
			FROM
			(
				SELECT 
					LI.�����������,
					LI.�������,
					CASE WHEN LI.�����������=0 THEN LS.�������
					     WHEN LI.�����������=1 THEN ORG.��������
						 WHEN LI.����������� IN (12,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
						 WHEN LI.����������� IN (11,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
						 WHEN LI.����������� IN (13,2) THEN CAST(CY.ROW_ID AS nvarchar(12))
						 WHEN LI.�����������=3 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
						 WHEN LI.�����������=4 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
						 WHEN LI.�����������=5 THEN CAST(LS.ROW_ID AS nvarchar(12)) 
					END AS �����
			FROM stack.[������� ��������] AS LI
			JOIN stack.[������� �����] AS LS 
				ON LI.��������=LS.ROW_ID 
			LEFT JOIN stack.������ AS CY
				ON LS.[�����-������� ����]=CY.ROW_ID
--�������
			LEFT JOIN stack.����������� AS ORG
				ON ORG.ROW_ID=LS.[����-�������� �������] 
--������������ �����-�������
		) AS pvt_adrs
		PIVOT (
				MAX(�����) FOR pvt_adrs.����������� IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
			  ) AS pvt_adrs
		LEFT JOIN stack.������ AS CITY
			ON CITY.ROW_ID=CAST([12] AS int)
		LEFT JOIN stack.������ AS STREET
			ON STREET.ROW_ID=CAST([2] AS int)
		LEFT JOIN stack.[������� �����] AS HOUSE
			ON HOUSE.ROW_ID=CAST([3] AS int)
		LEFT JOIN stack.[������� �����] AS FLAT
			ON FLAT.ROW_ID=CAST([4] AS int)
		),
--�������� ������
INDEX_
	AS
		(
			SELECT	
				LI.�������
				,CASE
					WHEN LS.��������������=0 OR LS.�������������� IS NULL 
					THEN ISNULL(OP.��������,OPD.��������)
					END AS ������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LI.������� 
				AND (@date BETWEEN OP.������ AND OP.������)
				AND OP.[����-���������]=@��������������  
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� 
				AND (@date BETWEEN OPD.������ AND OPD.������)
				AND OPD.[����-���������]=@��������������  
			WHERE LI.�����������=3 AND LI.����������=5
		),
--���������� � ��
SCHETCHIK 
	AS
		(
			SELECT  SO.[�������-����] AS �������
					, NR.������������ AS [��� ��]
					, SO.�������������� AS [����� ��]
					, SO.����������
					, SO.�����������
					, SO.[����������� �������������] AS [����.������]
					,CASE
						WHEN SS.��������� = 0 THEN '����������'
						WHEN SS.��������� = 1 THEN '���'
						WHEN SS.��������� = 2 THEN '�������'
						WHEN SS.��������� = 3 THEN '��������'
					END AS [��� �������]
			FROM stack.[������ ��������] AS SO 
			LEFT JOIN stack.������������ AS NR 
				ON SO.[������������-�������]=NR.ROW_ID
			JOIN stack.[��������� ��������] AS SS
				ON SS.[����-�������� ���������]=SO.[�������-����] AND SS.���������!=3 AND
				@date BETWEEN SS.������ AND SS.������
			WHERE @date BETWEEN SO.������ AND SO.������
		),
--���������� �� ����������
POKAZANIYA 
	AS 
		(
		SELECT
				OL.[�������-����] AS �������		
				,POK1.��������� AS [�����������]
				,POK1.���� AS [���������������]
				,TE1.Typename AS [��������������]
				,POK2.��������� AS [�����������]
				,POK2.���� AS [���������������]
				,TE2.Typename AS [��������������]
				,POK3.��������� AS [�����������]
				,POK3.���� AS [���������������]
				,TE3.Typename AS [��������������]
				,PREDPOK1.��������� AS [�����������]
				,PREDPOK1.���� AS [���������������]
				,TEPRED1.Typename AS [��������������]
				,PREDPOK2.��������� AS [�����������]
				,PREDPOK2.���� AS [���������������]
				,TEPRED2.Typename AS [��������������]				
				,PREDPOK3.���� AS [���������������]
				,PREDPOK3.��������� AS [�����������]
				,TEPRED3.Typename AS [��������������]
		FROM stack.[������ ��������] AS OL 
		LEFT JOIN stack.������������ AS NR 
			ON OL.[������������-�������]=NR.ROW_ID
		OUTER APPLY
			(SELECT TOP 1 TS.���������, TS.����, TS.��������
			FROM stack.[��������� ���������] AS TS
			WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
			AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
			ORDER BY TS.���� DESC) AS POK1
		OUTER APPLY
		(SELECT TOP 1 TS.���������,TS.����, TS.��������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK2
		OUTER APPLY
		(
		SELECT TOP 1 TS.���������, TS.����, TS.��������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK3
--�������������
		OUTER APPLY
		(SELECT TOP 1 TS.���������, TS.����, TS.�������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
		AND POK1.����!=TS.����
		ORDER BY TS.���� DESC) AS PREDPOK1
		OUTER APPLY
		(SELECT TOP 1 TS.���������, TS.����, TS.�������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
		AND POK2.����!=TS.����
		ORDER BY TS.���� DESC) AS PREDPOK2
		OUTER APPLY
		(SELECT TOP 1 TS.���������, TS.����, TS.�������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
		AND POK3.����!=TS.����
		ORDER BY TS.���� DESC) AS PREDPOK3
		LEFT JOIN #TypeEnter AS TE1
		ON TE1.flags=POK1.��������
		LEFT JOIN #TypeEnter AS TE2
		ON TE2.flags=POK2.��������
		LEFT JOIN #TypeEnter AS TE3
		ON TE3.flags=POK3.��������
		LEFT JOIN #TypeEnter AS TEPRED1
		ON TEPRED1.flags=PREDPOK1.��������
		LEFT JOIN #TypeEnter AS TEPRED2
		ON TEPRED2.flags=PREDPOK2.��������
		LEFT JOIN #TypeEnter AS TEPRED3
		ON TEPRED3.flags=PREDPOK3.��������
		WHERE (@date BETWEEN OL.������ AND OL.������)
),
--����������
NACHISLENO
	AS 
		(SELECT	NT.���� AS ������� 
		, SUM(NT.�����) AS [��������������]
		, SUM(NT.�����) AS [��������������]
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		GROUP BY NT.����, NT.[����� �������]
		),
--���������� �� �������
NACH_100
	AS 
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS ���������_100
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		AND NT.[����� ������]  BETWEEN 100 AND 199
		OR NT.[����� ������]  BETWEEN 400 AND 499
		GROUP BY NT.����, NT.[����� �������]
		),
NACH_300
	AS 
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS ���������_300
		FROM  stack.������ AS NT
		WHERE   NT.[����� �������]=@date
			AND NT.[����� ������]  BETWEEN 300 AND 399
			OR  NT.[����� ������]  BETWEEN 3700 AND 3799
			OR  NT.[����� ������]  BETWEEN 3800 AND 3899
			OR  NT.[����� ������]  BETWEEN 3900 AND 3999
		GROUP BY NT.����, NT.[����� �������]
		),
--����������
PERERASCH
	AS
		(
		SELECT NP.���� AS �������
			   , SUM(NP.�����) AS [����� �����������]
			   , SUM(NP.�����) AS [����� �����������]
		FROM stack.������� AS NP
		WHERE NP.[����� �������]=@date
		GROUP BY NP.����
		),
--������ �������� 100,400
SALDO_VHOD_100
	AS
		(
			SELECT SUM(S.Summa) AS ������_100,
					S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) 
							AND NS.[����� ������]  BETWEEN 100 AND 199
							OR NS.[����� ������]  BETWEEN 400 AND 499
							GROUP BY NS.����
				) AS S
			GROUP BY S.����
		),
--������ �������� 300,350,3700,3800,3900
SALDO_VHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS ������_300,
				   S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) 
							AND NS.[����� ������] BETWEEN 300 AND 399
							OR NS.[����� ������]  BETWEEN 3700 AND 3799
							OR NS.[����� ������]  BETWEEN 3800 AND 3899
							OR NS.[����� ������]  BETWEEN 3900 AND 3999
							GROUP BY NS.����			
							) AS S
					GROUP BY S.����
		),
--������ ��������� 100
SALDO_ISHOD_100
	AS
		(
			SELECT SUM(S.Summa) AS ���������_100,
					S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]= @date 
							AND NS.[����� ������] BETWEEN 100 AND 199 
							OR NS.[����� ������] BETWEEN 400 AND 499
							GROUP BY NS.����
				) AS S
			GROUP BY S.����
		),
--������ ��������� 300
SALDO_ISHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS ���������_300,
					S.���� AS �������
			FROM(
						    SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]= @date
							AND NS.[����� ������]  BETWEEN 300 AND 399
							OR NS.[����� ������]  BETWEEN 3700 AND 3799
							OR NS.[����� ������]  BETWEEN 3800 AND 3899
							OR NS.[����� ������]  BETWEEN 3900 AND 3999
							GROUP BY NS.����
				) AS S
			GROUP BY S.����
		),
--����
PENYANACH
	AS
		(
			SELECT  PN.���� AS �������
					,SUM(PN.�����) AS �������
			FROM stack.�������������� AS PN
			WHERE  PN.[����� �������]=@date
			GROUP BY PN.����
		),
--���� ���������
PENYAISALDO
	AS
		(
			SELECT  PSI.���� AS ������� 
					,SUM(PSI.�����) AS ���������
			FROM stack.���������� AS PSI
			WHERE  PSI.[����� �������]=@date
			GROUP BY PSI.����
		),
--���� ��������
PENYAVSALDO
	AS
		(
			SELECT  PSV.���� AS �������
					,SUM(PSV.�����) AS ��������
			FROM stack.���������� AS PSV
			WHERE  PSV.[����� �������]=DATEADD(mm, -1, @date)
			GROUP BY PSV.����
		),
--������
PLATEJ
	AS
		(
		 SELECT TOP (1) WITH TIES 
               SO.���� AS [���� ��������� ������] 
              ,SO.[����-������] AS �������
         FROM stack.[������ ������] AS SO
         ORDER BY row_number() OVER (PARTITION BY SO.[����-������] ORDER BY SO.���� DESC)
		),
--���
ODN
	AS
		(
		SELECT O.[���������-����] AS �������
				,O.������
		FROM (SELECT TOP 1 PS.������,
			PS.[���������-����] 
		FROM stack.[��������� ���������] AS PS
		LEFT JOIN stack.�������� AS DOC
		ON DOC.ROW_ID=PS.[���������-��������] AND DOC.[��� ���������]=77 AND DOC.�������� = 0
		LEFT JOIN [stack].[������ ��������] AS SO ON SO.[�������-���������] = DOC.ROW_ID AND @date BETWEEN SO.������ AND SO.������) O
		),
--��
BU
	AS 
	(
		SELECT SUM(NT.�����) [��������� �� ���� ��]
			   ,SUM(NT.�����) AS [����� �� ���� ��]

			   ,NT.���� AS �������
		FROM stack.������ AS NT
		WHERE NT.[����� ������]=(
		SELECT TOP 1 TU.[����� ������]
		FROM stack.[���� �����] AS TU
		WHERE TU.������������='���������� �����������'
		) AND NT.[����� �������]=@date AND NT.����=150403
		GROUP BY  NT.����, NT.[����� �������]
	),
POSTAV_NAME
	AS (
			SELECT LI.�������,
					 ISNULL(ORG.��������,ORG_D.��������) AS [������������ ����������]
			FROM 
				 stack.[������� ��������] AS LI
--��� ��
			LEFT JOIN stack.���������� AS POS
			ON POS.[����-������ �����������]=LI.�������
			LEFT JOIN stack.����������� AS ORG
			ON ORG.ROW_ID=POS.[����������-������]
--��� ����
			LEFT JOIN stack.���������� AS POS_D
			ON POS_D.[����-������ �����������]=LI.��������
			LEFT JOIN stack.����������� AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[����������-������]
			WHERE LI.�����������=3 AND LI.����������=5 AND (@date BETWEEN POS.������ AND POS.������ OR @date BETWEEN POS_D.������ AND POS_D.������)
		),
PARAMETRS AS (

		SELECT 
			PVT.���� AS �������
		,CASE
			WHEN PVT.���������=0 THEN '������������' 
			WHEN PVT.���������=1 THEN '�� ���������' 
			WHEN PVT.���������=2 THEN '������' 
			ELSE '�� ���������'
		END AS ���������
		,CASE 
			WHEN PVT.������ IS NULL THEN '���'
			WHEN PVT.������ IS NOT NULL THEN '��'
			ELSE '�� ���������'
		END AS ������ 
		,CASE
			WHEN PVT.��������=0 THEN '���������������'
			WHEN PVT.��������=1 THEN '�������'
			WHEN PVT.��������=2 THEN '���������'
			WHEN PVT.��������=3 THEN '����'
			WHEN PVT.��������=4 THEN '�����'
			WHEN PVT.��������=5 THEN '����'
			WHEN PVT.��������=6 THEN '�����'
			WHEN PVT.��������=7 THEN '������'
			WHEN PVT.��������=8 THEN '������ ���������������'
			ELSE '�� ���������'
		END AS �������� 
		,������� 
		,����
		,������
		,����������
	FROM (
		SELECT TOP(1) WITH TIES 
			LH.������� AS ����,
			V.��������,
			O.��������
		FROM [stack].[������� ��������] AS LH
		JOIN [stack].[��������] AS O 
		  ON O.[����-���������] = LH.��������
			 AND @date BETWEEN O.������ AND   O.������
		JOIN [stack].[���� ����������] AS V ON V.row_id = O.[����-���������]
		WHERE LH.���������� = 5
		  AND O.[����-���������] IN (SELECT row_id FROM [stack].[���� ����������] WHERE �������� IN ('���������', '������', '��������', '�������', '����', '������', '����������'))
		ORDER BY ROW_NUMBER() OVER (PARTITION BY LH.�������, O.[����-���������] ORDER BY LH.�������)
	) AS T	
	PIVOT (
		MAX(��������) FOR �������� IN (���������, ������, ��������, �������, ����, ������, ����������)
	) AS PVT
	),
	USLUGA
	AS
		(
			SELECT	LI.�������
			,T.�������� AS �����
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
			WHERE LI.�����������=3 AND LI.����������=5 
			AND T.������=(
			SELECT TOP 1 T.������
			FROM stack.[������] AS T			
			WHERE T.[���-������]=TUD.ROW_ID OR TU.ROW_ID=T.[���-������]
			ORDER BY T.������ DESC)
			GROUP BY LI.�������
			, T.��������),
--������� � e-mail
PHONE
	AS
		(
			SELECT 
					[stack].[CLR_Concat](PH.�����) AS �������
					,PH.[����-�������]
			FROM  stack.[��������] AS PH
			WHERE  PH.���!=4 
			GROUP BY PH.[����-�������]
		),
EMAILS
	AS
		(
			SELECT 
					[stack].[CLR_Concat](EM.�����) AS [E-MAIL]
					, EM.[����-�������]
			FROM stack.[��������] AS EM
			WHERE EM.���=4
			GROUP BY EM.[����-�������] 
		)
 SELECT	
		 LS.�������
		 ,DN.[����� ��������]
		 ,DN.[������� �������]
		 ,(iSNULL(ODPU.[������� ����], '���')) AS [������� ���� 1 - ��, 0 - ���]
		 ,FIO.���
		 ,TS.[��� ��������]
		 ,ISNULL(TU.������, '���') AS [������]
		 ,AD.�����
		 ,IND.������
		 ,AD.�����
		 ,AD.[��� ��]
		 ,AD.[���������� �����]
		 ,AD.[��� �����]
		 ,AD.�����
		 ,AD.���
		 ,AD.������
		 ,AD.��������
		 ,SC.[��� ��]
		 ,SC.[����� ��]
		 ,SC.����������
		 ,SC.�����������
		 ,SC.[����.������]
		 ,POK.��������������� 
		 ,POK.����������� 
		 ,POK.�������������� 
		 ,POK.��������������� 
		 ,POK.����������� 
		 ,POK.�������������� 
		 ,POK.���������������
		 ,POK.����������� 
		 ,POK.�������������� 
		 ,POK.��������������� 
		 ,POK.����������� 
		 ,POK.��������������
		 ,POK.���������������
		 ,POK.����������� 
		 ,POK.�������������� 
		 ,POK.���������������
		 ,POK.����������� 
		 ,POK.�������������� 
		 ,ISNULL(NA.[��������������], 0) AS [����� ��������������� �����������]
	     ,ISNULL(PER.[����� �����������], 0) AS [����� �����������]
		 ,PER.[����� �����������]
 		 ,SC.[��� �������]
		 ,(NA.��������������+ISNULL(PEN.�������, 0)) AS [��������� ��������������� �����������]
		 ,NACH_100.���������_100
		 ,NACH_300.���������_300
		 ,ODN.������
		 ,SV100.������_100
		 ,SV300.������_300
		 ,(ISNULL(NA.[��������������], 0)+ISNULL(PER.[����� �����������], 0)) AS [����� �����] 
		 ,U.�����
		---- ,(ISNULL(NA.[��������� ��������������� �����������], 0) AS [��������� ����� 100,400]
		 ,PL.[���� ��������� ������]
		--,PL.����� AS [������ �����]
		 ,BU.[����� �� ���� ��]
	     ,BU.[��������� �� ���� ��]
		 ,SI100.���������_100
		 ,SI300.���������_300
		 ,P.������
		 ,P.������
		 ,P.�������� [��� �������������]
		 ,P.����
		 ,P.�������
		 ,P.����������
		 ,U.[����� ������]
		 ,PN.[������������ ����������]
		 ,PH.�������
		,ISNULL(EM.[E-MAIL], '���') AS [E-Mail]
 --������� ��� ������� join, row_id � ������ �����
 FROM #Result AS LS
 LEFT JOIN DOG_NUM AS DN ON LS.ROW_ID=DN.�������
 LEFT JOIN ODPU ON ODPU.�������=LS.ROW_ID
 LEFT JOIN FIO ON FIO.[����-����������]=LS.ROW_ID
 LEFT JOIN TYPE_STROY AS TS ON TS.�������=LS.ROW_ID 
 LEFT JOIN TYPE_UL AS TU ON TU.�������=LS.ROW_ID
 LEFT JOIN INDEX_ AS IND ON IND.�������=LS.ROW_ID
 LEFT JOIN SCHETCHIK AS SC ON SC.�������=LS.ROW_ID
 LEFT JOIN POKAZANIYA AS POK ON POK.�������=LS.ROW_ID
 LEFT JOIN ADDRES AS AD ON AD.�������=LS.ROW_ID
 LEFT JOIN NACHISLENO AS NA ON NA.�������=LS.ROW_ID
 LEFT JOIN PENYANACH AS PEN ON PEN.�������=LS.ROW_ID
 LEFT JOIN NACH_100 ON NACH_100.�������=LS.ROW_ID
 LEFT JOIN NACH_300 ON NACH_300.�������=LS.ROW_ID
 LEFT JOIN PERERASCH AS PER ON PER.�������=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_100 AS SV100 ON SV100.�������=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_100 AS SI100 ON SI100.�������=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_300 AS SV300 ON SV300.�������=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_300 AS SI300 ON SI300.�������=LS.ROW_ID
 LEFT JOIN PENYAVSALDO AS PSV ON PSV.�������=LS.ROW_ID
 LEFT JOIN PENYAISALDO AS PSI ON PSI.�������=LS.ROW_ID
 LEFT JOIN PLATEJ AS PL ON PL.�������=LS.ROW_ID
 LEFT JOIN BU ON BU.�������=LS.ROW_ID
 LEFT JOIN ODN ON ODN.�������=LS.ROW_ID
 LEFT JOIN PARAMETRS AS P ON p.�������=LS.ROW_ID
 LEFT JOIN PHONE AS PH ON LS.ROW_ID=PH.[����-�������]
 LEFT JOIN EMAILS AS EM ON LS.ROW_ID=EM.[����-�������] 
 LEFT JOIN POSTAV_NAME AS PN ON PN.�������=LS.ROW_ID
 LEFT JOIN USLUGA AS U ON LS.ROW_ID = U.�������
WHERE LS.ROW_ID IN (@account) 
-- DROP TABLE #TypeEnter
