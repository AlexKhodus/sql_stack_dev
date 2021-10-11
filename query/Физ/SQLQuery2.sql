DECLARE @date datetime='20200401';
WITH
--����������
--NACHISLENO
--	AS 
--		(
--		SELECT	NT.���� AS ������� 
--				, SUM(NT.�����) AS [��������� ��������������� �����������]
--				, SUM(NT.�����) AS [����� ��������������� �����������]
--		FROM  stack.������ AS NT
--		WHERE  NT.[����� �������]=@date
--		GROUP BY NT.����
--		),
----������ ��������
--SALDO_VHOD
--	AS
--		(
--		DECLARE @date datetime='20200401';
--		SELECT (	
--					(
--						SELECT SUM(NS.�����) AS Sum100
--						FROM stack.������� AS NS
--						WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) AND (NS.[����� ������] BETWEEN 100 AND 199)
--					--) +
--					--(
--					--	SELECT SUM(NS.�����) AS Sum400
--					--	FROM stack.������� AS NS
--					--	WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) AND (NS.[����� ������] BETWEEN 400 AND 499) 
--					--)
--				) AS [������ �� ����� ������ 100,400]
--		FROM stack.������� AS NS
--		WHERE NS.����=164180
--		),
----������ ���������
--SALDO_ISHOD
--	AS
--		(
--		SELECT NS.���� AS �������
--				,SUM(NS.�����) AS [������ �� ������ ������ 100,400]
--		FROM stack.������� AS NS
--		WHERE NS.[����� �������]=@date AND (NS.[����� ������] BETWEEN 100 AND 199) OR (NS.[����� ������] BETWEEN 400 AND 499) 
--		GROUP BY NS.����
--		),
		PLATEJ
	AS
		(
			SELECT   SO.����
			,SO.[����-������] AS �������
			FROM stack.[������ ������] AS SO
			WHERE SO.ROW_ID=140338880
		)
SELECT LS.�����
		,PL.����
		--,NACH.[����� ��������������� �����������]
		--,NACH.[��������� ��������������� �����������]
		--,SV.[������ �� ����� ������ 100,400]
		--,SI.[������ �� ������ ������ 100,400]
FROM stack.[������� �����] AS LS
LEFT JOIN PLATEJ AS PL ON PL.�������=LS.ROW_ID
--LEFT JOIN NACHISLENO AS NACH ON NACH.�������=LS.ROW_ID
--LEFT JOIN SALDO_VHOD AS SV ON SV.�������=LS.ROW_ID
--LEFT JOIN SALDO_ISHOD AS SI ON SI.�������=LS.ROW_ID
WHERE LS.ROW_ID=164180 

SELECT	*
FROM	stack.[������ ������]
Where	ROW_ID = 140338880

with
D AS(
			SELECT TOP 1 SO.����, SO.�����
			,SO.[����-������] AS �������
			FROM stack.[������ ������] AS SO
			WHERE SO.[����-������]=164180
			ORDER BY  SO.���� DESC)
SELECT LS.�����,
		D.����,
		D.�����
FROM stack.[������� �����] AS LS
LEFT JOIN D ON D.�������=LS.ROW_ID
WHERE LS.ROW_ID=164180

