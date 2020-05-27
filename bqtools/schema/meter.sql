CREATE TABLE IF NOT EXISTS `{{ project_id }}.{{ dataset_id }}.meter`
(
  `date` DATE NOT NULL,
  `time` TIME NOT NULL,
  `hours` STRUCT<`start` TIME NOT NULL, `end` TIME NOT NULL> NOT NULL,
  `num_value` FLOAT64,
  `project_key` STRING NOT NULL,
  `site_id` STRING NOT NULL,
  `site_name` STRING,
  `equip_id` STRING NOT NULL,
  `equip_name` STRING,
  `equip_tags` ARRAY<STRING>,
  `equip_props` STRUCT<
    `nmi` STRING,
    `meterId` STRING,
    `subMeterType` STRING,
    `hisRollupFunc` STRING,
    `minFlow` FLOAT64,
    `maxFlow` FLOAT64,
    `slowSync` STRING,
    `fireText` STRING,
    `fireGroupNr` STRING,
    `fireSensorType` STRING,
    `fireLoopNr` STRING,
    `fireDeviceNr` STRING,
    `fireZoneNr` STRING,
    `filterPressureSP` FLOAT64,
    `maxDefrostCycles` FLOAT64,
    `oaLockoutTemp` FLOAT64,
    `refrigerantType` STRING,
    `totalMeterType` STRING,
    `reliefFanPair` STRING,
    `ahuMaxDischargePressure` FLOAT64,
    `ahuMinDischargePressure` FLOAT64,
    `moaOverwrite` FLOAT64,
    `oaLockoutSP` FLOAT64,
    `condenserApproachTemp` FLOAT64,
    `evaporatorApproachTemp` FLOAT64,
    `minCDWTemp` FLOAT64,
    `minCHWDPSP` FLOAT64,
    `minCDWDPSP` FLOAT64,
    `minHHWDPSP` FLOAT64,
    `minStaticPressure` FLOAT64,
    `pressureCorrectionFactor` FLOAT64,
    `upperTempLimit` FLOAT64,
    `lowerTempLimit` FLOAT64,
    `deadbandLower` FLOAT64,
    `deadbandUpper` FLOAT64,
    `zonePair` STRING,
    `minCO2Sp` FLOAT64,
    `maxCO2Sp` FLOAT64,
    `maxConcurrentCtOperation` FLOAT64,
    `meterManager` STRING,
    `minFrequency` FLOAT64,
    `solarCapacity` FLOAT64,
    `add` STRING,
    `subtract` STRING,
    `meterSlowSync` FLOAT64,
    `spValue` FLOAT64,
    `submeterOf` STRING,
    `minSpeed` FLOAT64,
    `hisMode` STRING
  >,
  `point_id` STRING NOT NULL,
  `point_name` STRING,
  `point_unit` STRING NOT NULL,
  `point_tags` ARRAY<STRING>,
  `point_decommissioned` BOOLEAN NOT NULL
)
PARTITION BY `date`
CLUSTER BY `date`, `project_key`, `site_id`
OPTIONS (
  description="All historical data tagged as meter"
);
