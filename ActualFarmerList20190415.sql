 /**2019-04-15實耕者名冊**/
 SELECT A.[NAME] AS '實耕者姓名', A.[IDCard] AS '身分證字號', 
	(CASE A.[IdentityType] 
	 WHEN 1 THEN '百大青年農民 '
	 WHEN 2 THEN '青年農民聯誼會成員'
	 WHEN 3 THEN '通過四章一Q驗證之農民或通過友善環境認證之農民' ELSE '配合其他政策之農民' END)AS '身分別',
	(CASE P.[FarmInsureStatus] WHEN 1 THEN '投保' WHEN 0 THEN '退保' ELSE '' END) AS '農保',
	(CASE OI.[InsureStatus] WHEN  1 THEN '投保' WHEN 0 THEN '退保'ELSE '' END)AS '職保',
	(CASE P.[HealthInsureStatus] WHEN 1 THEN '投保' WHEN 0 THEN '退保' ELSE '' END)AS '健保',
	(CASE WHEN AFA.[ID] IS NOT NULL THEN '是' ELSE '否' END) AS '異常',
	A.[ApplyDate] AS '申請日期',
	A.[Tel] AS '聯絡電話',
	A.[CellPhone] AS '行動電話',
	(CASE WHEN A.WhichAddress = 0 THEN A.[HouseAddress] ELSE S.County+S.Town+S.Village+A.[LastAddress] END) AS '戶籍地址',
	(CASE WHEN A.CommWhichAddress = 0 THEN A.[CommAddress] ELSE S.County+S.Town+S.Village+A.[CommLastAddress] END) AS '通訊地址',
	A.[QualificationCertNo] AS '核發公文文號',
	A.[QualificationCertEndDate] AS '資格證明到期日',
	D.[Name] AS '所屬改良場',
	O.[Name] AS '所屬農會',
	(CASE WHEN C.[Note] IS NULL THEN CT.[Name] ELSE CT.[Name] + '-' + C.[Note] END) AS '栽培作物'
 FROM  [ActualFarmer] A --保戶資料主檔
	 JOIN [InsureUserProfile] P on P.[ActualFarmerID] = A.[ID] AND P.[IsDelete] = 0 --實耕者主檔，且保戶資料未被刪除
	 JOIN [FarmerOrg] O on P.[FarmerOrgID] = O.[ID] AND P.[FarmerOrgID] != 287 --農會資料主檔，排除凌誠農會
	 JOIN [Dares] D ON A.[DaresID] = D.[ID] --改良場資料主檔
	 LEFT JOIN [AddressInfo] S ON A.TownCode = S.TownCode AND A.CountyCode = S.CountyCode AND A.VillageCode = S.VillageCode --戶籍地址
	 LEFT JOIN [AddressInfo] R ON A.CommCountyCode = R.CountyCode AND A.CommTownCode = R.TownCode AND A.CommVillageCode = R.VillageCode --通訊地址
	 LEFT JOIN [OccupationalInjuryInsure] OI ON  P.[ID] = OI.[InsureUserProfileID] --職災投保
	 LEFT JOIN [FarmInsureAbnormalLog] FA ON A.[ID] = FA.[InsureUserProfileID] and FA.[StatEnum] = 0 --農保資格異常未處理
	 LEFT JOIN [ActualFarmerAbnormalLog] AFA ON A.[ID] = AFA.[ActualFarmerID] AND AFA.[StatEnum] = 0 --實耕者異常未處理
	 LEFT JOIN [ActualFarmerCrop] C ON A.[ID] = C.[ActualFarmerID] --實耕者作物
	 LEFT JOIN [CropType] CT ON C.[CropTypeID] = CT.[ID] --實耕者作物資料檔
 ORDER BY A.[IDCard] ASC
