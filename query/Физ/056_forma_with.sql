USE tns_kuban_fl_dev;
DECLARE @date datetime='20200301';
	CREATE TABLE #TypeEnter
	(flags INT PRIMARY KEY,
     Typename NVARCHAR(30) NOT NULL)
	 INSERT INTO #TypeEnter
	 VALUES			(0 , '��')
					,(1 , '��')
					,(2 , '��')
					,(3 , '��')
					,(4 , '���������')
					,(5 , '������')
					,(6 , '��/�')
					,(7 , '���������')
					,(8 , '����')
					,(9 , 'WEB')
					,(10 , 'OUT')
					,(11 , '�����')
					,(12 , '�������')
					,(13 , '����')
					,(14 , '�����')
					,(15 , '�������')
					,(16 , 'SMS')
					,(17 , '���')
					,(18 , '���');
WITH 
--���������� ��� ����
--������� ����
--����� �������� (�� �������� ��������), �������� ���������, ���� � LS.ROW_ID ���������� ID ����
--���������� ����� ������� ��������
DOG_NUM
	AS
		(
					SELECT LI.�������			
						   ,UKDOG_DOM.����� AS [����� ��������]
						   ,ORG.�������� AS [����������� ����������� ��������]
					FROM  stack.[������� ��������] AS LI
					LEFT JOIN stack.[����������� ��������] AS UK_DOM
						ON UK_DOM.[����-��]=LI.�������� AND LI.[�����������]=3 
					JOIN stack.[�� ��������] AS UKDOG_DOM
						ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] AND
						@date BETWEEN UKDOG_DOM.������ AND UKDOG_DOM.������
					JOIN stack.����������� AS ORG
						ON UK_DOM.[�����������-��]=ORG.ROW_ID
					WHERE LI.�����������=3 
		),
--������� �������
--������� ����
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
				AND OP.[����-���������]=(
					SELECT TOP 1 VP.ROW_ID
					FROM stack.[���� ����������] AS VP
					WHERE VP.��������='��������'
				)
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� 
				AND (@date BETWEEN OPD.������ AND OPD.������)
				AND OPD.[����-���������]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[���� ����������] AS VPD
					WHERE VPD.��������='��������'
				 )
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
			WHERE OP.[����-���������]=(
					SELECT TOP 1 VP.ROW_ID
					FROM stack.[���� ����������] AS VP
					WHERE VP.��������='������'
				) AND @date BETWEEN OP.������ AND OP.������
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
 SELECT				[5] AS �������
					,[0] +' '+ [1] AS �����,
					ISNULL(CITY.����������, ' ') AS [��� ��]
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
			WHERE LI.����������=5
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
				AND OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='������'
					 )
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� 
				AND (@date BETWEEN OPD.������ AND OPD.������)
				AND OPD.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='������'
					 )
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
						WHEN SS.���������=0 THEN '����������'
						WHEN SS.��������� = 1 THEN '���'
						WHEN SS.��������� = 2 THEN '�������'
						WHEN SS.��������� = 3 THEN '��������'
					END AS [��� ������� (���, ��������, �������)]
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
				,POK1.��������� AS [��������� ��������� ����]
				,POK1.���� AS [���� ��������� ��������� ����]
				,TE1.Typename AS [��� ���������� ��������� ����]
				,POK2.��������� AS [��������� ��������� ����]
				,POK2.���� AS [���� ��������� ��������� ����]
				,TE2.Typename AS [��� ���������� ��������� ����]
				,POK3.��������� AS [��������� ��������� ����]
				,POK3.���� AS [���� ��������� ��������� ����]
				,TE3.Typename AS [��� ���������� ��������� ����]
				,PREDPOK1.��������� AS [���������� ��������� ����]
				,PREDPOK1.���� AS [���� ������������� ��������� ����]
				,TEPRED1.Typename AS [��� �������������� ��������� ����]
				,PREDPOK2.��������� AS [���������� ��������� ����]
				,PREDPOK2.���� AS [���� ���������� ��������� ����]
				,TEPRED2.Typename AS [��� �������������� ��������� ����]				
				,PREDPOK3.���� AS [���� ���������� ��������� ����]
				,PREDPOK3.��������� AS [���������� ��������� ����]
				,TEPRED3.Typename AS [��� �������������� ��������� ����]
	FROM 
		stack.[������ ��������] AS OL 
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
	(
		SELECT TOP 1 TS.���������, TS.����, TS.�������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
		AND POK1.����!=TS.����
		ORDER BY TS.���� DESC) AS PREDPOK1
	OUTER APPLY
	(
		SELECT TOP 1 TS.���������, TS.����, TS.�������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
		AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
		AND POK2.����!=TS.����
		ORDER BY TS.���� DESC) AS PREDPOK2
	OUTER APPLY
	(
		SELECT TOP 1 TS.���������, TS.����, TS.�������� 
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
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS [��������� ��������������� �����������]
				, SUM(NT.�����) AS [����� ��������������� �����������]
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		GROUP BY NT.����
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
			SELECT SUM(S.Summa) AS [������ �� ������ ������ 100,400],
					S.���� AS �������
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
			GROUP BY S.����
		),
--������ �������� 300,350,3700,3800,3900
SALDO_VHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS [������ �� ������ ������ 300,350,3700,3800,3900],
				   S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) AND NS.[����� ������]  BETWEEN 300 AND 399
							GROUP BY NS.����, NS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=DATEADD(mm, -1, @date) AND VS.[����� ������]  BETWEEN 3700 AND 3799
							GROUP BY VS.����, VS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=DATEADD(mm, -1, @date) AND VS.[����� ������]  BETWEEN 3800 AND 3899
							GROUP BY VS.����, VS.[����� ������]							
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=DATEADD(mm, -1, @date) AND VS.[����� ������]  BETWEEN 3900 AND 3999
							GROUP BY VS.����, VS.[����� ������]							
							) AS S
					GROUP BY S.����
		),
--������ ��������� 100
SALDO_ISHOD_100
	AS
		(
			SELECT SUM(S.Summa) AS [������ �� ����� ������ 100,400],
					S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]= @date AND NS.[����� ������]  BETWEEN 100 AND 199
							GROUP BY NS.����, NS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=@date AND VS.[����� ������]  BETWEEN 400 AND 499
							GROUP BY VS.����, VS.[����� ������]) AS S
			GROUP BY S.����
		),
--������ ��������� 300
SALDO_ISHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS [������ �� ����� ������ 300,350,3700,3800,3900],
					S.���� AS �������
			FROM(
						  SELECT NS.����
								 , SUM(NS.�����) AS Summa
							FROM stack.������� AS NS
							WHERE  NS.[����� �������]= @date AND NS.[����� ������]  BETWEEN 300 AND 399
							GROUP BY NS.����, NS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=@date AND VS.[����� ������]  BETWEEN 3700 AND 3799
							GROUP BY VS.����, VS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=@date AND VS.[����� ������]  BETWEEN 3800 AND 3899
							GROUP BY VS.����, VS.[����� ������]
						UNION
							SELECT VS.����
								 , SUM(VS.�����) AS Summa
							FROM stack.������� AS VS
							WHERE   VS.[����� �������]=@date AND VS.[����� ������]  BETWEEN 3900 AND 3999
							GROUP BY VS.����, VS.[����� ������]) AS S
			GROUP BY S.����
		),
--������
PLATEJ
	AS
		(
			SELECT TOP 1 SO.���� AS [���� ��������� ������]
			,SO.[����-������] AS �������
			FROM stack.[������ ������] AS SO
			--WHERE SO.[����-������]=164180
			ORDER BY  SO.���� DESC
		),
--���
ODN
	AS
		(
		SELECT TOP 1 PS.������,
			PS.[���������-����] AS �������
		FROM stack.[��������� ���������] AS PS
		JOIN stack.[���� �����] AS TU
		 ON TU.ROW_ID=PS.[���������-������]
		LEFT JOIN stack.�������� AS DOC
		ON DOC.ROW_ID=PS.[���������-��������]
		WHERE DOC.[��� ���������]=77
		--AND PS.[���������-����]=164180
		ORDER BY PS.���� DESC
		),
--���� ��
BU
	AS 
	(
		SELECT RA.[����-������ ����] AS �������
			,SUM(RA.���������) AS [����� �� ���� ��]
			,SUM(RA.���������) AS [��������� �� ���� ��]
		FROM	stack.[������ ����] AS RA
		Where	 @date=RA.����� 
		GROUP BY RA.[����-������ ����]
	),
--����� ������
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
			, T.��������
		),
--������� ����
SQUARE_
	AS
		(
			SELECT	OP.[����-���������] AS �������
					,OP.�������� AS �������
			FROM  stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT  TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='����������') 
			AND (@date BETWEEN OP.������ AND OP.������)
		),
--���������� ������
ROOMS
	AS
		(
			SELECT	OP.[����-���������] AS �������
					,OP.�������� AS ������
			FROM  stack.�������� AS OP 
				WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='�������') 
				AND (@date BETWEEN OP.������ AND OP.������)
		),
--���������� �����������
PROPISAN
	AS
		(
			SELECT	OP.[����-���������] AS �������
					,OP.�������� AS ���������
			FROM stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='����') 
			AND (@date BETWEEN OP.������ AND OP.������)
		),
--��������� ��
SOST_LS
	AS
		(
			SELECT  OP.[����-���������] AS �������
				,CASE
					WHEN OP.��������=0 THEN '������������' 
					WHEN OP.��������=1 THEN '�� ���������' 
					WHEN OP.��������=2 THEN '������' 
				END AS [��������� �������� (��� ����������)]
			FROM stack.�������� AS OP 
				WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='���������') 
				AND (@date BETWEEN OP.������ AND OP.������)
		),
--���������
POSTAV_NAME
	AS
		(
			SELECT  LI.�������,
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
--������� � e-mail
--����� �������� �� ��� � � ������������ � ��� ���������� �� ��������+������� � ���� ������, ���� ���������
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
		 LS.�����
		 ,DN.[����� ��������]
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
		 ,AD.[������� ��������]
		 ,SC.[��� ��]
		 ,SC.[����� ��]
		 ,SC.����������
		 ,SC.�����������
		 ,SC.[����.������]
		 ,POK.[���� ��������� ��������� ����]
		 ,POK.[��������� ��������� ����]
		 ,POK.[��� ���������� ��������� ����]
		 ,POK.[���� ������������� ��������� ����]
		 ,POK.[���������� ��������� ����]
		 ,POK.[��� �������������� ��������� ����]
		 ,POK.[���� ��������� ��������� ����]
		 ,POK.[��������� ��������� ����]
		 ,POK.[��� ���������� ��������� ����]
		 ,POK.[���� ���������� ��������� ����]
		 ,POK.[���������� ��������� ����]
		 ,POK.[��� �������������� ��������� ����]
		 ,ISNULL(POK.[���� ��������� ��������� ����], ' ') AS [���� ��������� ��������� ����]
		 ,ISNULL(POK.[��������� ��������� ����],' ') AS [��������� ��������� ����]
		 ,ISNULL(POK.[��� ���������� ��������� ����],' ') AS [��� ���������� ��������� ����]
		 ,ISNULL(POK.[���� ���������� ��������� ����],' ') AS [���� ���������� ��������� ����]
		 ,ISNULL(POK.[���������� ��������� ����],' ') AS [���������� ��������� ����]
		 ,ISNULL(POK.[��� �������������� ��������� ����],' ') AS [��� �������������� ��������� ����]
		 ,ISNULL(NA.[����� ��������������� �����������], 0) AS [����� ��������������� �����������]
		 ,ISNULL(PER.[����� �����������], 0) AS [����� �����������]
		 ,SC.[��� ������� (���, ��������, �������)]
		 ,NA.[��������� ��������������� �����������]
		 ,SV100.[������ �� ������ ������ 100,400]
		 ,SV300.[������ �� ������ ������ 300,350,3700,3800,3900]
		 ,(ISNULL(NA.[����� ��������������� �����������], 0)+ISNULL(PER.[����� �����������], 0)) AS [����� �����] 
		 ,U.�����
		-- ,(ISNULL(NA.[��������� ��������������� �����������], 0) AS [��������� ����� 100,400]
		 ,PL.[���� ��������� ������] 
		 ,BU.[����� �� ���� ��]
		 ,BU.[��������� �� ���� ��]
		 ,SI100.[������ �� ����� ������ 100,400]
		 ,SI300.[������ �� ����� ������ 300,350,3700,3800,3900]
		,U.[����� ������]
		 ,SQ.�������
		 ,R.������
		 ,PR.���������
		 ,U.[��� �������������]
		 ,SL.[��������� �������� (��� ����������)]
		 ,PN.[������������ ����������]
		 ,PH.�������
		 ,ISNULL(EM.[E-MAIL], '���') AS [E-Mail]
 --������� ��� ������� join, row_id � ������ �����
 FROM stack.[������� �����] AS LS
 LEFT JOIN DOG_NUM AS DN ON LS.ROW_ID=DN.�������
 LEFT JOIN FIO ON FIO.[����-����������]=LS.ROW_ID
 LEFT JOIN TYPE_STROY AS TS ON TS.�������=LS.ROW_ID 
 LEFT JOIN TYPE_UL AS TU ON TU.�������=LS.ROW_ID
 LEFT JOIN INDEX_ AS IND ON IND.�������=LS.ROW_ID
 LEFT JOIN SCHETCHIK AS SC ON SC.�������=LS.ROW_ID
 LEFT JOIN POKAZANIYA AS POK ON POK.�������=LS.ROW_ID
 LEFT JOIN ADDRES AS AD ON AD.�������=LS.ROW_ID
 LEFT JOIN NACHISLENO AS NA ON NA.�������=LS.ROW_ID
 LEFT JOIN PERERASCH AS PER ON PER.�������=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_100 AS SV100 ON SV100.�������=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_100 AS SI100 ON SI100.�������=LS.ROW_ID
 LEFT JOIN SALDO_VHOD_300 AS SV300 ON SV300.�������=LS.ROW_ID
 LEFT JOIN SALDO_ISHOD_300 AS SI300 ON SI300.�������=LS.ROW_ID
 LEFT JOIN PLATEJ AS PL ON PL.�������=LS.ROW_ID
 LEFT JOIN BU ON BU.�������=LS.ROW_ID
 LEFT JOIN SOST_LS AS SL ON LS.ROW_ID=SL.�������
 LEFT JOIN POSTAV_NAME AS PN ON LS.ROW_ID=PN.�������
 LEFT JOIN PROPISAN AS PR ON LS.ROW_ID=PR.�������
 LEFT JOIN ROOMS AS R ON LS.ROW_ID=R.�������
 LEFT JOIN USLUGA AS U ON LS.ROW_ID=U.�������
 LEFT JOIN SQUARE_ AS SQ ON LS.ROW_ID=SQ.�������
 LEFT JOIN PHONE AS PH ON LS.ROW_ID=PH.[����-�������]
 LEFT JOIN EMAILS AS EM ON LS.ROW_ID=EM.[����-�������] 
 WHERE LS.ROW_ID=164180 
 DROP TABLE #TypeEnter
