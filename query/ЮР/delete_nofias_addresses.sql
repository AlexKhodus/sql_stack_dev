IF OBJECT_ID(N'tempdb..#Cities', N'U') IS NOT NULL
      DROP TABLE #Cities
CREATE TABLE #Cities(
	row_id		INT
	);
WITH Cities AS (
	SELECT 
		row_id
	FROM [stack].[������]
	WHERE ROW_ID = 1

		UNION ALL

	SELECT 
		C.row_id
	FROM Cities AS P
	JOIN [stack].[������] AS C ON C.������ = P.row_id
)
INSERT INTo #Cities(row_id)
SELECT *
FROM #Cities

--DELETE stack.������
--OUTPUT deleted.* INTO [dbo].[temp_deletedNoFiasCities_HodusAL_10062021]
--WHERE ROW_ID IN (SELECT row_id FROM #Cities)




