DECLARE @date datetime ='20200801';

WITH PARAMETRS AS (

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
	)


	UPDATE R
	SET ����_�� = P.���������,
		��_���� = P.������,
		������ = P.������,
		����������� = P.��������,
		�������� = P.����,
		������� = P.�������,
		������� = P.����������
	FROM #Result AS R
	JOIN PARAMETRS AS P ON p.�������=R.ROW_ID
