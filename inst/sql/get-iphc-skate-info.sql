-- SQL code to get IPHC skate INFO from GFBioSQL
-- Adapted by EK from RH SQL code from 2015
-- Last modified: 2018-09-21
-- Extracts data at the skate level (hook level, but rolled up to skate level)

SET NOCOUNT ON -- prevents timeout errors

-- If any of this first call changes then update table in text (currently
--  in Andy's yeye15reproduce repo, will get moved to gfsynopsis)
SELECT
  YEAR(T.TRIP_START_DATE) AS [year],
  FE.TRIP_ID AS tripID,
  FE.FE_MAJOR_LEVEL_ID AS "set",
  SL.setID,
  FE.FE_SUB_LEVEL_ID AS skate,
  FE.FE_PARENT_EVENT_ID AS skateID,
  COALESCE(LBL2012.BAIT_LURE_CODE, LBL.BAIT_LURE_CODE) AS bait,
  COUNT(FE.FE_MINOR_LEVEL_ID) AS HOOKS_PER_SKATE,
  SUM(CASE WHEN HS.HOOK_YIELD_CODE IN (0,7) THEN 0 ELSE 1 END) AS USE_HOOKS_PER_SKATE
FROM FISHING_EVENT FE
	INNER JOIN TRIP T ON FE.TRIP_ID = T.TRIP_ID 
	INNER JOIN TRIP_SURVEY TS ON TS.TRIP_ID = T.TRIP_ID
	INNER JOIN SURVEY S ON  TS.SURVEY_ID = S.SURVEY_ID
	LEFT JOIN
		(SELECT T.TRIP_ID, -- extracting set level bait info from all survey years other than 2012 (bait experiment)
			FE.FE_MAJOR_LEVEL_ID,
			LBL.BAIT_LURE_CODE
		 FROM FISHING_EVENT FE
			INNER JOIN TRIP T ON FE.TRIP_ID = T.TRIP_ID 
			INNER JOIN TRIP_SURVEY TS ON TS.TRIP_ID = T.TRIP_ID
			INNER JOIN SURVEY S ON  TS.SURVEY_ID = S.SURVEY_ID
 			LEFT JOIN LONGLINE_BAIT_LURE LBL ON FE.FISHING_EVENT_ID = LBL.FISHING_EVENT_ID
		 WHERE FE.FE_MINOR_LEVEL_ID Is Null AND 
			S.SURVEY_SERIES_ID IN (14) AND 
			FE.BLOCK_DESIGNATION Is Not Null
		 GROUP BY T.TRIP_ID, 
			FE.FE_MAJOR_LEVEL_ID, 
			LBL.BAIT_LURE_CODE) LBL ON LBL.TRIP_ID = T.TRIP_ID AND LBL.FE_MAJOR_LEVEL_ID = FE.FE_MAJOR_LEVEL_ID
	LEFT JOIN 
		(SELECT --extracting skate level bait info for 2012 survey 
			FE.TRIP_ID, 
			FE.FISHING_EVENT_ID,
			FE.FE_MAJOR_LEVEL_ID, 
			FE.FE_SUB_LEVEL_ID, 
			BAIT_LURE_CODE
		FROM 
			(FISHING_EVENT FE 
			INNER JOIN LONGLINE_SPECS LS ON FE.FISHING_EVENT_ID = LS.FISHING_EVENT_ID) 
			INNER JOIN LONGLINE_BAIT_LURE LBL ON LS.FISHING_EVENT_ID = LBL.FISHING_EVENT_ID
		WHERE
			FE.TRIP_ID IN (73290,73291)) LBL2012 ON LBL2012.TRIP_ID = T.TRIP_ID AND LBL2012.FE_MAJOR_LEVEL_ID = FE.FE_MAJOR_LEVEL_ID AND LBL2012.FE_SUB_LEVEL_ID = FE.FE_SUB_LEVEL_ID
	INNER JOIN HOOK_SPECS HS ON HS.FISHING_EVENT_ID = FE.FISHING_EVENT_ID
	INNER JOIN 
		(SELECT 
			T.TRIP_ID,
			FE.FISHING_EVENT_ID AS setID,
			FE_MAJOR_LEVEL_ID
		FROM FISHING_EVENT FE
			INNER JOIN TRIP T ON FE.TRIP_ID = T.TRIP_ID 
			INNER JOIN TRIP_SURVEY TS ON TS.TRIP_ID = T.TRIP_ID
			INNER JOIN SURVEY S ON S.SURVEY_ID = TS.SURVEY_ID
		WHERE SURVEY_SERIES_ID = '14' AND FE_PARENT_EVENT_ID IS NULL) SL ON SL.TRIP_ID = T.TRIP_ID AND SL.FE_MAJOR_LEVEL_ID = FE.FE_MAJOR_LEVEL_ID
WHERE
  FE.FE_MINOR_LEVEL_ID Is Not Null AND 
  S.SURVEY_SERIES_ID IN (14)
GROUP BY YEAR(T.TRIP_START_DATE),
  FE.TRIP_ID,
  SL.setID,
  FE.FE_PARENT_EVENT_ID,
  FE.FE_MAJOR_LEVEL_ID,
  FE.FE_SUB_LEVEL_ID,
  COALESCE(LBL2012.BAIT_LURE_CODE, LBL.BAIT_LURE_CODE) 
ORDER BY
  Year(T.TRIP_START_DATE),
  FE.TRIP_ID,
  FE.FE_MAJOR_LEVEL_ID,
  FE.FE_SUB_LEVEL_ID
