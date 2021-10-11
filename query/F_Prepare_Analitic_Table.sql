/*
    -- �������� �������
    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[Analitic_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[Analitic_LS_ArtemovAS](
        [������] [int] NOT NULL,
        [�����] [varchar](5) NOT NULL,
        [����������] [int] NOT NULL,
        [����] [int] NOT NULL
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS]
    (
        [������] ASC,
        [�����] ASC,
        [����������] ASC,
        [����] ASC
    )
    GO

    DROP INDEX IF EXISTS [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS] WITH ( ONLINE = OFF )
    GO

    DROP TABLE IF EXISTS [dbo].[AnaliticReplace_LS_ArtemovAS]
    GO

    CREATE TABLE [dbo].[AnaliticReplace_LS_ArtemovAS](
	    [������] [int] NOT NULL,
    ) ON [PRIMARY]
    GO

    CREATE UNIQUE CLUSTERED INDEX [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS]
    (
	    [������] ASC
    )
    GO

    ALTER INDEX [IDX_main] ON [dbo].[Analitic_LS_ArtemovAS] REBUILD
    ALTER INDEX [IDX_main] ON [dbo].[AnaliticReplace_LS_ArtemovAS] REBUILD
*/

WITH Replaced AS (
    SELECT * FROM (VALUES -- ��� ���� �����, ����� ������ ����������� ����������1
        (191), (192), (193), (199), (291), (292), (293),
        (145), (146), (149), (181), (182), (183), (188),
        (245), (246), (249), (281), (282), (283), (288),
        (184), (185), (186), (187)
    ) AS V(������)
)
INSERT INTO [dbo].[AnaliticReplace_LS_ArtemovAS]
SELECT * FROM Replaced;

WITH Services AS (
    SELECT '�' AS ������, ������, '�' AS �����, 1 AS ����������, 1 AS ���� FROM (VALUES (101), (151), (181), (191), (201), (251), (281), (291), (401), (4001), (4003)) AS V(������) UNION ALL -- ������� ����� - ���� �����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 1 AS ���� FROM (VALUES (154), (254))                                                                  AS V(������) UNION ALL -- ������� ����� - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 2 AS ���� FROM (VALUES (157), (257))                                                                  AS V(������) UNION ALL -- ������� ����� - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 1 AS ���� FROM (VALUES (166), (266))                                                                  AS V(������) UNION ALL -- ������� ����� - ��� ������ - ���
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 2 AS ���� FROM (VALUES (160), (260))                                                                  AS V(������) UNION ALL -- ������� ����� - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 3 AS ���� FROM (VALUES (163), (263))                                                                  AS V(������) UNION ALL -- ������� ����� - ��� ������ - �������

    SELECT '�' AS ������, ������, '�' AS �����, 1 AS ����������, 1 AS ���� FROM (VALUES (102), (152), (182), (192), (202), (252), (282), (292), (402))                 AS V(������) UNION ALL -- ������������  - ���� �����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 1 AS ���� FROM (VALUES (155), (255))                                                                  AS V(������) UNION ALL -- ������������  - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 2 AS ���� FROM (VALUES (158), (258))                                                                  AS V(������) UNION ALL -- ������������  - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 1 AS ���� FROM (VALUES (167), (267))                                                                  AS V(������) UNION ALL -- ������������  - ��� ������ - ���
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 2 AS ���� FROM (VALUES (161), (261))                                                                  AS V(������) UNION ALL -- ������������  - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 3 AS ���� FROM (VALUES (164), (264))                                                                  AS V(������) UNION ALL -- ������������  - ��� ������ - �������
     
    SELECT '�' AS ������, ������, '�' AS �����, 1 AS ����������, 1 AS ���� FROM (VALUES (103), (153), (183), (193), (203), (253), (283), (293), (403))                 AS V(������) UNION ALL -- ����          - ���� �����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 1 AS ���� FROM (VALUES (156), (256))                                                                  AS V(������) UNION ALL -- ����          - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 2 AS ����������, 2 AS ���� FROM (VALUES (159), (259))                                                                  AS V(������) UNION ALL -- ����          - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 1 AS ���� FROM (VALUES (168), (268))                                                                  AS V(������) UNION ALL -- ����          - ��� ������ - ���
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 2 AS ���� FROM (VALUES (162), (262))                                                                  AS V(������) UNION ALL -- ����          - ��� ������ - ����
    SELECT '�' AS ������, ������, '�' AS �����, 3 AS ����������, 3 AS ���� FROM (VALUES (165), (265))                                                                  AS V(������) UNION ALL -- ����          - ��� ������ - �������

    SELECT '�' AS ������, ������, '����'  AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (301), (302), (303), (304), (305))                                        AS V(������) UNION ALL -- ������ ������  - ����������
    SELECT '�' AS ������, ������, '�����' AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (351), (352), (353), (354), (355))                                        AS V(������) UNION ALL -- ������ ������  - �����������
    SELECT '�' AS ������, ������, '����'  AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (3700), (3701))                                                           AS V(������) UNION ALL -- ������ ������  - ����������
    SELECT '�' AS ������, ������, '����'  AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (3800), (3801))                                                           AS V(������) UNION ALL -- ������ ������  - �������� ��������
    SELECT '�' AS ������, ������, '�����' AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (3900), (3901))                                                           AS V(������) UNION ALL -- ������ ������  - �������� ����
    SELECT '�' AS ������, ������, '����'  AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (65535))                                                                  AS V(������) UNION ALL -- ������ ������  - ����
    SELECT '�' AS ������, ������, '�����' AS �����, 0 AS ����������, 0 AS ���� FROM (VALUES (20000), (21001))                                                         AS V(������) UNION ALL -- ������ ������  - �������� �� ����������������

    SELECT '�' AS ������, ������, '�' AS �����, 1 AS ����������, 1 AS ���� FROM 
        (VALUES (109), (135), (145), (146), (149), (176), (184), (185), (186), (187), (188), (189), (199), (235), (245), (246), (249), (284), (285), (286), (287),
                (100), (130), (150), (200), (230), (250), (400))                                                                                                     AS V(������)            -- ��������� ������ 100, 200 �����, ���������� �� �� ������� ����� �������������
)
INSERT INTO [dbo].[Analitic_LS_ArtemovAS](������, �����, ����������, ����)
SELECT ������, �����, ����������, ����
FROM Services
WHERE ������ = '�'