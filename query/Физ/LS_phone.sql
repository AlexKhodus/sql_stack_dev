USE tns_kuban_fl_dev;

			SELECT PH.Номер AS Телефон, PH.Тип
			FROM stack.[Лицевые счета] AS LS
			LEFT JOIN stack.[Телефоны] AS PH
				ON PH.[Счет-Телефон]=LS.ROW_ID
			WHERE  LS.ROW_ID=164171 AND PH.Тип!=4


			SELECT PH.Номер AS [E-mail]
			FROM stack.[Лицевые счета] AS LS
			LEFT JOIN stack.[Телефоны] AS PH
				ON PH.[Счет-Телефон]=LS.ROW_ID
			WHERE  LS.ROW_ID=164171 AND PH.Тип=4

			SELECT *
			FROM stack.[Телефоны]