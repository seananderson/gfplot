SELECT TRIP_START_DATE,
  SM.TRIP_ID,
  SM.GEAR_CODE AS GEAR,
  SM.SPECIES_CODE, 
  SPP.SPECIES_COMMON_NAME, 
  SPP.SPECIES_SCIENCE_NAME, 
  SP.SAMPLE_ID,
  SP.SPECIMEN_ID, 
  SP.SPECIMEN_SEX_CODE AS SEX,
  SPECIMEN_AGE AS AGE,
  CASE WHEN SPECIES_COMMON_NAME = 'NORTH PACIFIC SPINY DOGFISH' AND AGEING_METHOD_CODE = 11 THEN AGEING_METHOD_CODE
  	WHEN SPECIES_COMMON_NAME = 'WALLEYE POLLOCK' AND AGEING_METHOD_CODE = 7 THEN AGEING_METHOD_CODE	
	WHEN SPECIES_COMMON_NAME IN('LINGCOD', 'PACIFIC COD') AND AGEING_METHOD_CODE = 6 THEN AGEING_METHOD_CODE 
  	WHEN SPECIES_COMMON_NAME IN ('SHORTRAKER ROCKFISH', 'SHORTSPINE THORNYHEAD', 'LONGSPINE THORNYHEAD') AND AGEING_METHOD_CODE IN (1, 3, 4, 17) THEN  AGEING_METHOD_CODE
	WHEN SPECIES_COMMON_NAME IN ('BIG SKATE',
	'LONGNOSE SKATE',
	'BASKING SHARK',
	'SALMON SHARK',
	'BROWN CAT SHARK',
	'BLUE SHARK',
	'PACIFIC SLEEPER SHARK',
	'ALEUTIAN SKATE',
	'ABYSSAL SKATE',
	'BROAD SKATE',
	'ROUGHTAIL SKATE',
	'SANDPAPER SKATE') AND AGEING_METHOD_CODE = 12 THEN AGEING_METHOD_CODE
	WHEN SPECIES_COMMON_NAME IN ('PACIFIC HAKE', 
	'ROUGHEYE/BLACKSPOTTED ROCKFISH COMPLEX', 
	'PACIFIC OCEAN PERCH',
	'REDBANDED ROCKFISH',
	'SILVERGRAY ROCKFISH',
	'COPPER ROCKFISH',
	'DARKBLOTCHED ROCKFISH',
	'WIDOW ROCKFISH',
	'YELLOWTAIL ROCKFISH',
	'QUILLBACK ROCKFISH',
	'BOCACCIO',	
	'CANARY ROCKFISH',
	'REDSTRIPE ROCKFISH',
	'YELLOWMOUTH ROCKFISH',
	'YELLOWEYE ROCKFISH',
	'SABLEFISH',
	'ARROWTOOTH FLOUNDER',
	'PETRALE SOLE',
	'REX SOLE',
	'SOUTHERN ROCK SOLE',
	'DOVER SOLE',
	'ENGLISH SOLE') AND AGEING_METHOD_CODE IN (1, 3, 17) THEN AGEING_METHOD_CODE END AS AGEING_METHOD,
  CAST(ROUND(Best_Length / 10.0, 1) AS DECIMAL(8,1)) AS LENGTH,
  ROUND_WEIGHT AS WEIGHT,
  SP.MATURITY_CODE, 
  SM.MATURITY_CONVENTION_CODE,
  MC.MATURITY_CONVENTION_DESC,
  TRIP_SUB_TYPE_CODE, 
  SM.SAMPLE_TYPE_CODE, 
  SM.SPECIES_CATEGORY_CODE,
  SM.SAMPLE_SOURCE_CODE,
  SM.CATCH_WEIGHT, 
  SM.CATCH_COUNT,
  SM.MAJOR_STAT_AREA_CODE,
  MAJOR_STAT_AREA_NAME,
  SM.MINOR_STAT_AREA_CODE,
  CASE WHEN SM.GEAR_CODE IN (1, 6, 11) THEN ISNULL(TRSP.USABILITY_CODE, 0)
  WHEN SM.GEAR_CODE IN (2) THEN ISNULL(TPSP.USABILITY_CODE, 0)
  WHEN SM.GEAR_CODE IN (5) THEN ISNULL(LLSP.USABILITY_CODE, 0)
  WHEN SM.GEAR_CODE IN (4) THEN ISNULL(HLSP.USABILITY_CODE, 0)
  ELSE 0 END AS USABILITY_CODE,
  CASE WHEN SPECIES_CATEGORY_CODE IN (1, 5, 6, 7) AND (SAMPLE_SOURCE_CODE IS NULL OR SAMPLE_SOURCE_CODE = 1) 
		THEN 'UNSORTED'
	WHEN SPECIES_CATEGORY_CODE = 1 AND SAMPLE_SOURCE_CODE = 2 
		THEN 'KEEPERS'
	WHEN SPECIES_CATEGORY_CODE = 3 AND SAMPLE_SOURCE_CODE = 1 
		THEN 'TBD'
	WHEN SPECIES_CATEGORY_CODE = 3 AND (SAMPLE_SOURCE_CODE IS NULL OR SAMPLE_SOURCE_CODE = 2) 
		THEN 'KEEPERS'
	END AS SAMPLING_DESC
FROM GFBioSQL.dbo.B21_Samples SM
	INNER JOIN GFBioSQL.dbo.B22_Specimens SP ON SM.SAMPLE_ID = SP.SAMPLE_ID
	INNER JOIN GFBioSQL.dbo.SPECIES SPP ON SPP.SPECIES_CODE = SM.SPECIES_CODE
	INNER JOIN GFBioSQL.dbo.Maturity_Convention MC ON SM.MATURITY_CONVENTION_CODE = MC.MATURITY_CONVENTION_CODE
	INNER JOIN GFBioSQL.dbo.FISHING_EVENT FE ON FE.FISHING_EVENT_ID = SM.FISHING_EVENT_ID
	INNER JOIN GFBioSQL.dbo.MAJOR_STAT_AREA MSA ON SM.MAJOR_STAT_AREA_CODE = MSA.MAJOR_STAT_AREA_CODE
	LEFT OUTER JOIN GFBioSQL.dbo.MATURITY_DESCRIPTION MD ON SM.MATURITY_CONVENTION_CODE = MD.MATURITY_CONVENTION_CODE 
	  AND SP.MATURITY_CODE = MD.MATURITY_CODE AND SP.SPECIMEN_SEX_CODE = MD.SPECIMEN_SEX_CODE
    LEFT JOIN GFBioSQL.dbo.TRAWL_SPECS TRSP ON TRSP.FISHING_EVENT_ID = SM.FISHING_EVENT_ID
    LEFT JOIN GFBioSQL.dbo.TRAP_SPECS TPSP ON TPSP.FISHING_EVENT_ID = SM.FISHING_EVENT_ID
    LEFT JOIN GFBioSQL.dbo.LONGLINE_SPECS LLSP ON LLSP.FISHING_EVENT_ID = SM.FISHING_EVENT_ID
    LEFT JOIN GFBioSQL.dbo.HANDLINE_SPECS HLSP ON HLSP.FISHING_EVENT_ID = SM.FISHING_EVENT_ID
WHERE TRIP_SUB_TYPE_CODE NOT IN (2, 3) AND
  SM.SAMPLE_TYPE_CODE IN (1,2,6,7,8) AND
  (SPECIES_CATEGORY_CODE IS NULL OR SPECIES_CATEGORY_CODE IN (1, 3, 5, 6, 7)) AND
  (SAMPLE_SOURCE_CODE IS NULL OR SAMPLE_SOURCE_CODE IN(1, 2)) AND
  (SP.MATURITY_CODE <= MC.MATURITY_CONVENTION_MAXVALUE OR SP.MATURITY_CODE IS NULL)
-- insert species here
ORDER BY SAMPLING_DESC,  
YEAR(TRIP_START_DATE)

