IF 0 = 1

BEGIN
	DROP TABLE IF EXISTS #addresses;

	CREATE TABLE #addresses (
		[row_id]         [int]           NOT NULL,
		[�������]        [bigint]        NOT NULL,
		[�������]        [varchar](256)  NOT NULL,
		[�����������]    [varchar](256)  NULL,
		[�����XML]       [nvarchar](max) NULL,
		[������]         [nvarchar](max) NULL,
		[������]         [nvarchar](max) NULL,
		[�������]        [nvarchar](max) NULL,
		[�����������]    [int]           NULL,
		[������]         [int]           NULL,
		[������_�������] [int]           NULL   
	);

	WITH raw AS (
		SELECT 
			L.row_id,
			L.����� AS �������,
			D.����� AS �������,
			L.������� AS �����������,
			CAST(A.����� AS nvarchar(MAX)) AS �����XML,
			ISNULL(X.����.value('.', 'nvarchar(max)'), '') �������,
			X.����.value('for $i in . return count(../*[. << $i]) + 1', 'int') AS �����������
		FROM [stack].[������� �����] AS L
		JOIN stack.[������� ��������] AS LD ON LD.�������=L.ROW_ID AND CAST(GETDATE() AS DATE) BETWEEN LD.������ AND LD.������
		JOIN stack.������� AS D ON LD.�������=D.ROW_ID 
		CROSS APPLY (VALUES(CAST(CONCAT('<H>',�REPLACE(L.�������,�',',�'</H><H>'),�'</H>')�AS�XML))) AS A(�����)
		CROSS APPLY A.�����.nodes('H') AS X(����)
		WHERE D.[���������-��������] IN (252,253.254) AND CAST(GETDATE() AS DATE) BETWEEN D.[������ ��������] AND ISNULL(D.���������,'20450509') 
		  AND D.����� IN (23060401282, 23060501288, 23110601049, 23010201291)
	), Details AS (
		SELECT
			row_id,
			�������,
			�������,
			�����������,
			�����XML,
			MAX(IIF(V.������ IS NOT NULL, �������, NULL)) OVER (PARTITION BY row_id) AS ������,
			MAX(IIF(V.������ IS NOT NULL, �������, NULL)) OVER (PARTITION BY row_id) AS ������,
			IIF(����������� IN (MAX(V.������) OVER (PARTITION BY row_id), MAX(V.������) OVER (PARTITION BY row_id)), NULL, �������) AS �������,
			�����������
		FROM raw
		CROSS APPLY (VALUES(
			IIF(����������� IN (1, 2) AND LEN(�������) > 3 AND TRY_CAST(������� AS INT) IS NOT NULL,                �����������, NULL),
			IIF(����������� IN (1, 2) AND RTRIM(LTRIM(LOWER(�������))) IN ('��', '���������� ���������', '������'), �����������, NULL)
		)) AS V(������, ������)
	)
	INSERT INTO #addresses ([row_id], [�������], [�������], [�����������], [�����XML], [������], [������], [�������],[�����������], [������], [������_�������])
	SELECT *
	FROM (
		SELECT
			[row_id],
			[�������],
			[�������],
			[�����������],
			[�����XML],
			[������],
			[������],
			[�������],
			[�����������],
			NULL AS ������,
			NULL AS ������_�������
		FROM Details

			UNION ALL

		SELECT DISTINCT
			[row_id],
			[�������],
			[�������],
			[�����������],
			[�����XML],
			[������],
			[������],
			'��',
			0,
			1303592,
			1
		FROM Details
	) AS T;
END

DECLARE @level INT = 1,
		@limit INT = 3 -- (SELECT MAX(�����������) FROM #addresses);

WHILE @level <= @limit
BEGIN
	WITH �������� AS (
		SELECT 
			A.row_id,
			A.�������,
			A.�������,
			A.������,
			R.������ AS ������,
			R.������_�������
		FROM #addresses AS A
		CROSS APPLY (
			SELECT TOP(1) 
				������,
				������_�������
			FROM #addresses
			WHERE row_id = A.row_id
			  AND ������ IS NOT NULL
			ORDER BY ����������� DESC
		) AS R
		WHERE A.����������� = @level
	), ������������� AS (
		SELECT 
			row_id AS ����,
			������ AS row_id,
			CAST(NULL AS VARCHAR(256)) AS ��������,
			0 AS �������
		FROM �������� 

			UNION ALL 

		SELECT 
			P.����,
			C.row_id,
			C.��������,
			P.������� + 1
		FROM ������������� AS P
		JOIN [stack].[������] AS C ON C.������ = P.row_id
		WHERE P.������� <= 1
	) 
	--SELECT *
	--FROM #addresses AS A
	--LEFT JOIN ������������� AS S ON S.����=A.row_id
	
	SELECT * 
	FROM �������������

	SET @level = @level + 1;
	
END
--SELECT  *
--FROM (	SELECT A.row_id, 
--			   A.�������,
--			   A.�������, 
--			   A.�����XML,
--			   A.�����������,
--			   A.������,
--			   A.������,
--			   A.�������,
--			   A.�����������,  
--			   A.������, 
--			   A.������_������� 
--		FROM #addresses AS A) AS A
--PIVOT 
--( 
--	MAX(A.�������) FOR A.����������� IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
--) AS pvt

--WHERE ������� IS NOT NULL AND �������!=''


