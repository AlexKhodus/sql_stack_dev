USE tns_kuban_fl_dev;

			SELECT PH.����� AS �������, PH.���
			FROM stack.[������� �����] AS LS
			LEFT JOIN stack.[��������] AS PH
				ON PH.[����-�������]=LS.ROW_ID
			WHERE  LS.ROW_ID=164171 AND PH.���!=4


			SELECT PH.����� AS [E-mail]
			FROM stack.[������� �����] AS LS
			LEFT JOIN stack.[��������] AS PH
				ON PH.[����-�������]=LS.ROW_ID
			WHERE  LS.ROW_ID=164171 AND PH.���=4

			SELECT *
			FROM stack.[��������]