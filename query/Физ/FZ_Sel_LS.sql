SELECT LS.Номер,SO.ЗаводскойНомер, NR.Наименование
FROM stack.[Лицевые счета] AS LS
LEFT JOIN stack.[Список объектов] AS SO ON SO.[Объекты-Счет]=LS.ROW_ID
LEFT JOIN stack.Номенклатура AS NR ON SO.[Номенклатура-Объекты]=NR.ROW_ID
WHERE SO.ROW_ID IS NULL AND LS.Тип=5
--выбор ЛС без счетчиа