
SELECT LF.�������, LL.�������, COUNT(LS.�����) AS [����������]
FROM [stack].[������� �����] AS LS 
JOIN [stack].[������� ��������] AS LI 
	ON  LS.ROW_ID=LI.������� AND LI.[�����������]=0 
JOIN stack.[������� �����] AS LF ON LI.��������=LF.ROW_ID 
JOIN stack.[������� ��������] AS LU 
	ON LU.�������=LS.ROW_ID AND LU.[�����������]=1 
JOIN stack.[������� �����] AS LL 
	ON LU.��������=LL.ROW_ID 
LEFT JOIN stack.�������� AS OP 
	ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=76 AND GETDATE() BETWEEN OP.������ AND OP.������ AND OP.��������!=2
WHERE LS.[���]=5 
GROUP BY LF.�������, LL.�������
ORDER BY  LF.�������, LL.�������

SELECT	*
FROM	stack.[��������]
Where	ROW_ID = 208135


