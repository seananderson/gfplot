SELECT YEAR(BEST_DATE) AS YEAR,
	VESSEL_NAME,
	VESSEL_REGISTRATION_NUMBER,
	FISHERY_SECTOR,
	TRIP_ID,
	FISHING_EVENT_ID,
	FE_START_DATE,
	FE_END_DATE,
	SP.SPECIES_CODE,
	SPECIES_COMMON_NAME,
	GEAR,
	BEST_DEPTH,
	MAJOR_STAT_AREA_CODE,
	LOCALITY_CODE,
	LATITUDE,
	LONGITUDE,
	ISNULL(LANDED_KG, 0) AS LANDED_KG,
	ISNULL(DISCARDED_KG, 0) AS DISCARDED_KG
FROM GFFOS.dbo.GF_MERGED_CATCH C
LEFT JOIN GFFOS.dbo.SPECIES SP ON SP.SPECIES_CODE = C.SPECIES_CODE
	WHERE FE_START_DATE IS NOT NULL AND
-- insert filters here
	FE_END_DATE IS NOT NULL