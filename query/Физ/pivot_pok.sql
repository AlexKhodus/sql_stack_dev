DECLARE @date datetime ='20200801';

SELECT POK1.���������, POK1.����
FROM stack.[������ ��������] AS OL
LEFT JOIN (
SELECT PVT.[0] AS ����
	  ,PVT.[1] ����
	  ,PVT.[2] ����
	  ,PVT.[���������-����]
	  ,PVT.����
FROM(
		SELECT TOP(1) WITH TIES 
			TS.���������, TS.����, TS.��������, TS.[���������-����], TS.[������-���������], ����� 
		FROM stack.[��������� ���������] AS TS
		WHERE TS.[���������-����]= 164180 AND TS.���=1 
		ORDER BY (ROW_NUMBER() OVER (PARTITION BY �����, [���������-����] ORDER BY ���� DESC, row_id DESC) -1)
        ) AS POK1 
		 PIVOT (
		MAX(POK1.���������) FOR ����� IN ([0], [1], [2])
	) AS PVT) AS POK
		 ON POK.[���������-����]=OL.[�������-����] 
			AND POK1.[������-���������]=OL.ROW_ID
LEFT JOIN stack.������������ AS NR ON OL.[������������-�������]=NR.ROW_ID
WHERE OL.[�������-����] = 164180 AND @date BETWEEN OL.������ AND OL.������
ORDER BY POK1.���� DESC