
DECLARE @PER DATE = '20200426',
	@��������� NVARCHAR(MAX) = 35033; --������������� �������
SELECT D.ROW_ID,
       D.�����,
       ISNULL(
             NULLIF(REPLACE(RTRIM(LTRIM(S.����������)), ' ', ''), ''), 
             NULLIF(REPLACE(RTRIM(LTRIM(O.Email)), ' ', ''), '')
       ) AS email
FROM stack.������� AS D
JOIN stack.����������� AS O ON O.ROW_ID=D.����������
LEFT JOIN [stack].[��������] AS S 
       ON D.ROW_ID = S.[���������-�������]
       AND @PER BETWEEN S.������ AND S.������
       AND S.[����-���������] = (SELECT TOP(1) row_id FROM [stack].[���� ����������] WHERE �������� = '��������')
       AND S.�������� = 1
WHERE D.ROW_ID IN (SELECT [�������] FROM [stack].[contracts_lite](@���������))
  AND D.�����_ADD = 1