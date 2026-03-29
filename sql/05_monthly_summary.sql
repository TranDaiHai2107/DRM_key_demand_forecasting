WITH DailyCount AS(
    SELECT LogDate,
           COUNT(DISTINCT CustomerID) AS Total_Daily_Keys
    FROM VW_DRM_BASE
    GROUP BY LogDate
),
MonthLyCount AS(
    SELECT YEAR(LogDate) AS Year,
           MONTH(LogDate) AS Month,
           SUM(Total_Daily_Keys) AS Total_Monthly_Keys,
           MAX(Total_Daily_Keys) AS Max_Daily_keys,
           MIN(Total_Daily_Keys) AS Min_Daily_keys
    FROM DailyCount
    Group By YEAR(LogDate), MONTH(LogDate)
)

SELECT Year,
       Month,
       Total_Monthly_Keys,
       Max_Daily_keys,
       Min_Daily_keys,
       LAG(Total_Monthly_Keys,1) OVER ( ORDER BY Year,Month) AS Prev_Month_Keys,
       ROUND(((Total_Monthly_Keys * 1.0 / NULLIF(LAG(Total_Monthly_Keys, 1) OVER (ORDER BY Year, Month), 0)) - 1) * 100, 2) AS MoM_Growth_Pct
FROM MonthLyCount
