WITH DailyCount AS(
    SELECT LogDate,
           DATEPART(dw,LogDate) AS DayOfWeekNum,
           DATENAME(dw,LogDate) AS DayOfWeekName,
           COUNT(DISTINCT CustomerID) AS Total_Daily_Keys
    FROM VW_DRM_BASE
    GROUP BY LogDate
)

SELECT
    DayOfWeekName,
    ROUND(AVG(Total_Daily_Keys * 1.0), 0) AS Avg_Keys,
    MAX(Total_Daily_Keys) AS Max_Keys_Recorded,
    MIN(Total_Daily_Keys) AS Min_Keys_Recorded
FROM DailyCount
GROUP BY DayOfWeekName, DayOfWeekNum
ORDER BY DayOfWeekNum;

