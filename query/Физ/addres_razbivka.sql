	USE tns_kuban_fl_dev;			 
			 
			 SELECT pvt_adrs.������� AS ROW_ID,
					[5] AS LS,
					[0] + [1] AS �����,
					CITY.���������� AS [��� ��],
					CITY.�������� AS [���������� �����],
					STREET.���������� AS [��� �����],
					STREET.�������� AS �����,
					HOUSE.����� AS ���,
					HOUSE.������� AS ������,
					FLAT.����� AS ��������,
					FLAT.������� AS [������� ��������]
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
				WHERE LI.����������=5 AND LI.�������=366006

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
