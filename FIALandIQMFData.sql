--產出財稅中心資料，每7萬筆一個檔
SELECT  FORMAT(RowNumber + 100000, '00000000000000') + 'EL1070' + IDCard 
FROM
	(SELECT ROW_NUMBER() OVER (ORDER BY ID.[IDCard]) as RowNumber, UPPER(ID.[IDCard]) as IDCard FROM
		(SELECT [同戶IDCard] AS 'IDCard' FROM [dbo].[coa_d03_10405]
			UNION
		SELECT [IDCard] AS 'IDCard' FROM [dbo].[InsureUserProfile] --保戶身分證
			UNION
		SELECT [HouseKingIDCard] FROM [dbo].[InsureUserProfile] --戶長身分證
			UNION
		SELECT [LandIDCard] FROM [dbo].[Land] --地主身分證
			UNION
		SELECT [INQ_KEY] FROM [dbo].[IQMFData]) AS ID
	WHERE IDCard LIKE '[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') AS T
WHERE [RowNumber] BETWEEN 1 AND 70000 --若資料不分檔，可不必加此句
