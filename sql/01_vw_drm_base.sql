CREATE VIEW VW_DRM_BASE AS

SELECT CAST(B.DATE as date) as LogDate,
       B.CustomerID,
       'BHD'               as Source
FROM Log_BHD_MovieID B
JOIN MV_PropertiesShowVN M ON B.MovieID = M.MovieId

UNION ALL

SELECT CAST(F.date as date) as LogDate,
       F.CustomerID,
       'Fimplus'            as Source
FROM Log_Fimplus_MovieID F
JOIN MV_PropertiesShowVN M ON F.MovieId = M.MovieId

UNION ALL

SELECT CAST(Date as date)   as LogDate,
       CustomerID,
       'IPTV'               as Source
FROM Log_Get_DRM_List