USE tns_kuban_fl_dev

SELECT	PA.�����,
		OL.��������������, 
		NR.������������,
		POK1.���������,
		POK2.���������, 
		POK3.���������, 
		PPOK.���������,
		OI.������������,
ISNULL(TU.������������,TUD.������������) AS [�������� ������]
FROM stack.[������� �����] AS PA
	LEFT JOIN stack.[������ ��������] AS OL 
		ON OL.[�������-����]=PA.ROW_ID AND
		GETDATE() BETWEEN OL.������ AND OL.������
	LEFT JOIN stack.������������ AS NR 
		ON OL.[������������-�������]=NR.ROW_ID
	LEFT JOIN stack.�������� AS OP 
		ON OP.[����-���������]=PA.ROW_ID AND OP.[����-���������]=76  AND 
		GETDATE() BETWEEN OP.������ AND OP.������ AND OP.��������!=2
	JOIN stack.[��������� ��������] AS SS
		ON SS.[����-�������� ���������]=PA.ROW_ID AND SS.���������!=3 AND
		GETDATE() BETWEEN SS.������ AND SS.������
	OUTER APPLY
		(SELECT TOP 1 TS.���������, TS.����
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=PA.[ROW_ID] AND TS.���=1 
		AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK1
	OUTER APPLY
		(SELECT TOP 1 TS.���������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=PA.[ROW_ID] AND TS.���=1 
		AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK2
	OUTER APPLY
		(
		SELECT TOP 1 TS.���������
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=PA.[ROW_ID] AND TS.���=1 
		AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
		ORDER BY TS.���� DESC) AS POK3
--�������������
	OUTER APPLY
	(
		SELECT TOP 1 TS.��������� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]=PA.[ROW_ID] AND TS.���=1 
		AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
		AND POK1.����!=TS.����
		ORDER BY TS.���� DESC) AS PPOK
		
--������� ��������
	LEFT JOIN [stack].[������� ��������] AS LI 
		ON  PA.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
	LEFT JOIN stack.[������ �����] AS SU
		ON SU.[����-������]=PA.ROW_ID 
		AND SU.���������=0
	LEFT JOIN stack.[���� �����] AS TU
		ON TU.ROW_ID=SU.[���-������]
	LEFT JOIN stack.[����������] AS PO
		ON PO.[����-������ �����������]=PA.ROW_ID
	LEFT JOIN stack.[�����������] AS OI
		ON OI.ROW_ID=PO.[����������-������]
--��� ����
	LEFT JOIN stack.[������ �����] AS SUD
		ON SUD.[����-������]=LI.[��������]
			AND SUD.���������=0
	LEFT JOIN stack.[���� �����] AS TUD
		ON TUD.ROW_ID=SUD.[���-������]
	LEFT JOIN stack.[����������] AS POD
		ON POD.[����-������ �����������]=LI.[��������]
	LEFT JOIN stack.[�����������] AS OID
		ON OID.ROW_ID=POD.[����������-������]
WHERE  PA.ROW_ID=366006



--SELECT	*
--FROM	stack.[��������� ���������]
