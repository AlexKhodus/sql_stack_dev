			DECLARE @date datetime='20201101',
					--@account int=161408,
					@������������������� INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '��������');
		 
		 SELECT  LS.�����, COUNT(LS.�����)
		  , A.[����� ��], A.�������
		  FROM stack.[������� ��������] AS L
		  JOIN stack.[������� �����] AS LS
			ON LS.ROW_ID=L.�������
		  CROSS APPLY
			(
				SELECT   TOP (1)
						SO.[�������-����] AS �������
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
				JOIN stack.������������ AS NR 
					ON SO.[������������-�������]=NR.ROW_ID 
				JOIN stack.[��������� ��������] AS SS
					ON SS.[����-�������� ���������]=SO.[�������-����] AND SS.���������!=3 AND
					@date BETWEEN SS.������ AND SS.������
				WHERE @date BETWEEN SO.������ AND SO.������
				AND ISNULL(NR.�������������, 0) = 0
				AND L.�������=SO.[�������-����]
			  ORDER BY SO.������ DESC
			  ) AS A
			  WHERE L.����������=5 AND L.�����������=3
			  GROUP BY LS.�����
			  , A.[����� ��], A.�������
			  Having COUNT(LS.�����) > 1
