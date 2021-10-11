USE tns_kuban_fl_dev;
DECLARE @date datetime='20200401';
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
					,(18 , '���')
		--SELECT *
		--FROM #TypeEnter
		SELECT
				OL.[�������-����]			
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
DROP TABLE #TypeEnter