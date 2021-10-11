-- Обновление
DECLARE @Phones TABLE (
				Лицевой					BIGINT,
				Контакт					NVARCHAR(256),
				Тип						INT,
				[Участвует в рассылке]  INT,
				[Тип Рассылки]			INT,
				Подтвержден				INT
					  );

INSERT INTO @Phones (Лицевой, Контакт, Тип, [Участвует в рассылке], [Тип Рассылки], Подтвержден)
SELECT 
    [Лицевой], 
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Контакт] , ' ', ''), '+', ''),'-', ''),'(', ''), ')', ''),
	CASE [Тип]
        WHEN 'Сотовый'					   THEN 1
        WHEN 'Домашний'					   THEN 2
        WHEN 'Рабочий'					   THEN 3
        WHEN 'Другой'					   THEN 4
		ELSE 0
    END,
	CASE [Участвует_в_рассылке]
		WHEN  'СМС'						   THEN 1 
		WHEN  'ТЕЛЕФОН'					   THEN 2 
		WHEN  'СМС;ТЕЛЕФОН'				   THEN 3
        WHEN  'E-MAIL'					   THEN 4
        WHEN  'СМС;E-MAIL'				   THEN 5
        WHEN  'ТЕЛЕФОН;E-MAIL'			   THEN 6
        WHEN  'СМС;ТЕЛЕФОН;E-MAIL'		   THEN 7
		ELSE 0
	END,
	CASE [Вид рассылки]
        WHEN 'ОБЩИЙ'					   THEN 1
        WHEN 'КВИТАНИЦЯ'				   THEN 2
        WHEN 'ОБЩИЙ;КВИТАНИЦЯ'			   THEN 3
        WHEN 'ОГРАНИЧЕНИЕ'				   THEN 4
        WHEN 'ОБЩИЙ;ОГРАНИЧЕНИЕ'		   THEN 5
        WHEN 'КВИТАНИЦЯ;ОГРАНИЧЕНИЕ'	   THEN 6
        WHEN 'ОБЩИЙ;КВИТАНИЦЯ;ОГРАНИЧЕНИЕ' THEN 7
        ELSE 0
    END,
	IIF([Подтвержден] = 'Да', 1, 0)
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=g:\Bulk\УПУ_1612.xlsx',
    'select * from [Лист2$]')
WHERE LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Контакт, ' ', ''), '+', ''),'-', ''),'(', ''), ')', '')) = 11; 
	SELECT *
	FROM  @Phones AS P

---- Добавление
UPDATE p
SET    [ДатаАктуализации] = CAST(GETDATE() AS DATE),  -- ДатаАктуализации
	   Тип                = T.Тип,                    -- Тип              
	   Флаги              = T.[Участвует в рассылке], -- Флаги     
	   ВидРассылки		  = T.[Тип Рассылки],	      -- ВидРассылки        
	   [Подтверждение]	  = T.Подтвержден  			  -- Подтверждение	
OUTPUT deleted.ROW_ID,
	   deleted.Тип,
	   deleted.Флаги,
	   deleted.ВидРассылки,
	   deleted.Подтверждение,
	   deleted.ДатаАктуализации
INTO   [dbo].[temp_Телефоны_HodusAL_2020_16_12]
--SELECT 
--	L.Номер,
--	T.Контакт,
--	P.Номер,
--	CAST(GETDATE() AS DATE),  -- ДатаАктуализации
--  T.Тип,                    -- Тип              
--  T.[Участвует в рассылке], -- Флаги     
--  T.[Тип Рассылки],	      -- ВидРассылки        
--  T.Подтвержден  		      -- Подтверждение
FROM @Phones AS T
JOIN stack.[Лицевые счета] AS L ON L.Номер = T.Лицевой
JOIN stack.Телефоны AS P
  ON P.[Счет-Телефон] = L.row_id
     AND T.Контакт = RIGHT('8' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(P.Номер, ' ', ''), '+', ''),'-', ''),'(', ''), ')', ''), 11)
WHERE L.Тип = 5;


