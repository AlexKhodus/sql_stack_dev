USE tns_kuban_fl_dev
SELECT DISTINCT LS.����� AS [� �������� �����],
				CR.���,
				(LF.������� +' '+ ORG.��������) AS [����������� �������������],
				(LFNP.������� +' '+  '��.'+ LFU.�������+ ' '+ '�.'+ CONVERT(varchar, LFD.�����)+' '+ '��.'+CONVERT(varchar, LFKV.�����)) AS [�����],
				PH.����� AS �������
				--�������� �����
				--!!!�������� ����� �� ��������� ��������
				/*CASE 
				WHEN PH.�����=1 THEN '+' 
				WHEN PH.�����=2 THEN '����������'
				WHEN PH.�����=3 THEN '���������� � ���'
				END AS '������������'*/
FROM stack.[������� �����] AS LS
JOIN [stack].[������� ��������] AS LI 
	ON  LS.ROW_ID=LI.������� AND LI.[�����������]=0 
JOIN stack.[������� �����] AS LF ON LI.��������=LF.ROW_ID 
JOIN stack.[������� ��������] AS LU 
	ON LU.�������=LS.ROW_ID AND LU.[�����������]=1 
--�������� ����������� ��
LEFT JOIN stack.�������� AS OP 
	ON OP.[����-���������]=LS.ROW_ID AND OP.[����-���������]=76 AND GETDATE() BETWEEN OP.������ AND OP.������ AND OP.��������!=2
--���
JOIN stack.[�������� �����������] AS CR
	ON CR.[����-����������]=LS.ROW_ID
--�������
JOIN stack.[��������] AS PH
	ON PH.[����-�������]=LS.ROW_ID
LEFT JOIN stack.����������� AS ORG
ON ORG.ROW_ID=LS.[����-�������� �������]
--�����
JOIN [stack].[������� ��������] AS LIU 
	ON  LS.ROW_ID=LIU.������� AND LIU.[�����������]=2 
JOIN stack.[������� �����] AS LFU ON LIU.��������=LFU.ROW_ID 
JOIN [stack].[������� ��������] AS LID 
	ON  LS.ROW_ID=LID.������� AND LID.[�����������]=3 
JOIN stack.[������� �����] AS LFD ON LID.��������=LFD.ROW_ID 
JOIN [stack].[������� ��������] AS LIKV 
	ON  LS.ROW_ID=LIKV.������� AND LIKV.[�����������]=4 
JOIN stack.[������� �����] AS LFKV ON LIKV.��������=LFKV.ROW_ID 
JOIN [stack].[������� ��������] AS LINP 
	ON  LS.ROW_ID=LINP.������� AND LINP.[�����������]=12 
JOIN stack.[������� �����] AS LFNP ON LINP.��������=LFNP.ROW_ID 
WHERE LS.���=5 AND LFD.ROW_ID=1322457

/*USE tns_kuban_fl_dev
SELECT LI.�����������,
	   LI.�������,
CASE 
	WHEN LI.�����������=0 THEN LS.�������
	WHEN LI.�����������=1 THEN ORG.��������
	WHEN LI.����������� IN (12,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.����������� IN (12,2) AND CY.��_�����=0 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.����������� IN (11,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.����������� IN (11,2) AND CY.��_�����=0 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.����������� IN (13,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.����������� IN (13,2) AND CY.��_�����=0 THEN CY.�������� + ' ' + CY.���������� 
	WHEN LI.�����������=3 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
	WHEN LI.�����������=4 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
	WHEN LI.�����������=5 THEN CAST(LS.����� AS nvarchar(12))
	END AS �����
FROM stack.[������� ��������] AS LI
JOIN stack.[������� �����] AS LS
	ON LI.�����������=LS.ROW_ID
LEFT JOIN stack.������ AS CY
	ON LS.[�����-������� ����]=CY.ROW_ID
LEFT JOIN stack.����������� AS ORG
	ON ORG.ROW_ID=LS.[����-�������� �������]
WHERE LI.����������=5 */
