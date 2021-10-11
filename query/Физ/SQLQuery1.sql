DECLARE @date datetime='20200401';
WITH
--����������
NACHISLENO
	AS 
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS [��������� ��������������� �����������]
				, SUM(NT.�����) AS [����� ��������������� �����������]
				, NT.���������������� AS [����� ����]
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		GROUP BY NT.����, NT.����������������
		),
--����������
PERERASCH
	AS
		(
		SELECT NP.���� AS �������
			   , SUM(NP.�����) AS [����� �����������]
		FROM stack.������� AS NP
		WHERE NP.[����� �������]=@date
		GROUP BY NP.����
		),
--������ ��������
SALDO_VHOD
	AS
		(
		SELECT NS.���� AS �������
				,SUM(NS.�����) AS [������ �� ����� ������ 100,400]
		FROM stack.������� AS NS
		WHERE NS.[����� �������]=DATEADD(mm, -1, @date) AND (NS.[����� ������] BETWEEN 100 AND 199) OR (NS.[����� ������] BETWEEN 400 AND 499) 
		GROUP BY NS.����
		),
--������ ���������
--SALDO_ISHOD
--	AS
--		(
--		SELECT NS.���� AS �������
--				,SUM(NS.�����) AS [������ �� ������ ������ 100,400]
--		FROM stack.������� AS NS
--		WHERE NS.[����� �������]=@date AND (NS.[����� ������] BETWEEN 100 AND 199) OR (NS.[����� ������] BETWEEN 400 AND 499) 
--		),
USLUGA
	AS
		(
			SELECT	LI.������� 
			,[stack].[CLR_Concat](ISNULL(TU.[����� ������],TUD.[����� ������])) AS [����� ������]
			,[stack].[CLR_Concat](ISNULL(TU.������������,TUD.������������)) AS [��� �������������]
			FROM stack.[������� ��������] AS LI
--��� ��
			LEFT JOIN stack.[������ �����] AS SU
				ON SU.[����-������]=LI.������� 
			LEFT JOIN stack.[���� �����] AS TU
				ON TU.ROW_ID=SU.[���-������]
--��� ����
			LEFT JOIN stack.[������ �����] AS SUD
				ON SUD.[����-������]=LI.�������� 
			LEFT JOIN stack.[���� �����] AS TUD
				ON TUD.ROW_ID=SUD.[���-������]
			WHERE LI.�����������=3 AND LI.����������=5
			GROUP BY LI.�������
		),
TARIF
AS
(
		SELECT	NT.���� AS ������� 
				, NT.���������������� AS [�����]
		FROM  stack.������ AS NT
			LEFT JOIN stack.[������ �����] AS SU
				ON SU.[����-������]=NT.����
			LEFT JOIN stack.[���� �����] AS TU
				ON TU.ROW_ID=SU.[���-������]
		WHERE  NT.[����� �������]=@date AND NT.[����� ������]=102
		GROUP BY NT.����, NT.����������������
)

		SELECT U.[����� ������]
				 ,NA.[����� ��������������� �����������]
		 ,ISNULL(PER.[����� �����������], 0)
		 ,(NA.[����� ��������������� �����������]+PER.[����� �����������]) AS [����� �����] 
		 ,NA.[����� ����]
		 ,NA.[��������� ��������������� �����������]
		 ,T.�����
		 FROM stack.[������� �����] AS LS
		 LEFT JOIN USLUGA AS U ON LS.ROW_ID=U.�������
		 LEFT JOIN NACHISLENO AS NA ON NA.�������=LS.ROW_ID
		 LEFT JOIN PERERASCH AS PER ON PER.�������=LS.ROW_ID
		 LEFT JOIN TARIF AS T ON T.�������=LS.ROW_ID
		 WHERE LS.ROW_ID=164180 