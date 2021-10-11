USE tns_kuban_fl_dev;
DECLARE @date datetime='20200301';
SELECT 
		PVT.����
	  , PVT.[����� ������]
	  , ISNULL(PVT.[3], ' ') AS [�������� ������]
	  , ISNULL(PVT.[1], ' ') AS [���������]
	  , ISNULL(PVT.[2], ' ') AS [��������� ������]
	  , ISNULL(PVT.[4], ' ') AS [����������]
FROM
	(
		SELECT 		NT.����
					, NT.[����� ������]
					, NT.�����
					, 1 AS _TYPE_
				FROM stack.������ AS NT
				WHERE NT.���� IN (164171) AND NT.[����� �������]=@date
		UNION
				SELECT NS.����
					 , NS.[����� ������]
					 , SUM(NS.�����) AS Summa
					 , 2 AS _TYPE_
				FROM stack.������� AS NS
				WHERE NS.���� IN (164171) AND NS.[����� �������]=@date
				GROUP BY NS.����, NS.[����� ������]
		UNION
				SELECT VS.����
					 , VS.[����� ������]
					 , SUM(VS.�����) AS Summa
					 , 3 AS _TYPE_
				FROM stack.������� AS VS
				WHERE VS.���� IN (164171) AND VS.[����� �������]=DATEADD(mm, -1, @date)
				GROUP BY VS.����, VS.[����� ������]
		UNION
				SELECT NP.����
					 , NP.[����� ������]
					 , SUM(NP.�����) AS Summa
					 , 4 AS _TYPE_
				FROM stack.������� AS NP
				WHERE NP.[����� �������]=@date AND NP.���� IN (164171)
				GROUP BY NP.����, NP.[����� ������], NP.�����
	) as PVT_SUM
PIVOT (max(PVT_SUM.�����)
		FOR _TYPE_ IN ([1], [2], [3], [4])) AS PVT