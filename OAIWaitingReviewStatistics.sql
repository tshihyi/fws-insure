/**MS SQL-統計2018-10-01 ~ 2019-03-20以前職保所有待審投保人數統計**/
SELECT F.[Name], COUNT(I.[InsureUserProfileID]) as Total --待審人數統計
  FROM [dbo].[OccupationalInjuryInsure] I --職保保戶資料表主檔
  inner join [dbo].[InsureUserProfile] P on I.[InsureUserProfileID] = P.[ID] and P.[IsDelete] = 0 --所有保戶資料表主檔且保戶未被刪除
  inner join [dbo].[FarmerOrg] F on P.[FarmerOrgID] = F.[ID] and F.[ID] != 287 --農會資料主檔，排除凌誠農會
  WHERE I.[ReviewResult] = 0 --待審
  AND I.[ApplyDate] >= '2018-10-01' 
  AND I.[ApplyDate] <= '2019-03-20'
  GROUP BY F.[Name] --GROUP欄位須與SELECT的欄位相同
  ORDER BY Total DESC
