DECLARE @date    datetime = '20200901',
	    @������� NVARCHAR(MAX) = 1092, --������������� �������
		@�����������������   INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '���������');


SELECT   LS.�����
		,EM.����� AS EMAIL
   FROM stack.[������� ��������] AS LI
   JOIN stack.[������� �����] AS LS ON LS.row_id = LI.�������
   JOIN stack.�������� AS EM ON EM.[����-�������]=LS.ROW_ID
   LEFT JOIN stack.�������� AS S ON S.[����-���������] = LS.ROW_ID AND S.[����-���������]=@����������������� AND @date BETWEEN S.������ AND S.������
WHERE LI.���������� = 5 
	 AND EM.�����=4
	 AND (S.��������!=2 OR S.�������� IS NULL)
     AND LI.�������� IN (SELECT * FROM [stack].[CLR_Split](@�������));
