USE tns_kuban_fl_dev;

WITH 
--���������� ��� ����
--������� ����
--����� �������� (�� �������� ��������), �������� ���������, ���� � LS.ROW_ID ���������� ID ����
--���������� ����� ������� ��������
--OR ��� UKDOG
Dog_num
	AS
		(
					SELECT 							
						   ISNULL(UKDOG.�����, UKDOG_DOM.�����) AS [����� ��������]
					FROM stack.[������� �����] AS LS
					JOIN stack.[������� ��������] AS LI
						ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
					LEFT JOIN stack.[����������� ��������] AS UK
						ON UK.[����-��]=LS.ROW_ID
					LEFT JOIN stack.[�� ��������] AS UKDOG
						ON UKDOG.ROW_ID=UK.[���-���������] 
						AND GETDATE() BETWEEN UKDOG.������ AND UKDOG.������
--��� ����
					LEFT JOIN stack.[����������� ��������] AS UK_DOM
						ON UK_DOM.[����-��]=LI.��������
					LEFT JOIN stack.[�� ��������] AS UKDOG_DOM
						ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] 
						AND GETDATE() BETWEEN UKDOG_DOM.������ AND UKDOG_DOM.������
					WHERE LS.ROW_ID=366006
		),
--��� ��������
Type_stroy
	AS
		(
			SELECT	
					CASE
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
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=242 AND 
				GETDATE() BETWEEN OP.������ AND OP.������
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=242 AND 
				GETDATE() BETWEEN OPD.������ AND OPD.������
				 WHERE  LS.ROW_ID=366006

		),
--�� ����
Type_UL
	AS
		(
			SELECT 
				CASE 
				WHEN OP.�������� IS NULL THEN '���'
				WHEN OP.�������� IS NOT NULL THEN '��'
				ELSE '�� ���������'
				END AS ������
			FROM stack.[������� �����] AS LS
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=244 AND 
				GETDATE() BETWEEN OP.������ AND OP.������
				 WHERE  LS.ROW_ID=366006

		),
--���������� �� ��
LS_number 
	AS
		(
			SELECT CR.��� AS ���,LS.����� AS [� �������� �����]
			FROM stack.[������� �����] AS LS
			JOIN stack.[�������� �����������] AS CR
				ON CR.[����-����������]=LS.ROW_ID
			WHERE LS.���=5  AND  LS.ROW_ID=366006

		),
--����� �������� 
ADDRES
		AS
		(
			SELECT ([12] + ' '+ [2]+' '+ [3] +' ') AS �����
			FROM(
				SELECT	
					LI.�����������,
					LI.�������,
				CASE 
					WHEN LI.�����������=0 THEN LS.�������
					WHEN LI.�����������=1 THEN ORG.��������
					WHEN LI.����������� IN (12,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.����������
					WHEN LI.����������� IN (12,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.��������  
					WHEN LI.����������� IN (11,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.�������� 
					WHEN LI.����������� IN (11,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
					WHEN LI.����������� IN (13,2) AND CY.��_�����=1 THEN CY.���������� + ' ' + CY.��������  
					WHEN LI.����������� IN (13,2) AND CY.��_�����=0 THEN CY.�������� + ' ' + CY.���������� 
					WHEN LI.�����������=3 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
					WHEN LI.�����������=4 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
					WHEN LI.�����������=5 THEN CAST(LS.����� AS nvarchar(12))
				END AS �����
				FROM stack.[������� ��������] AS LI
				JOIN stack.[������� �����] AS LS
					ON LI.��������=LS.ROW_ID
				LEFT JOIN stack.������ AS CY
					ON LS.[�����-������� ����]=CY.ROW_ID
--�������
				LEFT JOIN stack.����������� AS ORG
					ON ORG.ROW_ID=LS.[����-�������� �������] 
				WHERE LI.�������=366006
--������������ �����-�������
			) AS pvt_adrs
			PIVOT (
					 MAX(�����) FOR pvt_adrs.����������� IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
				   ) AS pvt_adrs
		),
--�������� ������
Ind
	AS
		(
			SELECT	
					CASE 
					WHEN LS.�������������� IS NOT NULL 
					THEN ISNULL(OP.��������,OPD.��������)
					END AS ������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=11 AND 
				GETDATE() BETWEEN OP.������ AND OP.������
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=11 AND 
				GETDATE() BETWEEN OPD.������ AND OPD.������
				 WHERE  LS.ROW_ID=366006
		),
--��������� ���������
ADDRES_RAZVERN
		AS
		(
		SELECT ([0]+' '+[1]) AS '�����',[12] AS '���������� �����',[13],[11],[2] AS '�����',[3] AS '����',[4] AS '��������',[5]
		FROM(
			SELECT	
				LI.�����������,
				LI.�������,
			CASE 
				WHEN LI.�����������=0 THEN LS.�������
				WHEN LI.�����������=1 THEN ORG.��������
				WHEN LI.����������� IN (12,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.����������
				WHEN LI.����������� IN (12,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.��������  
				WHEN LI.����������� IN (11,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.�������� 
				WHEN LI.����������� IN (11,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
				WHEN LI.����������� IN (13,2) AND CY.��_�����=1 THEN CY.���������� + ' ' + CY.��������  
				WHEN LI.����������� IN (13,2) AND CY.��_�����=0 THEN CY.�������� + ' ' + CY.���������� 
				WHEN LI.�����������=3 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
				WHEN LI.�����������=4 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
				WHEN LI.�����������=5 THEN CAST(LS.����� AS nvarchar(12))
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
			  ),
--���������� �� ��������	
SCHETCHIK 
	AS
		(
			SELECT NR.������������ AS [��� ��], SO.�������������� AS [����� ��], SO.����������, SO.�����������, SO.[����������� �������������] AS [����.������]
			FROM stack.[������� �����] AS LS
			LEFT JOIN stack.[������ ��������] AS SO 
				ON SO.[�������-����]=LS.ROW_ID 
			LEFT JOIN stack.������������ AS NR 
				ON SO.[������������-�������]=NR.ROW_ID
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.��������!=2
			JOIN stack.[��������� ��������] AS SS
				ON SS.[����-�������� ���������]=LS.ROW_ID AND SS.���������!=3 AND
				GETDATE() BETWEEN SS.������ AND SS.������
				 WHERE  LS.ROW_ID=366006

		),
--���������� �� ����������
POKAZANIYA 
	AS 
		(	
		SELECT
			POK1.���� AS [���� ���������� ���������],
			CASE 
				WHEN POK1.��������=0 THEN '��'
				WHEN POK1.��������=1 THEN '��'
				WHEN POK1.��������=2 THEN '��'
				WHEN POK1.��������=3 THEN '��'
				WHEN POK1.��������=4 THEN '���������'
				WHEN POK1.��������=5 THEN '������'
				WHEN POK1.��������=6 THEN '��/�'
				WHEN POK1.��������=7 THEN '���������'
				WHEN POK1.��������=8 THEN '����'
				WHEN POK1.��������=9 THEN 'WEB'
				WHEN POK1.��������=10 THEN 'OUT'
				WHEN POK1.��������=11 THEN '�����'
				WHEN POK1.��������=12 THEN '�������'
				WHEN POK1.��������=13 THEN '����'
				WHEN POK1.��������=14 THEN '�����'
				WHEN POK1.��������=15 THEN '�������'
				WHEN POK1.��������=16 THEN 'SMS'
				WHEN POK1.��������=17 THEN '���'
				WHEN POK1.��������=18 THEN '���'
			END AS [��� ���������� ���������],
			POK1.��������� AS [��������� ��������� ����],
			POK2.��������� AS [��������� ��������� ����],
			POK3.��������� AS [��������� ��������� ����]
			
	FROM 
		stack.[������� �����] AS LS
	LEFT JOIN stack.[������ ��������] AS OL 
		ON OL.[�������-����]=LS.ROW_ID AND
		GETDATE() BETWEEN OL.������ AND OL.������
	LEFT JOIN stack.������������ AS NR 
		ON OL.[������������-�������]=NR.ROW_ID
	LEFT JOIN stack.�������� AS OP 
		ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=76  AND 
		GETDATE() BETWEEN OP.������ AND OP.������ AND OP.��������!=2
	OUTER APPLY
		(SELECT TOP 1 TS.���������, TS.����, TS.��������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=LS.[ROW_ID] AND TS.���=1 
		AND TS.�����=1
		AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK1
	OUTER APPLY
		(SELECT TOP 1 TS.���������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=LS.[ROW_ID] AND TS.���=1 
		AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK2
	OUTER APPLY
		(SELECT TOP 1 TS.���������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=LS.[ROW_ID] AND TS.���=1 
		AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK3
		--���������� ���������
	OUTER APPLY
		(SELECT  MAX(TSP.���������) AS [���������� ���������], 
		MAX(TSP.����) AS [����������� ����]
		FROM stack.[��������� ���������] AS TSP
		WHERE TSP.[���������-����]=LS.[ROW_ID] AND TSP.���=1 
		AND TSP.[������-���������]=OL.ROW_ID AND
		TSP.��������� < 
			( 
			SELECT  MAX(TSP.���������)
			FROM stack.[��������� ���������] AS TSP
			WHERE TSP.[���������-����]=LS.[ROW_ID] AND TSP.���=1 
			AND TSP.[������-���������]=OL.ROW_ID
			)
		AND TSP.���� < 
		(
			SELECT  MAX(TSP.����)
			FROM stack.[��������� ���������] AS TSP
			WHERE TSP.[���������-����]=LS.[ROW_ID] AND TSP.���=1 
			AND TSP.[������-���������]=OL.ROW_ID
		)
		) AS PREDPOK
		 WHERE  LS.ROW_ID=366006

		),
--������� ����
SQUARE_parametrs
	AS
		(
			SELECT ISNULL(OP.��������,OPD.��������) AS �������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=102 AND 
					GETDATE() BETWEEN OP.������ AND OP.������
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=102 AND 
					GETDATE() BETWEEN OPD.������ AND OPD.������
					 WHERE  LS.ROW_ID=366006

		),
--���������� ������
ROOMS_parametrs
	AS
		(
			SELECT ISNULL(OP.��������,OPD.��������) AS ������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=92 AND 
					GETDATE() BETWEEN OP.������ AND OP.������
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=92 AND 
					GETDATE() BETWEEN OPD.������ AND OPD.������
					 WHERE  LS.ROW_ID=366006

		),
--���������� �����������
Propis_parametrs
	AS
		(
			SELECT ISNULL(OP.��������,OPD.��������) AS ���������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=83 AND 
					GETDATE() BETWEEN OP.������ AND OP.������
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=83 AND 
					GETDATE() BETWEEN OPD.������ AND OPD.������
					 WHERE  LS.ROW_ID=366006

		),
--��������� ��
Sost_LS
	AS
		(
			SELECT 
				CASE
				WHEN ISNULL(OP.��������,OPD.��������)=0 THEN '������������' 
				WHEN ISNULL(OP.��������,OPD.��������)=1 THEN '�� ���������' 
				WHEN ISNULL(OP.��������,OPD.��������)=2 THEN '������' 
				END AS [��������� �������� (��� ����������)]
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
	--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=76 AND 
					GETDATE() BETWEEN OP.������ AND OP.������
	--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� AND OPD.[����-���������]=76 AND 
					GETDATE() BETWEEN OPD.������ AND OPD.������
					 WHERE  LS.ROW_ID=366006

		),
--���������
Postav_name
	AS
		(
			SELECT 
				ISNULL(ORG.��������,ORG_D.��������) AS [������������ ����������]
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.���������� AS POS
			ON POS.[����-������ �����������]=LS.ROW_ID
			LEFT JOIN stack.����������� AS ORG
			ON ORG.ROW_ID=POS.[����������-������]
--��� ����
			LEFT JOIN stack.���������� AS POS_D
			ON POS_D.[����-������ �����������]=LI.��������
			LEFT JOIN stack.����������� AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[����������-������]
			 WHERE  LS.ROW_ID=366006

		),
--������� � e-mail
CONTACTS
	AS
		(
			SELECT LS.�������, LS.[E-Mail] 
			FROM stack.[������� �����] AS LS 
			 WHERE  LS.ROW_ID=366006

		)
--����������� ��

 SELECT *
 --������� ��� ������� join, row_id � ������ �����
 FROM
 Dog_num,Type_stroy,Type_UL,LS_number,ADDRES,Ind,SCHETCHIK,POKAZANIYA,SQUARE_parametrs,ROOMS_parametrs,Propis_parametrs,Sost_LS,Postav_name, CONTACTS

