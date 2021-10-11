
DECLARE @PER DATE = '20200426',
	@крУчасток NVARCHAR(MAX) = 35033; --краснодарский участок
SELECT D.ROW_ID,
       D.Номер,
       ISNULL(
             NULLIF(REPLACE(RTRIM(LTRIM(S.Примечание)), ' ', ''), ''), 
             NULLIF(REPLACE(RTRIM(LTRIM(O.Email)), ' ', ''), '')
       ) AS email
FROM stack.Договор AS D
JOIN stack.Организации AS O ON O.ROW_ID=D.Плательщик
LEFT JOIN [stack].[Свойства] AS S 
       ON D.ROW_ID = S.[Параметры-Договор]
       AND @PER BETWEEN S.ДатНач AND S.ДатКнц
       AND S.[Виды-Параметры] = (SELECT TOP(1) row_id FROM [stack].[Виды параметров] WHERE Название = 'РАССЫЛКА')
       AND S.Значение = 1
WHERE D.ROW_ID IN (SELECT [Договор] FROM [stack].[contracts_lite](@крУчасток))
  AND D.Папки_ADD = 1