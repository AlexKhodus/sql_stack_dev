USE tns_kuban_fl_dev;
DECLARE @data dateTime='20200318';

--������ �������, ����� � ���-�� ����.����������, ���-�� �����
SELECT 
		VP.����� AS [���������]
		, COUNT(DISTINCT PV.ROW_ID) AS [�������]
		, COUNT(SO.ROW_ID) AS [�������]
		, SUM(SO.�����) AS [����� ��������]
		, PV.���_��
FROM stack.[������ ������] AS SO
JOIN stack.�������� AS PV
ON PV.ROW_ID=SO.[������-������] AND PV.[��� ���������]=67
JOIN stack.�������� AS VP
ON VP.ROW_ID=PV.[������-�������] AND VP.[��� ���������]=3
WHERE VP.ROW_ID=2639315
--VP.����=@data
GROUP BY VP.�����, PV.ROW_ID, PV.���_�� 



