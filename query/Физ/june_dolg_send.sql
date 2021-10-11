DECLARE @date DATE = '20210723',
		@PER DATE = '20210601';
WITH ������ AS (
	SELECT SO.[����-������],
		   ISNULL(SUM(SO.�����),0) AS �����
	FROM stack.[������ ������] AS SO 
	JOIN stack.�������� As D ON D.ROW_ID=SO.[������-������]
	JOIN [stack].[��������] AS V ON D.[������-�������] = V.ROW_ID
	WHERE V.���� > '20210701' 
	GROUP BY SO.[����-������]
),
������ AS (
	SELECT SUM(ISS.�����) AS ���������,
			ISS.����
	FROM stack.������� AS ISS 
	WHERE  ISS.[����� �������]=@PER  AND ((ISS.[����� ������]>=100 and ISS.[����� ������]<200) OR (ISS.[����� ������]>=400 and ISS.[����� ������]<500)) 
	GROUP BY ISS.����
),
���� AS  (
SELECT S.����, (S.���������-O.�����) AS ����
FROM ������ AS S
JOIN ������ AS O ON O.[����-������]=S.����
),
�������� AS (
SELECT S.[����-���������], S.����������
FROM  stack.�������� AS S
WHERE S.[����-���������]=281 AND @date BETWEEN S.������ AND S.������
),
�������� AS (
SELECT LS.�����, 
	   round((D.����),2,1) AS ����,
	   ISNULL(P.����������,E.�����) AS EMAIL
FROM stack.[������� �����] AS LS
JOIN ���� AS D ON D.����=LS.ROW_ID
LEFT JOIN �������� AS P ON P.[����-���������]=LS.ROW_ID
LEFT JOIN stack.�������� AS E ON E.[����-�������]=LS.ROW_ID AND E.���=4
WHERE D.���� >= 100 
)
SELECT *
FROM ��������
WHERE EMAIL IS NOT NULL
