/**系統所有職保潛在保戶**/

SELECT 
	P.[Name] AS '姓名', 
	P.[IDCard] AS '身分證字號',
	(CASE WHEN P.[Birthday] = '1753-01-01' THEN '' ELSE P.[Birthday] END)AS '出生日期',
	(CASE WHEN P.[Birthday] is null or P.[Birthday] = '1753-01-01' THEN '' ELSE (2019 - YEAR(P.[Birthday])) END) as '年齡',
	(SELECT left(T.[TEL],len(T.[TEL])-1) from 
	(SELECT (SELECT [TEL] + ',' from [dbo].[InsureUserTel] WHERE InsureUserProfileID = P.ID and [TEL] NOT LIKE '09%' and [TEL] <> '' and [TEL] is not null FOR XML PATH('')) as [TEL]) T) as '市話',
	(SELECT left(T.[TEL],len(T.[TEL])-1) from 
	(SELECT (SELECT [TEL] + ',' from [dbo].[InsureUserTel] WHERE InsureUserProfileID = P.ID and [TEL] LIKE '09%' and [TEL] <> '' and [TEL] is not null FOR XML PATH('')) as [TEL]) T) as '行動電話',
	(CASE P.[MemberType] WHEN 0 THEN '非會員' ELSE '會員' END) +
	(CASE P.[QualificationID]
		 WHEN 'A' THEN '自耕農'
		 WHEN 'B' THEN '佃農'
		 WHEN 'C' THEN '雇農'
		 WHEN 'D' THEN '配偶'
         WHEN 'J' THEN '自耕農'
		 WHEN 'K' THEN '佃農'
		 WHEN 'L' THEN '雇農'
		 WHEN 'M' THEN '農業推廣工作者'
		 WHEN 'N' THEN '農林牧場員工從事農作者'
		 WHEN 'E' THEN '蜂農'
		 WHEN 'F' THEN '實耕者'
         ELSE '' END) AS '資格別',
	(CASE P.[FarmInsureStatus] WHEN 0 THEN '退保' WHEN 1 THEN '投保' ELSE '' END) AS '農保',
	(CASE I.[ReviewResult] WHEN 0 THEN '待審' WHEN 1 THEN '通過' ELSE '' END) AS '職保',
	(CASE P.[HealthInsureStatus] WHEN 0 THEN '退保' WHEN 1 THEN '投保' ELSE '' END) AS '健保',
	(CASE WHEN A.[ID] IS NOT NULL THEN '是' ELSE '否' END) AS '異常',
	(CASE WHEN N.[ID] is NOT NULL THEN '是' ELSE '否' END) as '補正通知',
	O.[Name] AS '農會名稱'
FROM [InsureUserProfile] P
	JOIN [dbo].[FarmerOrg] O on P.[FarmerOrgID] = O.[ID] --農會資料主檔
	LEFT JOIN [OccupationalInjuryInsure] I on P.[ID]= I.[InsureUserProfileID] --職保資料檔
	LEFT JOIN [dbo].[FarmInsureAbnormalLog] A on P.[ID] = A.[InsureUserProfileID] AND A.StatEnum = 0 --未處理異常
	LEFT JOIN 
	(SELECT N.[ID], N.[InsureUserProfileID],[CheckStatus] FROM [dbo].[Inventory] N 
		JOIN [dbo].[InventoryReasonSetting] R ON N.[ReasonID] = R.[ID] and R.[IsDelete] = 0 and R.[IsFillCheck] = 1
	 where N.[CheckStatus] in (2, 3)
	) N on N.[InsureUserProfileID] = P.[ID] --未處理補正
WHERE  P.[FarmInsureStatus] = 1
	AND P.[IsDelete] = 0
	AND P.[FarmerOrgID] != 287
	AND A.[ID] IS NULL --無異常
	AND N.[ID] IS NULL --無補正
	AND (I.[InsureUserProfileID] IS NULL OR I.[ReviewResult] = 0) --排除職保退保，加入投保中但待審
ORDER BY P.[IDCard], O.[Name]
