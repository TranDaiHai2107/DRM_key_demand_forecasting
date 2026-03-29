WITH DailyCount AS(
    SELECT LogDate,
       COUNT(DISTINCT CustomerID) AS Total_Daily_Keys
    FROM VW_DRM_BASE
    GROUP BY LogDate
),
TrendAnalysis AS (
    SELECT LogDate,
           Total_Daily_Keys,
           -- Moving Averages
           AVG(Total_Daily_Keys*1.0) OVER (ORDER BY LogDate ROWS BETWEEN 6 PRECEDING and CURRENT ROW ) AS MA_7_days,
           AVG(Total_Daily_Keys*1.0) OVER (ORDER BY LogDate ROWS BETWEEN 29 PRECEDING and CURRENT ROW ) AS MA_30_days,
           --Take 7 days ago to compare
           LAG(Total_Daily_Keys,7) OVER ( ORDER BY LogDate) AS Keys_Last_week
    FROM DailyCount
)
SELECT LogDate,
       Total_Daily_Keys,
       CAST(ROUND(MA_7_days,1) AS DECIMAL(10,2)) AS MA_7_Days,
       CAST(ROUND(MA_30_days,1) AS DECIMAL(10,2)) AS MA_30_Days,
        -- Growth Percentage WoW--
       CAST(ROUND(((Total_Daily_Keys * 1.0 / NULLIF(Keys_Last_Week, 0)) - 1) * 100, 2) AS DECIMAL(10,2)) AS WoW_Growth_Pct
FROM TrendAnalysis


