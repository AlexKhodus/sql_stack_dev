SELECT PA.�����, OL.��������������, NR.������������, POK1.���������
FROM stack.[������� �����] AS PA
LEFT JOIN stack.[������ ��������] AS OL 
	ON OL.[�������-����]=PA.ROW_ID
LEFT JOIN stack.������������ AS NR 
	ON OL.[������������-�������]=NR.ROW_ID
LEFT JOIN stack.�������� AS OP 
	ON OP.[����-���������]=OP.ROW_ID AND OP.[����-���������]=76  AND 
	GETDATE() BETWEEN OP.������ AND OP.������ AND OP.��������!=2
OUTER APPLY
	(SELECT TOP 1 TS.���������
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
	(SELECT TOP 1 TS.���������
	FROM stack.[��������� ���������] AS TS
	WHERE TS.[���������-����]=PA.[ROW_ID] AND TS.���=1 
	AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
	ORDER BY TS.���� DESC) AS POK3
WHERE PA.���=5 AND PA.ROW_ID=31422
