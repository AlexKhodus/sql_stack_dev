-- ����������
DECLARE @Phones TABLE (
				�������					BIGINT,
				�������					NVARCHAR(256),
				���						INT,
				[��������� � ��������]  INT,
				[��� ��������]			INT,
				�����������				INT
					  );

INSERT INTO @Phones (�������, �������, ���, [��������� � ��������], [��� ��������], �����������)
SELECT 
    [�������], 
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([�������] , ' ', ''), '+', ''),'-', ''),'(', ''), ')', ''),
	CASE [���]
        WHEN '�������'					   THEN 1
        WHEN '��������'					   THEN 2
        WHEN '�������'					   THEN 3
        WHEN '������'					   THEN 4
		ELSE 0
    END,
	CASE [���������_�_��������]
		WHEN  '���'						   THEN 1 
		WHEN  '�������'					   THEN 2 
		WHEN  '���;�������'				   THEN 3
        WHEN  'E-MAIL'					   THEN 4
        WHEN  '���;E-MAIL'				   THEN 5
        WHEN  '�������;E-MAIL'			   THEN 6
        WHEN  '���;�������;E-MAIL'		   THEN 7
		ELSE 0
	END,
	CASE [��� ��������]
        WHEN '�����'					   THEN 1
        WHEN '���������'				   THEN 2
        WHEN '�����;���������'			   THEN 3
        WHEN '�����������'				   THEN 4
        WHEN '�����;�����������'		   THEN 5
        WHEN '���������;�����������'	   THEN 6
        WHEN '�����;���������;�����������' THEN 7
        ELSE 0
    END,
	IIF([�����������] = '��', 1, 0)
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=g:\Bulk\���_1612.xlsx',
    'select * from [����2$]')
WHERE LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(�������, ' ', ''), '+', ''),'-', ''),'(', ''), ')', '')) = 11; 
	SELECT *
	FROM  @Phones AS P

---- ����������
UPDATE p
SET    [����������������] = CAST(GETDATE() AS DATE),  -- ����������������
	   ���                = T.���,                    -- ���              
	   �����              = T.[��������� � ��������], -- �����     
	   �����������		  = T.[��� ��������],	      -- �����������        
	   [�������������]	  = T.�����������  			  -- �������������	
OUTPUT deleted.ROW_ID,
	   deleted.���,
	   deleted.�����,
	   deleted.�����������,
	   deleted.�������������,
	   deleted.����������������
INTO   [dbo].[temp_��������_HodusAL_2020_16_12]
--SELECT 
--	L.�����,
--	T.�������,
--	P.�����,
--	CAST(GETDATE() AS DATE),  -- ����������������
--  T.���,                    -- ���              
--  T.[��������� � ��������], -- �����     
--  T.[��� ��������],	      -- �����������        
--  T.�����������  		      -- �������������
FROM @Phones AS T
JOIN stack.[������� �����] AS L ON L.����� = T.�������
JOIN stack.�������� AS P
  ON P.[����-�������] = L.row_id
     AND T.������� = RIGHT('8' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(P.�����, ' ', ''), '+', ''),'-', ''),'(', ''), ')', ''), 11)
WHERE L.��� = 5;


