	SELECT I.[Name] AS '姓名', I.[IDCard] AS '身分證', I.[Birthday] AS '出生日期', 
		CASE I.[MemberType] WHEN 1 THEN '會員' ELSE '非會員' END +
		CASE I.[QualificationID] 
			WHEN 'A' THEN '自耕農'
		    WHEN 'B' THEN '佃農'
            WHEN 'C' THEN '雇農'
		    WHEN 'D' THEN '配偶'
		    WHEN 'E' THEN '蜂農'
		    WHEN 'F' THEN '實耕者'
	        WHEN 'J' THEN '自耕農'
		    WHEN 'K' THEN '佃農'
		    WHEN 'L' THEN '雇農'
		    WHEN 'M' THEN '農業推廣工作者'
		    WHEN 'N' THEN '農林牧場員工'
		    ELSE ISNULL(I.[QualificationID], '') END AS '資格別', 
	   CASE I.[FarmInsureStatus] WHEN 0 THEN '退保' WHEN 1 THEN '投保' ELSE '' END AS '農保',
	   CASE OI.[InsureStatus] WHEN 0 THEN '退保' WHEN 1 THEN '投保' ELSE '' END AS '職保',
	   CASE I.[HealthInsureStatus] WHEN 0 THEN '退保' WHEN 1 THEN '投保' ELSE '' END AS '健保',
	   CASE A.[Stat]
	        WHEN '已處理' THEN '否'
	        WHEN '未處理' THEN '是'
		    ELSE ISNULL(A.[Stat], '否') END AS '異常',
	   CASE WHEN N.[ID] IS NOT NULL THEN '是' ELSE '否' END AS '補正通知',
	   CASE I.[CheckResult] WHEN 0 THEN '不通過' ELSE '待審' END AS '審核結果',
       O.[Name] AS '所屬農會'
    FROM [dbo].[InsureUserProfile] I
		  JOIN [dbo].[HealthInsure] H ON I.ID = H.InsureUserProfileID 
		  AND H.[IsDelete] = 0 --有效保戶
		  AND H.[InsureStatus] = 1 --健保在保中
		  AND  H.[InsurerTitle] = '本人' --主保人
		  JOIN [dbo].[FarmerOrg] O ON I.[FarmerOrgID] = O.ID --農會資料主檔
		  LEFT JOIN [dbo].[OccupationalInjuryInsure] OI ON I.[ID] = OI.[InsureUserProfileID] --職保投保主檔
		  LEFT JOIN [dbo].[FarmInsureAbnormalLog] A ON I.[ID] = A.[InsureUserProfileID] --農保異常記錄表
		  LEFT JOIN 
		       (SELECT N.[ID], N.[InsureUserProfileID], N.[CheckStatus]
				 FROM [dbo].[Inventory] N --補正記錄主檔
				 JOIN [dbo].[InventoryReasonSetting] R ON N.[ReasonID] = R.[ID] AND R.[IsDelete] = 0 AND R.[IsFillCheck] = 1 --補正原因檔且已審核
				 WHERE N.[CheckStatus] IN (2, 3) --審核狀態(0:補正完成 1:送審中 2:退回重新補正 3:未補正)
				)N ON N.[InsureUserProfileID] = I.[ID]
		  AND A.[StatEnum] = 0 --未處理異常
	WHERE I.[FarmInsureStatus] != 1
	  AND I.[IsDelete] = 0
	  AND I.[FarmerOrgID] != 287
	  GROUP BY I.[IDCard], I.[Name], I.[Birthday], I.[MemberType], I.[QualificationID],
	           I.[FarmInsureStatus], OI.[InsureStatus], I.[HealthInsureStatus],
			   A.[Stat], N.[ID], I.[CheckResult],  O.[Name]
	  ORDER BY I.[IDCard]
	
