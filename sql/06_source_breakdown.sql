SELECT LogDate,
       COUNT(DISTINCT CASE WHEN Source='BHD' THEN CustomerID END ) AS BHD_Keys,
       COUNT(DISTINCT CASE WHEN Source='Fimplus' THEN CustomerID END ) AS Fimplus_Keys,
       COUNT(DISTINCT CASE WHEN Source='IPTV' THEN CustomerID END ) AS IPTV_Keys,
       COUNT(DISTINCT CustomerID) AS Total_Daily_Keys
FROM VW_DRM_BASE
GROUP BY LogDate
