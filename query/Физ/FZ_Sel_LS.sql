SELECT LS.�����,SO.��������������, NR.������������
FROM stack.[������� �����] AS LS
LEFT JOIN stack.[������ ��������] AS SO ON SO.[�������-����]=LS.ROW_ID
LEFT JOIN stack.������������ AS NR ON SO.[������������-�������]=NR.ROW_ID
WHERE SO.ROW_ID IS NULL AND LS.���=5
--����� �� ��� �������