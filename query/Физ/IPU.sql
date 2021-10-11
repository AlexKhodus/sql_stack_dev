DECLARE @���� datetime='20200601'
DECLARE @������������������� INT = (SELECT TOP (1) ROW_ID FROM stack.[���� ����������] WHERE ��������='��������');
DECLARE @�������������� BIT = 0;
WITH ���� (�����, ���, �������, ��������) AS (
	SELECT
		D.�����,
		0, 
		LI.�������,
		LI.��������
	FROM [stack].[��������] AS D 
	JOIN [stack].[��������� ���������] PS 
	  ON D.[ROW_ID] = ps.[���������-��������]
		 AND PS.��� = 6
	JOIN stack.[������� ��������] LI ON LI.�������� = ps.[���������-����]
	JOIN [stack].[������ ��������] AS SO ON D.row_id = SO.[�������-���������]
	JOIN [stack].[������������] AS N ON N.row_id = SO.[������������-�������]
	JOIN [stack].[��������� ��������] AS SS ON SO.row_id = SS.[������-���������]
	WHERE D.[��� ���������] = 77
		AND D.�����_ADD = 1
		AND ISNULL(D.����������������, 0) = 0
		AND ISNULL(D.��������, 0) = 0
		AND ISNULL(N.�������������, 0) = 0
		AND GETDATE() BETWEEN SO.������ AND SO.������
		AND GETDATE() BETWEEN SS.������ AND SS.������
		AND SS.��������� = 1  
		
		UNION ALL
	
	SELECT 
		D.�����,
		1,
		LI.�������,
		LI.��������
	FROM [stack].[��������] AS D
	JOIN [stack].[��������� ���������] PS 
	  ON D.[ROW_ID] = ps.[���������-��������]
		AND PS.��� = 6
	JOIN stack.[������� ��������] LI ON LI.�������� = ps.[���������-����]
	JOIN [stack].[��������] AS O 
	  ON O.[��������-���������] = D.row_id
		AND GETDATE() BETWEEN O.������ AND O.������
		AND O.[����-���������] = (SELECT TOP(1) row_id FROM [stack].[���� ����������] WHERE �������� = '���������')
		AND O.�������� = 0
	LEFT JOIN stack.�������� PP
		ON PP.[��������-���������]=D.ROW_ID 
		AND @���� BETWEEn PP.������ AND PP.������
	WHERE D.[��� ���������] = 77
		AND D.�����_ADD = 1
		AND ISNULL(D.����������������, 0) = 1
		AND ISNULL(D.��������, 0) = 0
		AND LI.���������� = 5
		AND PP.��������!=2
), ������� AS (
	SELECT DISTINCT
		D.�����,
		D.���,
		D.�������,
		D.��������,
		O.��������
	FROM ���� AS D
	OUTER APPLY (
		SELECT TOP(1) O.��������
		FROM [stack].[������� ��������] AS LI
		JOIN [stack].[��������] AS O 
		  ON O.[����-���������] = LI.��������
		   AND O.[����-���������] = @�������������������
			AND @���� BETWEEN O.������ AND O.������
		WHERE LI.������� = D.�������
		ORDER BY ������� 
	) AS O
	WHERE O.�������� IN (0, 2)
),
����� AS(
 SELECT				pvt_adrs.������� AS �������,
					[0]  AS ������,
					[1] AS �������,
					CITY.���������� AS [��� ��],
					CITY.�������� AS [���������� �����],
					STREET.���������� AS [��� �����],
					STREET.�������� AS �����,
					HOUSE.����� AS ���,
					HOUSE.������� AS ������,
					FLAT.����� AS ��������,
					FLAT.������� AS [������� ��������],
					ROOM.������� AS �������
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
			LEFT JOIN stack.����������� AS ORG
				ON ORG.ROW_ID=LS.[����-�������� �������] 
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
		LEFT JOIN stack.[������� �����] AS ROOM
			ON ROOM.ROW_ID=CAST([5] AS int))
SELECT L.����� AS �����_��
,ISNULL(CAST(LS.����� AS nvarchar(256)),'') AS ���_���� 
,'��' �������_���_���
,CASE SLS.��������
	WHEN 0 THEN '������������'
	WHEN 1 THEN '�� ���������'
ELSE '������������'
END [����_��]
,CASE LS.��������
	WHEN 0 THEN '���������������'
	WHEN 2 THEN '���������'
	ELSE ''
END [���_��������]
,AD.������
,AD.�������		
,ISNULL(AD.[���������� �����],'') [����������_�����]
,ISNULL(AD.�����,'') [�����]
,ISNULL(AD.���,'') [���_����]
,ISNULL(AD.��������,'') [���_��������]
,ISNULL(AD.�������,'') [���_�������]
,CR.���
,CASE 
	WHEN US.��������=0 OR US.�������� IS NULL THEN '����'
	WHEN US.��������=1 THEN '���'
	ELSE ''
END [�����������_���_��]
,CASE
	WHEN F.������������ is null THEN '����������� ��'
	ELSE '��������������' END [���_��]
,CONVERT(VarChar(50), F.������, 104) [����_���������]
,CASE 
	WHEN F.��������� = 1 THEN '��������'
	WHEN F.��������� = 2 THEN '����������� �� ��������'
	WHEN F.��������� = 3 THEN '�� ��������'
	ELSE ''
  END [���������_��]
,F.������������ [������������_��]
,ISNULL(F.��������������,'') [�����_��]
,ISNULL(F.�����������,'') �����������
,ISNULL(F.����������,'') ����������
,ISNULL(F.[����������� �������������],'') [����_������]
,ISNULL(CONVERT(VarChar(50), F.����������, 104),'') [���_�������]
,CONVERT(VarChar(50), F.�����������, 104) [����_����_�������]
,ISNULL(PS.���,'') AS ���
,ISNULL(CONVERT(VarChar(50), F.��������������������, 104),'')  [����_����_�������]
,ISNULL(PS.[����� ��������],'') [�����_��������]
,ISNULL(PS.���,'') [���_��]
,ISNULL(PS.����,'') [���_��_���_��������]
,ISNULL(PS.����������,'') [����_��]
,CASE F.[����� ���������]
	WHEN 0 THEN '�� �����'
	WHEN 1 THEN '���������� ��������'
	WHEN 2 THEN '��������'
	WHEN 3 THEN '�������'
	WHEN 4 THEN '����� ���'
	WHEN 5 THEN '�������'
	WHEN 6 THEN '�����'
	WHEN 7 THEN '�����'
	WHEN 8 THEN '����� ������'
	WHEN 9 THEN '����� � �������� ���'
	WHEN 10 THEN '�������'
	WHEN 11 THEN '��� ���'
	WHEN 12 THEN '�� ��'
ELSE '�� �������'
END [�����_���������_��]
,ISNULL(F.��������, '') [�������_�����]
,CASE ASK.��������
	 WHEN 0 THEN '����������� ����������� �������' 
	 WHEN 1 THEN '���� ���������' 
	 WHEN 2 THEN '������������� ����������� � ����������' 
	 ELSE ''
END [�����] 
,ISNULL([stack].[CLR_Concat](SMS.�����), '') [���]
,ISNULL([stack].[CLR_Concat](AV.�����), '') [����������]
,ISNULL([stack].[CLR_Concat](PH.�����), '') [�������]
,ISNULL([stack].[CLR_Concat](EM.�����), '') [E_MAIL]
,ISNULL(ORG.��������, '')  [����_��]
,ISNULL(CAST(UKDOG_DOM.����� AS nvarchar(256)),'')  [���_���_��]
,F.���������� [����_�_�����_��]
,ISNULL(CONVERT(VarChar(50), P.[���� ���������], 104),'')  [����_����_������]
,CASE
	WHEN P.[��� ���������]=0 THEN '����'
	WHEN P.[��� ���������]=1 THEN '����'
	WHEN P.[��� ���������]=2 THEN '���'
	WHEN P.[��� ���������]=3 THEN '��������������'
	ELSE ''
END [���_��������_������]
,CASE
	WHEN P.���������=0 THEN '�����������'
	WHEN P.���������=1 THEN '�� ��������'
	WHEN P.���������=2 THEN '��������'
	ELSE ''
END [����_������]
FROM ������� AS LS
JOIN stack.[������� �����] As L ON L.ROW_ID=LS.�������
JOIN ����� AS AD ON AD.�������=LS.�������
JOIN stack.[�������� �����������] CR ON CR.[����-����������]=LS.�������
LEFT JOIN stack.�������� TU
	ON TU.[����-���������]=LS.������� 
				AND TU.[����-���������]=(
					SELECT TOP 1 VPD.ROW_ID
					FROM stack.[���� ����������] AS VPD
					WHERE VPD.��������='������'
				 )
				AND TU.�������� IS NULL
LEFT JOIN stack.�������� SLS ON SLS.[����-���������]=LS.�������
	AND (@���� BETWEEN SLS.������ AND SLS.������)
	AND SLS.[����-���������]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[���� ����������] VP
		WHERE VP.��������='���������'
		 )
LEFT JOIN stack.�������� US ON US.[����-���������]=LS.�������
	AND (@���� BETWEEN US.������ AND US.������)
	AND US.[����-���������]=(
		SELECT TOP 1 VP.ROW_ID
		FROM stack.[���� ����������] VP
		WHERE VP.��������='���_���_��'
		 )
OUTER APPLY
(
	SELECT TOP 1 SO.������, SO.ROW_ID so_row, NOM.ROW_ID  nom_row,
		SS.���������, NOM.������������,NOM.��������,SO.��������������,SO.�����������,SO.����������,SO.[����������� �������������],SO.���������� ,SO.�����������,so.[����� ���������],SO.����������, SO.��������������������  
	FROM stack.[������ ��������] AS SO 
	JOIN stack.[��������� ��������] SS
	  ON SS.[������-���������] = SO.row_id
         AND @���� BETWEEN SS.������ AND SS.������
	JOIN [stack].[������������] NOM on SO.[������������-�������]=nom.ROW_ID
	WHERE SO.[�������-����] = LS.������� 
	  AND @���� BETWEEN SO.������ AND SO.������
	  AND ISNULL(NOM.�������������, 0) = 0
	ORDER BY SO.������ DESC
) AS F
LEFT JOIN stack.�������� ASK ON ASK.[�������-���������]=F.so_row
	AND (@���� BETWEEN ASK.������ AND ASK.������)
	AND ASK.[����-���������]=2395
LEFT JOIN(	SELECT pvt.[60] AS ���,pvt.[23] AS [����� ��������], pvt.[28] AS ���������� ,pvt.[27] AS ���,pvt.[24] AS ����, pvt.������ AS �������
    FROM (            
		SELECT zp.[��������-��������] ��������, zp.��������,zp.[���-���������] AS ������
        FROM stack.[�������� ����������] zp
        WHERE zp.[��������-��������] in ( 23,24,27,28,60 )
         ) AS sv
    PIVOT ( max(��������) FOR �������� in ( [28], [27], [24], [60], [23] )
    ) AS pvt ) AS PS ON PS.�������=F.nom_row
LEFT JOIN stack.�������� PH
	ON PH.[����-�������]=LS.������� AND PH.�����=2
LEFT JOIN stack.�������� SMS
	ON SMS.[����-�������]=LS.������� AND SMS.�����=1	
LEFT JOIN stack.�������� AV
	ON AV.[����-�������]=LS.������� AND AV.�����=3
LEFT JOIN stack.[��������]  EM
	ON EM.[����-�������]=LS.������� AND EM.�����=4 
LEFT JOIN stack.[����������� ��������]  UK_DOM
		ON UK_DOM.[����-��]=LS.�������� 
		AND (@���� BETWEEN UK_DOM.������ AND UK_DOM.������)
LEFT JOIN stack.[�� ��������]  UKDOG_DOM
	ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] AND
	@���� BETWEEN UKDOG_DOM.������ AND UKDOG_DOM.������
LEFT JOIN stack.�����������  ORG
	ON UK_DOM.[�����������-��]=ORG.ROW_ID
OUTER APPLY(
			SELECT TOP 1  PL.[������-������]
			,PL.[���� ���������]
			,PL.[��� ���������]
			,PL.���������
			FROM stack.[������]  PL
			WHERE PL.[������-������]=F.so_row 
			ORDER BY PL.[���� ���������] DESC
		) AS P 
WHERE (TU.�������� IS NULL) AND (SLS.�������� IN (0,1) OR SLS.�������� IS NULL) AND (@��������������=0 OR  (F.so_row IS NOT NULL AND @���� >= DATEADD (year, CAST(PS.��� as int), F.�����������))) 
GROUP BY  L.�����,LS.�����,US.��������,LS.��������,SLS.��������,AD.������, AD.�������, AD.[���������� �����],AD.�����,AD.���,AD.��������,AD.�������, CR.���,F.������������,F.������,
F.���������,F.������������,F.��������������,F.�����������,F.����������,F.[����������� �������������] ,F.���������� ,F.�����������  ,F.�������������������� 
,F.[����� ���������],F.�������� ,ASK.��������,ORG.�������� ,UKDOG_DOM.�����,F.���������� 
,P.[���� ���������], P.[��� ���������],P.���������, PS.���,PS.[����� ��������],PS.����������,PS.���,PS.����
UNION ALL
SELECT 
	  LS.����� [�����_��]
	  ,ISNULL(CAST(ODPU.����� AS nvarchar(256)),'') [���_����]
	  ,'���' [�������_���_���]
	  ,CASE
			WHEN SLS.��������=0 THEN '������������'
			WHEN SLS.��������=1 THEN '�� ���������'
			WHEN SLS.��������=2 THEN '������'
	   END [����_��]
	  ,CASE
			WHEN ISNULL(OPTS.��������,OPTSH.��������)=0 THEN '���������������'
			WHEN ISNULL(OPTS.��������,OPTSH.��������)=2 THEN '���������'
			ELSE ''
	   END [���_��������]
		,'' ������
		,'' �������		
		,ISNULL(AD.[���������� �����],'') [����������_�����]
		,ISNULL(AD.�����,'') [�����]
		,ISNULL(AD.���,'') [���_����]
		,ISNULL(AD.��������,'') [���_��������]
		,ISNULL(AD.�������,'') [���_�������]
		,CR.��� [���]
		,CASE 
			WHEN US.��������=0 OR US.�������� IS NULL THEN '����'
			WHEN US.��������=1 THEN '���'
			ELSE ''
		 END [�����������_���_��]
		 ,CASE
			WHEN nom.������������ is null THEN '����������� ��'
			ELSE '��������������' END [���_��]
		 ,CONVERT(VarChar(50), SO.������, 104) [����_���������]
		 ,CASE 
			
			WHEN SS.��������� = 1 THEN '��������'
			WHEN SS.��������� = 2 THEN '����������� �� ��������'
			WHEN SS.��������� = 3 THEN '�� ��������'		
			ELSE ''
		  END [���������_��]
		 ,NOM.������������ [������������_��]
		 ,ISNULL(SO.��������������,'') [�����_��]
		 ,ISNULL(SO.�����������,'') �����������
		 ,ISNULL(SO.����������,'') ����������
		 ,ISNULL(SO.[����������� �������������],'') [����_������]
		 ,ISNULL(CONVERT(VarChar(50), SO.����������, 104),'') [���_�������]
		 ,CONVERT(VarChar(50), SO.�����������, 104) [����_����_�������]
		 ,ISNULL(MPI.��������,'') [���]
		 ,ISNULL(CONVERT(VarChar(50), SO.��������������������, 104),'')  [����_����_�������]
		 ,ISNULL(CT.��������,'') [�����_��������]
		 ,ISNULL(TOK.��������,'') [���_��]
		 ,ISNULL(KF.��������,'') [���_��_���_��������]
		 ,ISNULL(NAPR.��������,'') [����_��]
			  ,CASE 
				WHEN (SO.[����� ���������]=0)  THEN '�� �����'
				WHEN (SO.[����� ���������]=1)  THEN '���������� ��������'
				WHEN (SO.[����� ���������]=2)  THEN '��������'
				WHEN (SO.[����� ���������]=3)  THEN '�������'
				WHEN (SO.[����� ���������]=4)  THEN '����� ���'
				WHEN (SO.[����� ���������]=5)  THEN '�������'
				WHEN (SO.[����� ���������]=6)  THEN '�����'
				WHEN (SO.[����� ���������]=7)  THEN '�����'
				WHEN (SO.[����� ���������]=8)  THEN '����� ������'
				WHEN (SO.[����� ���������]=9)  THEN '����� � �������� ���'
				WHEN (SO.[����� ���������]=10) THEN '�������'
				WHEN (SO.[����� ���������]=11) THEN '��� ���'
				WHEN (so.[����� ���������]=12) THEN '�� ��'
				ELSE '�� �������'
			 END [�����_���������_��]
			,ISNULL(NOM.��������, '') [�������_�����]
			,CASE
				 WHEN ASK.��������=0 THEN '����������� ����������� �������' 
				 WHEN ASK.��������=1 THEN '���� ���������' 
				 WHEN ASK.��������=2 THEN '������������� ����������� � ����������' 
				 ELSE ''
			 END [�����] 
			,ISNULL([stack].[CLR_Concat](SMS.�����), '') [���]
			,ISNULL([stack].[CLR_Concat](AV.�����), '') [����������]
			,ISNULL([stack].[CLR_Concat](PH.�����), '') [�������]
			,ISNULL([stack].[CLR_Concat](EM.�����), '') [E_MAIL]
			,ISNULL(ORG.��������, '')  [����_��]
			,ISNULL(CAST(UKDOG_DOM.����� AS nvarchar(256)),'')  [���_���_��]
			,SO.���������� [����_�_�����_��]
			,ISNULL(CONVERT(VarChar(50), P.[���� ���������], 104),'')  [����_����_������]
			,CASE
				WHEN P.[��� ���������]=0 THEN '����'
				WHEN P.[��� ���������]=1 THEN '����'
				WHEN P.[��� ���������]=2 THEN '���'
				WHEN P.[��� ���������]=3 THEN '��������������'
				ELSE ''
			END [���_��������_������]
			,CASE
				WHEN P.���������=0 THEN '�����������'
				WHEN P.���������=1 THEN '�� ��������'
				WHEN P.���������=2 THEN '��������'
				ELSE ''
			END [����_������]
FROM TNS_Kuban_fl_522.stack.[������� �����] AS LS
JOIN TNS_Kuban_fl_522.stack.[������� ��������] AS LI ON LI.�������=LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.[stack].[��������� ���������] PS ON LI.�������� = ps.[���������-����] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[��������] ODPU  ON ODPU.[ROW_ID] = ps.[���������-��������] AND ODPU.[��� ���������] = 77 AND ps.��� = 6 AND ODPU.�������� = 0
LEFT JOIN TNS_Kuban_fl_522.stack.[������ ��������] SOODPU ON SOODPU.[�������-���������]=ODPU.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.�������� SLS ON SLS.[����-���������]=LS.ROW_ID
	AND SLS.[����-���������]=76
LEFT JOIN TNS_Kuban_fl_522.stack.�������� OPTS ON OPTS.[����-���������]=LS.ROW_ID 
	AND OPTS.[����-���������]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[���� ����������] AS VPD
		WHERE VPD.��������='��������'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.�������� OPTSH ON OPTSH.[����-���������]=LI.�������� 
	AND OPTSH.[����-���������]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[���� ����������] AS VPD
		WHERE VPD.��������='��������'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.�������� TU ON TU.[����-���������]=LS.ROW_ID 
	AND OPTSH.[����-���������]=(
		SELECT TOP 1 VPD.ROW_ID
		FROM TNS_Kuban_fl_522.stack.[���� ����������] AS VPD
		WHERE VPD.��������='������'
		)
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� �����������] CR ON CR.[����-����������]=LS.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.�������� US ON US.[����-���������]=LS.ROW_ID
	AND US.[����-���������]=(
	SELECT TOP 1 VP.ROW_ID
	FROM TNS_Kuban_fl_522.stack.[���� ����������] VP
	WHERE VP.��������='���_���_��'
	)
LEFT JOIN TNS_Kuban_fl_522.[stack].[������ ��������] SO ON SO.[�������-����] = LS.ROW_ID 
LEFT JOIN TNS_Kuban_fl_522.stack.[��������� ��������] SS
	ON SS.[����-�������� ���������]=SO.[�������-����] 
LEFT JOIN TNS_Kuban_fl_522.[stack].[������������] NOM ON SO.[������������-�������]=nom.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.�������� ASK ON ASK.[�������-���������]=SO.ROW_ID
	AND ASK.[����-���������]=2395
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� ����������] CT
	ON CT.[���-���������]=NOM.ROW_ID
	AND CT.[��������-��������]=23
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� ����������] KF
	ON KF.[���-���������]=NOM.ROW_ID
	AND KF.[��������-��������]=24
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� ����������] TOK
	ON TOK.[���-���������]=NOM.ROW_ID
	AND TOK.[��������-��������]=27
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� ����������] NAPR
	ON NAPR.[���-���������]=NOM.ROW_ID
	AND NAPR.[��������-��������]=28
LEFT JOIN TNS_Kuban_fl_522.stack.[�������� ����������] MPI
	ON MPI.[���-���������]=NOM.ROW_ID
	AND MPI.[��������-��������]=60
LEFT JOIN (
			SELECT pvt_adrs.������� AS ROW_ID,
					CITY.���������� AS [��� ��],
					CITY.�������� AS [���������� �����],
					STREET.���������� AS [��� �����],
					STREET.�������� AS �����,
					HOUSE.����� AS ���,
					HOUSE.������� AS ������,
					FLAT.����� AS ��������,
					FLAT.������� AS [������� ��������],
					ROOM.������� AS �������
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
					FROM TNS_Kuban_fl_522.stack.[������� ��������] AS LI
					JOIN TNS_Kuban_fl_522.stack.[������� �����] AS LS
						ON LI.��������=LS.ROW_ID
					LEFT JOIN TNS_Kuban_fl_522.stack.������ AS CY
						ON LS.[�����-������� ����]=CY.ROW_ID
					LEFT JOIN TNS_Kuban_fl_522.stack.����������� AS ORG
						ON ORG.ROW_ID=LS.[����-�������� �������] 
				) AS pvt_adrs
			PIVOT (
					MAX(�����) FOR pvt_adrs.����������� IN ([12],[13],[11],[2],[3],[4],[5])
				  ) AS pvt_adrs
					LEFT JOIN TNS_Kuban_fl_522.stack.������ AS CITY
						ON CITY.ROW_ID=CAST([12] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.������ AS STREET
						ON STREET.ROW_ID=CAST([2] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[������� �����] AS HOUSE
						ON HOUSE.ROW_ID=CAST([3] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[������� �����] AS FLAT
						ON FLAT.ROW_ID=CAST([4] AS int)
					LEFT JOIN TNS_Kuban_fl_522.stack.[������� �����] AS ROOM
						ON ROOM.ROW_ID=CAST([5] AS int)) AS AD 
					ON AD.ROW_ID=LS.ROW_ID
LEFT JOIN TNS_Kuban_fl_522.stack.�������� PH
	ON PH.[����-�������]=LS.ROW_ID AND PH.�����=2
LEFT JOIN stack.�������� AV
	ON AV.[����-�������]=LS.ROW_ID AND AV.�����=3
LEFT JOIN TNS_Kuban_fl_522.stack.�������� SMS
	ON SMS.[����-�������]=LS.ROW_ID AND SMS.�����=1
LEFT JOIN TNS_Kuban_fl_522.stack.[��������]  EM
	ON EM.[����-�������]=LS.ROW_ID AND EM.�����=4 
LEFT JOIN TNS_Kuban_fl_522.stack.[����������� ��������]  UK_DOM
		ON UK_DOM.[����-��]=LI.�������� 
LEFT JOIN TNS_Kuban_fl_522.stack.[�� ��������]  UKDOG_DOM
	ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] 
LEFT JOIN TNS_Kuban_fl_522.stack.�����������  ORG
	ON UK_DOM.[�����������-��]=ORG.ROW_ID
OUTER APPLY(
			SELECT TOP 1  PL.[������-������]
			,PL.[���� ���������]
			,PL.[��� ���������]
			,PL.���������
			FROM TNS_Kuban_fl_522.stack.[������]  PL
			WHERE PL.[������-������]=SO.ROW_ID 
			ORDER BY PL.[���� ���������] DESC
		) AS P 
WHERE LI.����������=5 AND (@�������������� = 0
    OR  
   (SO.ROW_ID IS NOT NULL AND @����  >= DATEADD (year, CAST(MPI.�������� AS int), SO.�����������)))
GROUP BY  LS.�����,ODPU.�����,US.��������,OPTS.��������,OPTSH.��������,SLS.��������,AD.[���������� �����],AD.�����,AD.���,AD.��������,AD.�������, CR.���,nom.������������,SO.������,
SS.���������,NOM.������������,SO.��������������,SO.�����������,SO.����������,SO.[����������� �������������] ,SO.���������� ,SO.�����������  ,MPI.�������� ,SO.�������������������� 
,CT.�������� ,TOK.�������� ,KF.�������� ,NAPR.��������,so.[����� ���������],NOM.�������� ,ASK.��������  ,SMS.����� ,PH.����� ,EM.�����,ORG.�������� ,UKDOG_DOM.�����,SO.���������� 
,P.[���� ���������], P.[��� ���������],P.���������
ORDER BY AD.������, AD.������� 