WITH
ADDRES
		AS
		(
			SELECT ([12] + ' '+ [2]+' '+ [3] +' ') AS �����
			CASE
				WHEN [4]=NULL THEN ([12] + ' '+ [2]+' '+ [3] +' ')
			END AS �����
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
	   ) AS pvt_adrs)
SELECT *
FROM ADDRES