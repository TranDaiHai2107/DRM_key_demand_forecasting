SELECT LogDate,
       COUNT(DISTINCT CustomerID) AS Total_Daily_Keys
FROM VW_DRM_BASE
GROUP BY LogDate
ORDER BY LogDate;