	DECLARE @date    datetime = '20200901',
		    @������� NVARCHAR(MAX) = 635992;
			--1054;

	DECLARE @������������������� INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '��������'),
            @�����������������   INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '���������'),
            @��������������      INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '������'),
		    @��������������      INT = (SELECT TOP (1) row_id FROM stack.[���� ����������] WHERE �������� = '������');

   IF OBJECT_ID(N'tempdb..#TypeEnter', N'U') IS NOT NULL
      DROP TABLE #TypeEnter

   CREATE TABLE #TypeEnter
      (flags INT PRIMARY KEY,
      Typename NVARCHAR(30) NOT NULL)
      INSERT INTO #TypeEnter
      VALUES	 (0  , '��')
                ,(1  , '��')
                ,(2  , '��')
                ,(3  , '��')
                ,(4  , '���������')
                ,(5  , '������')
                ,(6  , '��/�')
                ,(7  , '���������')
                ,(8  , '����')
                ,(9  , 'WEB')
                ,(10 , 'OUT')
                ,(11 , '�����')
                ,(12 , '�������')
                ,(13 , '����')
                ,(14 , '�����')
                ,(15 , '�������')
                ,(16 , 'SMS')
                ,(17 , '���')
                ,(18 , '���');

   IF OBJECT_ID(N'tempdb..#Result', N'U') IS NOT NULL
      DROP TABLE #Result;
  
   CREATE TABLE #Result(
      ROW_ID					INT,
      �������					BIGINT,
      ������					NVARCHAR(256),
	  �����						NVARCHAR(MAX),
	  �����						NVARCHAR(MAX),
	  ��������					NVARCHAR(MAX),
	  �����						NVARCHAR(MAX),
	  ���						NVARCHAR(MAX),
	  ��������					INT,
	  ���						NVARCHAR(MAX),
	  �������					NVARCHAR(MAX),
	  EMAIL						NVARCHAR(MAX),
	  �����������				NVARCHAR(MAX),
	  ���������					NVARCHAR(MAX),
	  �����						FLOAT,
	  �����						NVARCHAR(MAX),
	  �������					NVARCHAR(MAX),
	  �����������				INT,
	  ����������				INT,
	  ����������				INT,
	  ����������				NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  ���������������			DATE,
	  �����������				INT,
	  ��������������			NVARCHAR(MAX),
	  �������_100				FLOAT,
	  �������_300				FLOAT,
	  ���������_100				FLOAT,
	  ���������_300				FLOAT,
	  ���������_100				FLOAT,
	  ���������_300				FLOAT,
	  ��������������			FLOAT,
	  ��������������			FLOAT,
	  �����������				FLOAT,
	  �����������				FLOAT,
	  ����������_100			FLOAT,
	  ����������_300			FLOAT,
	  �������������				FLOAT,
	  ��������					DATE,
	  ��������_100				FLOAT,
	  ��������_300				FLOAT,
	  �����������				FLOAT,		
	  �������					FLOAT,
	  ��������					BIGINT,
	  ��������������			NVARCHAR(MAX),
	  ��������������			NVARCHAR(MAX),
	  �����������				NVARCHAR(MAX),
	  ������������				FLOAT,
	  ��������					FLOAT,
	  ����_��					NVARCHAR(MAX),
	  ��_����					NVARCHAR(MAX),
	  ������					NVARCHAR(MAX),
	  �����������				NVARCHAR(MAX),
	  ��������					INT,
	  �������					INT,
	  �������					NVARCHAR(MAX),
	  �������������				NVARCHAR(MAX)
   );

   INSERT INTO #Result(ROW_ID, �������, ������)
   SELECT
      LS.ROW_ID,
      LS.�����,
      LB.������� 
   FROM stack.[������� ��������] AS LI
   JOIN stack.[������� �����] AS LS ON LS.row_id = LI.�������
   JOIN [stack].[������� ��������] AS LHB ON LI.������� = LHB.������� AND LHB.�����������=0
   JOIN stack.[������� �����] AS LB ON LHB.��������=LB.ROW_ID
   WHERE LI.���������� = 5
     AND LI.�������� IN (SELECT * FROM [stack].[CLR_Split](@�������));

   CREATE INDEX NCI_ROW_ID ON #Result (ROW_ID);
   
        WITH ADDRES	AS (
			SELECT  pvt_adrs.�������,
					[0]+' '+[1]+' '+[13] AS �����,
					[12] AS [������������� ��],
					[2]  AS [����������� �����],
					[3]  AS [���, ������],
					[4]  AS ��������,
					IIF([4] IS NOT NULL,([0]+' '+[1]+','+' '+[13]+','+' '+[12] + ','+' '+ [2]+ ','+' '+[3] +','+' '+[4]),
										([0]+' '+[1]+','+' '+[13]+','+' '+[12] + ','+' '+ [2]+ ','+' '+[3])) AS �����		
         FROM(
            SELECT	
                  LI.�����������,
                  LI.�������,
                  CASE 
                     WHEN LI.�����������=0 THEN LS.�������
                     WHEN LI.�����������=1 THEN ORG.��������
                     WHEN LI.����������� IN (12,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.����������
                     WHEN LI.����������� IN (12,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.�������� 
                     WHEN LI.����������� IN (11,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.���������� 
                     WHEN LI.����������� IN (11,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.��������
                     WHEN LI.����������� IN (13,2) AND CY.��_�����=1 THEN CY.�������� + ' ' + CY.����������
                     WHEN LI.����������� IN (13,2) AND CY.��_�����=0 THEN CY.���������� + ' ' + CY.��������   
                     WHEN LI.�����������=3 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
                     WHEN LI.�����������=4 THEN CAST(LS.����� AS nvarchar(12)) + ' ' + LS.�������
                     WHEN LI.�����������=5 THEN CAST(LS.����� AS nvarchar(12))
                  END AS �����
            FROM stack.[������� ��������] AS LI
            JOIN stack.[������� �����] AS LS
               ON LI.��������=LS.ROW_ID
            LEFT JOIN stack.������ AS CY
               ON LS.[�����-������� ����]=CY.ROW_ID
            --�������
            LEFT JOIN stack.����������� AS ORG
               ON ORG.ROW_ID=LS.[����-�������� �������] 
            --������������ �����-�������
            ) AS pvt_adrs
         PIVOT (
                  MAX(�����) FOR pvt_adrs.����������� IN ([0],[1],[12],[13],[11],[2],[3],[4],[5])
               ) AS pvt_adrs)
			
          UPDATE R
          SET  �����    = A.�����,
	            �������� = A.[������������� ��],
	            �����    = A.[����������� �����],
               ���      = A.[���, ������],
               �������� = A.��������,
               �����    = A.�����

      FROM #Result AS R
      JOIN ADDRES AS A ON R.ROW_ID = A.�������;

      UPDATE R
      SET ��� = F.��� 
      FROM #Result AS R
      JOIN stack.[�������� �����������] AS F ON R.ROW_ID = F.[����-����������];

   WITH PHONE AS (
			SELECT 
					[stack].[CLR_Concat](PH.�����) AS �������,
               PH.[����-�������] AS �������
			FROM  stack.[��������] AS PH
			WHERE  PH.�����!=4 
			GROUP BY PH.[����-�������]
   )   
   UPDATE R
   SET ������� = PH.������� 
   FROM #Result AS R
   JOIN PHONE   AS PH ON R.ROW_ID = PH.�������;

   WITH  EMAILS
	AS
		(
			SELECT 
					[stack].[CLR_Concat](EM.�����) AS [E-MAIL]
					, EM.[����-�������] AS �������
			FROM stack.[��������] AS EM
			WHERE EM.�����=4
			GROUP BY EM.[����-�������] 
		)
      UPDATE R
      SET email = EM.[E-MAIL] 
      FROM #Result AS R
      JOIN EMAILS AS EM ON R.ROW_ID = EM.�������;

   WITH  USLUGA
	AS
		(
			SELECT	LI.�������
			,T.�������� AS �����
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
			LEFT JOIN 	stack.[������] AS T
			ON TU.ROW_ID=T.[���-������] OR TUD.ROW_ID=T.[���-������]
			WHERE LI.�����������=3 AND LI.����������=5 
			AND T.������=(
			SELECT TOP 1 T.������
			FROM stack.[������] AS T			
			WHERE T.[���-������]=TUD.ROW_ID OR TU.ROW_ID=T.[���-������]
			ORDER BY T.������ DESC)
			GROUP BY LI.�������
			, T.��������)

      UPDATE R
      SET ����������� = U.[����� ������],
      ��������� = U.[��� �������������],
      ����� = U.�����
      FROM #Result AS R
      JOIN USLUGA AS U ON R.ROW_ID = U.�������;

   WITH SCHETCHIK 
	AS
		(
			SELECT  SO.[�������-����] AS �������
					, NR.������������ AS [��� ��]
					, SO.�������������� AS [����� ��]
					, SO.����������
					, SO.�����������
               , SO.[����������� �������������]
					,CASE
						WHEN SS.��������� = 0 THEN '����������'
						WHEN SS.��������� = 1 THEN '���'
						WHEN SS.��������� = 2 THEN '�������'
						WHEN SS.��������� = 3 THEN '��������'
					END AS [��� �������]
			FROM stack.[������ ��������] AS SO 
			LEFT JOIN stack.������������ AS NR 
				ON SO.[������������-�������]=NR.ROW_ID
			JOIN stack.[��������� ��������] AS SS
				ON SS.[����-�������� ���������]=SO.[�������-����] AND SS.���������!=3 AND
				@date BETWEEN SS.������ AND SS.������
			WHERE @date BETWEEN SO.������ AND SO.������
         )

      UPDATE R
      SET �����       = SC.[��� ��],
          �������     = SC.[����� ��],
          ����������� = SC.����������,
          ����������  = SC.�����������,
          ����������  = SC.[����������� �������������],
          ����������  = SC.[��� �������]
      FROM #Result AS R
      JOIN SCHETCHIK AS SC ON R.ROW_ID = SC.�������;

   WITH POKAZANIYA 
	AS 
		(
		SELECT
				PREDPOK1.��������� AS [�����������]
				,PREDPOK1.���� AS [���������������]
				,TEPRED1.Typename AS [��������������]
				,PREDPOK2.��������� AS [�����������]
				,PREDPOK2.���� AS [���������������]
				,TEPRED2.Typename AS [��������������]				
				,PREDPOK3.���� AS [���������������]
				,PREDPOK3.��������� AS [�����������]
				,TEPRED3.Typename AS [��������������]
            ,OL.[�������-����] AS �������		
				,POK1.��������� AS [�����������]
				,POK1.���� AS [���������������]
				,TE1.Typename AS [��������������]
				,POK2.��������� AS [�����������]
				,POK2.���� AS [���������������]
				,TE2.Typename AS [��������������]
				,POK3.��������� AS [�����������]
				,POK3.���� AS [���������������]
				,TE3.Typename AS [��������������]
		FROM stack.[������ ��������] AS OL 
		LEFT JOIN stack.������������ AS NR 
			ON OL.[������������-�������]=NR.ROW_ID
		OUTER APPLY
			(
         SELECT TOP 1 TS.���������, TS.����, TS.��������
			FROM stack.[��������� ���������] AS TS
			WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
			AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
			ORDER BY TS.���� DESC
         ) AS POK1
      OUTER APPLY
         (
         SELECT TOP 1 TS.���������,TS.����, TS.��������
         FROM stack.[��������� ���������] AS TS
         WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
         AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
         ORDER BY TS.���� DESC
         ) AS POK2
      OUTER APPLY
         (
         SELECT TOP 1 TS.���������, TS.����, TS.��������
         FROM stack.[��������� ���������] AS TS
         WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
         AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
         ORDER BY TS.���� DESC
         ) AS POK3
--�������������
      OUTER APPLY
         (
         SELECT TOP 1 TS.���������, TS.����, TS.�������� 
         FROM stack.[��������� ���������] AS TS
         WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
         AND TS.�����=0 AND TS.[������-���������]=OL.ROW_ID
         AND POK1.����!=TS.����
         ORDER BY TS.���� DESC
         ) AS PREDPOK1
      OUTER APPLY
         (
         SELECT TOP 1 TS.���������, TS.����, TS.�������� 
         FROM stack.[��������� ���������] AS TS
         WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
         AND TS.�����=1 AND TS.[������-���������]=OL.ROW_ID
         AND POK2.����!=TS.����
         ORDER BY TS.���� DESC
         ) AS PREDPOK2
      OUTER APPLY
         (
         SELECT TOP 1 TS.���������, TS.����, TS.�������� 
         FROM stack.[��������� ���������] AS TS
         WHERE TS.[���������-����]=OL.[�������-����] AND TS.���=1 
         AND TS.�����=2 AND TS.[������-���������]=OL.ROW_ID
         AND POK3.����!=TS.����
         ORDER BY TS.���� DESC
         ) AS PREDPOK3
      LEFT JOIN #TypeEnter AS TE1     ON TE1.flags     =  POK1.��������
      LEFT JOIN #TypeEnter AS TE2     ON TE2.flags     =  POK2.��������
      LEFT JOIN #TypeEnter AS TE3     ON TE3.flags     =  POK3.��������
      LEFT JOIN #TypeEnter AS TEPRED1 ON TEPRED1.flags =  PREDPOK1.��������
      LEFT JOIN #TypeEnter AS TEPRED2 ON TEPRED2.flags =  PREDPOK2.��������
      LEFT JOIN #TypeEnter AS TEPRED3 ON TEPRED3.flags =  PREDPOK3.��������
      WHERE @date BETWEEN OL.������ AND OL.������
      )

      UPDATE R
      SET �����������     = POK.[�����������],
          ��������������� = POK.[���������������],
          ��������������  = POK.��������������,
          �����������     = POK.�����������,
          ��������������  = POK.[��������������],
          ��������������� = POK.[���������������],
          �����������     = POK.[�����������],
          ��������������� = POK.[���������������],
          ��������������  = POK.��������������,
          �����������     = POK.�����������,
          ��������������� = POK.[���������������],
          ��������������  = POK.[��������������],
          �����������     = POK.�����������,
          ��������������� = POK.[���������������],
          ��������������  = POK.[��������������],
          ��������������� = POK.���������������,
          �����������     = POK.[�����������],
          ��������������  = POK.[��������������]
      FROM #Result AS R
      JOIN POKAZANIYA AS POK ON R.ROW_ID = POK.�������;

   WITH SALDO_VHOD_100
	AS (
			SELECT SUM(S.Summa) AS ������_100,
					S.���� AS �������
			FROM(
				   SELECT NS.����
						  , SUM(NS.�����) AS Summa
		      	FROM stack.������� AS NS
					WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) 
						AND NS.[����� ������]  BETWEEN 100 AND 199
						OR  NS.[����� ������]  BETWEEN 400 AND 499
					GROUP BY NS.����
				) AS S
			GROUP BY S.����
		)

      UPDATE R
      SET  �������_100 = SV_100.[������_100]
      FROM #Result AS R
      JOIN SALDO_VHOD_100 AS SV_100 ON R.ROW_ID = SV_100.�������;

   WITH SALDO_VHOD_300
	AS (
		SELECT  SUM(S.Summa) AS ������_300,
				  S.���� AS �������
		FROM(
		   	SELECT NS.����
					 , SUM(NS.�����) AS Summa
				FROM stack.������� AS NS
				WHERE  NS.[����� �������]=DATEADD(mm, -1, @date) 
					AND NS.[����� ������] BETWEEN 300 AND 399
					OR NS.[����� ������]  BETWEEN 3700 AND 3799
					OR NS.[����� ������]  BETWEEN 3800 AND 3899
					OR NS.[����� ������]  BETWEEN 3900 AND 3999
				GROUP BY NS.����			
					) AS S
		GROUP BY S.����
		)
		
      UPDATE R
      SET  �������_300 = SV_300.[������_300]
      FROM #Result AS R
      JOIN SALDO_VHOD_300 AS SV_300 ON R.ROW_ID = SV_300.�������;

   WITH SALDO_ISHOD_100
	AS (
		SELECT SUM(S.Summa) AS ���������_100,
		       S.���� AS �������
		FROM(
		      SELECT NS.����
					 , SUM(NS.�����) AS Summa
				FROM stack.������� AS NS
				WHERE  NS.[����� �������]= @date 
						AND NS.[����� ������] BETWEEN 100 AND 199 
						OR NS.[����� ������] BETWEEN 400 AND 499
				GROUP BY NS.����
			) AS S
		GROUP BY S.����
		)
		
      UPDATE R
      SET  ���������_100 = IS_100.[���������_100]
      FROM #Result AS R
      JOIN SALDO_ISHOD_100 AS IS_100 ON R.ROW_ID = IS_100.�������;

  WITH SALDO_ISHOD_300
	AS
		(
			SELECT SUM(S.Summa) AS ���������_300,
					 S.���� AS �������
			FROM(
					SELECT NS.����
							 , SUM(NS.�����) AS Summa
					FROM stack.������� AS NS
					WHERE  NS.[����� �������] = @date
					   AND NS.[����� ������] BETWEEN 300 AND 399
						OR NS.[����� ������]  BETWEEN 3700 AND 3799
						OR NS.[����� ������]  BETWEEN 3800 AND 3899
						OR NS.[����� ������]  BETWEEN 3900 AND 3999
						GROUP BY NS.����
				) AS S
			GROUP BY S.����
		)
      UPDATE R
      SET  ���������_300 = IS_300.[���������_300]
      FROM #Result AS R
      JOIN SALDO_ISHOD_300 AS IS_300 ON R.ROW_ID = IS_300.�������;

  WITH NACH_100
	AS 
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS ���������_100
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		AND NT.[����� ������]  BETWEEN 100 AND 199
		OR NT.[����� ������]  BETWEEN 400 AND 499
		GROUP BY NT.����, NT.[����� �������]
		)
		
      UPDATE R
      SET  ���������_100 = N_100.[���������_100]
      FROM #Result AS R
      JOIN NACH_100 AS N_100 ON R.ROW_ID = N_100.�������;

  WITH NACH_300
	AS 
		(
		SELECT	NT.���� AS ������� 
				, SUM(NT.�����) AS ���������_300
		FROM  stack.������ AS NT
		WHERE   NT.[����� �������]=@date
			AND NT.[����� ������]  BETWEEN 300 AND 399
			OR  NT.[����� ������]  BETWEEN 3700 AND 3799
			OR  NT.[����� ������]  BETWEEN 3800 AND 3899
			OR  NT.[����� ������]  BETWEEN 3900 AND 3999
		GROUP BY NT.����, NT.[����� �������]
		)
		
      UPDATE R
      SET  ���������_300 = N_300.[���������_300]
      FROM #Result AS R
      JOIN NACH_300 AS N_300 ON R.ROW_ID = N_300.�������;

   WITH NACHISLENO
	AS 
		(SELECT	NT.���� AS ������� 
		, SUM(NT.�����) AS [��������������]
		, SUM(NT.�����) AS [��������������]
		FROM  stack.������ AS NT
		WHERE  NT.[����� �������]=@date
		GROUP BY NT.����, NT.[����� �������]
		)
      UPDATE R
      SET  �������������� = N.[��������������],
           �������������� = N.��������������
      FROM #Result AS R
      JOIN NACHISLENO AS N ON R.ROW_ID = N.�������;

   WITH PERERASCH
	AS
		(
		SELECT NP.���� AS �������
            , SUM(NP.�����) AS [����� �����������]
			   , SUM(NP.�����) AS [����� �����������]
			   
		FROM stack.������� AS NP
		WHERE NP.[����� �������]=@date
		GROUP BY NP.����
		)
		
      UPDATE R
      SET   ����������� = PERE.[����� �����������],
            ����������� = PERE.[����� �����������]
      FROM #Result AS R
      JOIN PERERASCH AS PERE ON R.ROW_ID = PERE.�������;

	WITH PLATEJ
	AS
		(
         SELECT TOP (1) WITH TIES 
                  SO.���� AS [���� ��������� ������] 
                  ,SO.[����-������] AS �������
         FROM stack.[������ ������] AS SO
         ORDER BY row_number() OVER (ORDER BY SO.���� DESC)
		)
		
      UPDATE R
      SET  �������� = PL.[���� ��������� ������]
      FROM #Result AS R
      JOIN PLATEJ AS PL ON R.ROW_ID = PL.�������;

   WITH SPIS_SALDO
	AS(
		SELECT
			KR.[����-���������] AS �������,
			SUM(IIF(TU.[����� ������] - TU.[����� ������] % 100 IN (100, 400), KS.�����, 0)) AS ��������_100400,
			SUM(IIF(TU.[����� ������] - TU.[����� ������] % 100 IN (300, 3700, 3800, 3900), KS.�����, 0)) AS ��������_300
		FROM stack.[��������� ���������] AS KR 
		JOIN stack.[��������� ������] AS KS ON KS.[������������-������] = KR.row_id
		JOIN stack.[���� �����] AS TU ON TU.ROW_ID = KS.[������-���������]
		WHERE ISNULL(KR.���, 0) != 1
		  AND KR.��������� = @date
		GROUP BY KR.[����-���������]
		)
   UPDATE R
   SET ��������_100 = SPS.��������_100400,
       ��������_300 = SPS.��������_300
   FROM #Result AS R
   JOIN SPIS_SALDO AS SPS ON R.Row_ID = SPS.�������;

   WITH BU
	AS 
	(
		SELECT SUM(NT.�����) AS [��������� �� ���� ��]
			   ,SUM(NT.�����) AS [����� �� ���� ��]
			   ,NT.���� AS �������
		FROM stack.������ AS NT
		WHERE NT.[����� ������]=(
		SELECT TOP 1 TU.[����� ������]
		FROM stack.[���� �����] AS TU
		WHERE TU.������������='���������� �����������'
		) AND NT.[����� �������]=@date
		GROUP BY  NT.����, NT.[����� �������]
	)
		
      UPDATE R
      SET   ����������� = BU.[��������� �� ���� ��],
            �������     = BU.[����� �� ���� ��]
      FROM #Result AS R
      JOIN BU ON R.ROW_ID = BU.�������;

   WITH  DOG_NUM
	AS (
		   SELECT LI.�������			
			      ,UKDOG_DOM.����� AS [����� ��������]
				   ,ORG.�������� AS [����������� ����������� ��������]
				   ,CASE 
						WHEN UK_DOM.[������� �������]=0 THEN ''
						WHEN UK_DOM.[������� �������]=1 THEN '��������� ������'
						WHEN UK_DOM.[������� �������]=2 THEN '��������� �� ������'
						WHEN UK_DOM.[������� �������]=3 THEN '������'
						WHEN UK_DOM.[������� �������]=4 THEN '�������� ��� � ��'
				   END AS [������� �������]
			FROM  stack.[������� ��������] AS LI
			LEFT JOIN stack.[����������� ��������] AS UK_DOM
				ON UK_DOM.[����-��]=LI.�������� AND LI.[�����������]=3 
			JOIN stack.[�� ��������] AS UKDOG_DOM
				ON UKDOG_DOM.ROW_ID=UK_DOM.[���-���������] AND
				@date BETWEEN UKDOG_DOM.������ AND UKDOG_DOM.������
			JOIN stack.����������� AS ORG
				ON UK_DOM.[�����������-��]=ORG.ROW_ID
		)  
      UPDATE R
      SET ��������       = DN.[����� ��������],
          �������������� = DN.[����������� ����������� ��������],
          �������������� = DN.[������� �������]
      FROM #Result AS R
      JOIN DOG_NUM AS DN ON R.ROW_ID = DN.�������;

   WITH ODPU
	AS (			
		SELECT 
			CASE 
				WHEN doc.����� IS NOT NULL THEN '��'
				WHEN doc.����� IS NULL     THEN '���'
			END AS [������� ����]
			,LI.�������
		FROM stack.[������� ��������] LI
		JOIN [stack].[��������� ���������] ps ON LI.�������� = ps.[���������-����]  AND  LI.�����������=3
		JOIN [stack].[��������] doc  on doc.[ROW_ID] = ps.[���������-��������] AND doc.[��� ���������] = 77 AND ps.��� = 6 AND doc.�������� = 0
		JOIN stack.[��������� ��������] AS SS
			ON SS.[����-�������� ���������]=LI.������� AND SS.���������!=3 
			AND @date BETWEEN SS.������ AND SS.������
		)
   
    UPDATE R
      SET ����������� = ODPU.[������� ����]
      FROM #Result AS R
      JOIN ODPU  ON R.ROW_ID = ODPU.�������;

   WITH ODN
	AS
		(
		SELECT O.[���������-����] AS �������
				,O.������
		FROM (SELECT TOP 1 PS.������,
			PS.[���������-����] 
		FROM stack.[��������� ���������] AS PS
		LEFT JOIN stack.�������� AS DOC
		ON DOC.ROW_ID=PS.[���������-��������] AND DOC.[��� ���������]=77 AND DOC.�������� = 0
		LEFT JOIN [stack].[������ ��������] AS SO ON SO.[�������-���������] = DOC.ROW_ID AND @date BETWEEN SO.������ AND SO.������) O
		)
   
    UPDATE R
      SET ������������ = ODN.������
      FROM #Result AS R
      JOIN ODN  ON R.ROW_ID = ODN.�������;

   WITH SOST_LS
	AS
		(
			SELECT  OP.[����-���������] AS �������
				,CASE
					WHEN OP.��������=0 THEN '������������' 
					WHEN OP.��������=1 THEN '�� ���������' 
					WHEN OP.��������=2 THEN '������' 
				END AS [��������� �������� (��� ����������)]
			FROM stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='���������') 
				AND (@date BETWEEN OP.������ AND OP.������)
		)
   
   UPDATE R
   SET  ����_�� = SLS.[��������� �������� (��� ����������)]
   FROM #Result AS R
   JOIN SOST_LS AS SLS ON R.ROW_ID = SLS.�������;

   WITH TYPE_UL
	AS
		(
			SELECT
				OP.[����-���������] AS �������
			,CASE 
				WHEN OP.�������� IS NULL THEN '���'
				WHEN OP.�������� IS NOT NULL THEN '��'
				ELSE '�� ���������'
			END AS ������
			FROM stack.�������� AS OP  
			WHERE OP.[����-���������]=@�������������� AND @date BETWEEN OP.������ AND OP.������
		)
   
   UPDATE R
   SET  ��_���� = TUL.������
   FROM #Result AS R
   JOIN TYPE_UL AS TUL ON R.ROW_ID = TUL.�������;

   WITH INDEX_
	AS
		(
			SELECT	
				LI.�������
				,CASE
					WHEN LS.��������������=0 OR LS.�������������� IS NULL 
					THEN ISNULL(OP.��������,OPD.��������)
					END AS ������
			FROM stack.[������� �����] AS LS
			JOIN stack.[������� ��������] AS LI
				ON  LS.ROW_ID=LI.������� AND LI.[�����������]=3 
--��� ��
			LEFT JOIN stack.�������� AS OP 
				ON OP.[����-���������]=LI.������� 
				AND (@date BETWEEN OP.������ AND OP.������)
				AND OP.[����-���������]=@��������������  
--��� ����
			LEFT JOIN stack.�������� AS OPD 
				ON OPD.[����-���������]=LI.�������� 
				AND (@date BETWEEN OPD.������ AND OPD.������)
				AND OPD.[����-���������]=@��������������  
			WHERE LI.�����������=3 AND LI.����������=5
		)
   
   UPDATE R
   SET  ������ = INDEX_.������
   FROM #Result AS R
   JOIN INDEX_  ON R.ROW_ID = INDEX_.�������;

   WITH TYPE_STROY
	AS
		(	
		SELECT	
			 LI.�������
			,LI.��������
			,CASE
				WHEN ISNULL(OP.��������,OPD.��������)=0 THEN '���������������'
				WHEN ISNULL(OP.��������,OPD.��������)=1 THEN '�������'
				WHEN ISNULL(OP.��������,OPD.��������)=2 THEN '���������'
				WHEN ISNULL(OP.��������,OPD.��������)=3 THEN '����'
				WHEN ISNULL(OP.��������,OPD.��������)=4 THEN '�����'
				WHEN ISNULL(OP.��������,OPD.��������)=5 THEN '����'
				WHEN ISNULL(OP.��������,OPD.��������)=6 THEN '�����'
				WHEN ISNULL(OP.��������,OPD.��������)=7 THEN '������'
				WHEN ISNULL(OP.��������,OPD.��������)=8 THEN '������ ���������������'
				ELSE '�� ���������'
			 END AS [��� ��������]
		FROM stack.[������� ��������] AS LI
--��� ��
		LEFT JOIN stack.�������� AS OP 
			ON OP.[����-���������]=LI.������� 
			AND (@date BETWEEN OP.������ AND OP.������)
			AND OP.[����-���������]=@�������������������
--��� ����
		LEFT JOIN stack.�������� AS OPD 
			ON OPD.[����-���������]=LI.�������� 
			AND (@date BETWEEN OPD.������ AND OPD.������)
			AND OPD.[����-���������]=@�������������������
		WHERE LI.�����������=3 AND LI.����������=5
		)
   
   UPDATE R
   SET  ����������� = TPS.[��� ��������]
   FROM #Result AS R
   JOIN TYPE_STROY AS TPS  ON R.ROW_ID = TPS.�������;

   WITH PROPISAN
	AS
		(
			SELECT OP.[����-���������] AS �������
					,OP.�������� AS ���������
			FROM stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='����') 
			AND (@date BETWEEN OP.������ AND OP.������)
		)
   
   UPDATE R
   SET  �������� = PR.���������
   FROM #Result  AS R
   JOIN PROPISAN AS PR  ON R.ROW_ID = PR.�������;

   WITH ROOMS
	AS
		(
			SELECT	OP.[����-���������] AS �������
					  ,OP.�������� AS ������
			FROM  stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='�������') 
			AND (@date BETWEEN OP.������ AND OP.������)
		)
   
   UPDATE R
   SET  ������� = RM.������
   FROM #Result AS R
   JOIN ROOMS AS RM  ON R.ROW_ID = RM.�������;

   WITH SQUARE_
	AS
		(
			SELECT OP.[����-���������] AS �������
					,OP.�������� AS �������
			FROM  stack.�������� AS OP 
			WHERE OP.[����-���������]=(
					 SELECT  TOP 1 VP.ROW_ID
					 FROM stack.[���� ����������] AS VP
					 WHERE VP.��������='����������') 
			AND (@date BETWEEN OP.������ AND OP.������)
		)
   
   UPDATE R
   SET  ������� = SQ.�������
   FROM #Result AS R
   JOIN SQUARE_ AS SQ  ON R.ROW_ID = SQ.�������;

   WITH POSTAV_NAME
	AS (
			SELECT LI.�������,
					 ISNULL(ORG.��������,ORG_D.��������) AS [������������ ����������]
			FROM 
				 stack.[������� ��������] AS LI
--��� ��
			LEFT JOIN stack.���������� AS POS
			ON POS.[����-������ �����������]=LI.�������
			LEFT JOIN stack.����������� AS ORG
			ON ORG.ROW_ID=POS.[����������-������]
--��� ����
			LEFT JOIN stack.���������� AS POS_D
			ON POS_D.[����-������ �����������]=LI.��������
			LEFT JOIN stack.����������� AS ORG_D
			ON ORG_D.ROW_ID=POS_D.[����������-������]
			WHERE LI.�����������=3 AND LI.����������=5 AND (@date BETWEEN POS.������ AND POS.������ OR @date BETWEEN POS_D.������ AND POS_D.������)
		)
   UPDATE R
   SET ������������� = PN.[������������ ����������]
   FROM #Result AS R
   JOIN POSTAV_NAME AS PN ON R.ROW_ID = PN.�������;

   SELECT
      *     
   FROM #Result AS LS