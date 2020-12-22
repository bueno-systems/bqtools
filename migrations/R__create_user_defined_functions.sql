 CREATE OR REPLACE FUNCTION `bqtools.getOperatingHours`(
  `ts` TIMESTAMP,
  `tz` STRING,
  `hours` STRUCT<
    monday STRUCT<`start` TIME, `end` TIME>,
    tuesday STRUCT<`start` TIME, `end` TIME>,
    wednesday STRUCT<`start` TIME, `end` TIME>,
    thursday STRUCT<`start` TIME, `end` TIME>,
    friday STRUCT<`start` TIME, `end` TIME>,
    saturday STRUCT<`start` TIME, `end` TIME>,
    sunday STRUCT<`start` TIME, `end` TIME>
  >
) RETURNS STRUCT<`start` TIME, `end` TIME> AS (
  CASE FORMAT_TIMESTAMP("%u", `ts`, `tz`)
    WHEN "1" THEN `hours`.`monday`
    WHEN "2" THEN `hours`.`tuesday`
    WHEN "3" THEN `hours`.`wednesday`
    WHEN "4" THEN `hours`.`thursday`
    WHEN "5" THEN `hours`.`friday`
    WHEN "6" THEN `hours`.`saturday`
    WHEN "7" THEN `hours`.`sunday`
  END
);

 CREATE OR REPLACE FUNCTION `bqtools.inOperatingHours`(
  `ts` TIMESTAMP,
  `tz` STRING,
  `hours` STRUCT<
    monday STRUCT<`start` TIME, `end` TIME>,
    tuesday STRUCT<`start` TIME, `end` TIME>,
    wednesday STRUCT<`start` TIME, `end` TIME>,
    thursday STRUCT<`start` TIME, `end` TIME>,
    friday STRUCT<`start` TIME, `end` TIME>,
    saturday STRUCT<`start` TIME, `end` TIME>,
    sunday STRUCT<`start` TIME, `end` TIME>
  >
) RETURNS BOOL AS (
  TIME(`ts`, `tz`) >= `bqtools.getOperatingHours`(`ts`, `tz`,  `hours`).`start`
    AND
  TIME(`ts`, `tz`) < `bqtools.getOperatingHours`(`ts`, `tz`, `hours`).`end`
);

 CREATE OR REPLACE FUNCTION `bqtools.notInOperatingHours`(
  `ts` TIMESTAMP,
  `tz` STRING,
  `hours` STRUCT<
    monday STRUCT<`start` TIME, `end` TIME>,
    tuesday STRUCT<`start` TIME, `end` TIME>,
    wednesday STRUCT<`start` TIME, `end` TIME>,
    thursday STRUCT<`start` TIME, `end` TIME>,
    friday STRUCT<`start` TIME, `end` TIME>,
    saturday STRUCT<`start` TIME, `end` TIME>,
    sunday STRUCT<`start` TIME, `end` TIME>
  >
) RETURNS BOOL AS (
  (TIME(`ts`, `tz`) >= TIME(00, 00, 00) AND TIME(`ts`, `tz`) < `bqtools.getOperatingHours`(`ts`, `tz`, `hours`).`start`)
    OR
  (TIME(`ts`, `tz`) >= `bqtools.getOperatingHours`(`ts`, `tz`, `hours`).`end` AND TIME(`ts`, `tz`) <= TIME(23, 59, 59))
);

 CREATE OR REPLACE FUNCTION `bqtools.timeInHours`(
  `time` TIME,
  `hours` STRUCT<`start` TIME, `end` TIME>
) RETURNS BOOL AS (
  `time` >= `hours`.`start`
    AND
  `time` < `hours`.`end`
);

CREATE OR REPLACE FUNCTION `bqtools.timeNotInHours`(
  `time` TIME,
  `hours` STRUCT<`start` TIME, `end` TIME>
) RETURNS BOOL AS (
  (`time` >= TIME(00, 00, 00) AND `time` < `hours`.`start`)
    OR
  (`time` >= `hours`.`end` AND `time` <= TIME(23, 59, 59))
);

CREATE OR REPLACE FUNCTION `bqtools.getEventualOperatingHours`(
  `ts` TIMESTAMP,
  `tz` STRING,
  `siteHours` STRUCT<
    monday STRUCT<`start` TIME, `end` TIME>,
    tuesday STRUCT<`start` TIME, `end` TIME>,
    wednesday STRUCT<`start` TIME, `end` TIME>,
    thursday STRUCT<`start` TIME, `end` TIME>,
    friday STRUCT<`start` TIME, `end` TIME>,
    saturday STRUCT<`start` TIME, `end` TIME>,
    sunday STRUCT<`start` TIME, `end` TIME>
  >,
  `equipHours` STRUCT<
    monday STRUCT<`start` TIME, `end` TIME>,
    tuesday STRUCT<`start` TIME, `end` TIME>,
    wednesday STRUCT<`start` TIME, `end` TIME>,
    thursday STRUCT<`start` TIME, `end` TIME>,
    friday STRUCT<`start` TIME, `end` TIME>,
    saturday STRUCT<`start` TIME, `end` TIME>,
    sunday STRUCT<`start` TIME, `end` TIME>
  >
) RETURNS STRUCT<`start` TIME, `end` TIME> AS (
  CASE
    WHEN `bqtools.getOperatingHours`(`ts`, `tz`, `equipHours`) IS NOT NULL
      THEN `bqtools.getOperatingHours`(`ts`, `tz`, `equipHours`)
    WHEN `bqtools.getOperatingHours`(`ts`, `tz`, `siteHours`) IS NOT NULL
      THEN `bqtools.getOperatingHours`(`ts`, `tz`, `siteHours`)
    ELSE
      STRUCT(TIME(06, 00, 00), TIME(19, 00, 00))
  END
);


CREATE OR REPLACE FUNCTION `bqtools.includes`(
  `tags` ARRAY<STRING>,
  `inList` ARRAY<STRING>
) RETURNS BOOL
LANGUAGE js AS """
  return tags.every(tag => inList.includes(tag))
""";

CREATE OR REPLACE FUNCTION `bqtools.excludes`(
  `tags` ARRAY<STRING>,
  `inList` ARRAY<STRING>
) RETURNS BOOL
LANGUAGE js AS """
  return !tags.some(tag => inList.includes(tag))
""";

CREATE OR REPLACE FUNCTION `bqtools.isMdaMeter`(
  `equipTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `bqtools.includes`(['meter', 'mda', 'siteMeter'], `equipTags`)
);

CREATE OR REPLACE FUNCTION `bqtools.isSolarMeter`(
  `equipTags` ARRAY<STRING>,
  `equipTotalMeterType` STRING
) RETURNS BOOL AS (
  `bqtools.includes`(['meter'], `equipTags`) AND `equipTotalMeterType` = 'SOLAR'
);

CREATE OR REPLACE FUNCTION `bqtools.isEnergyPoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `bqtools.includes`(['cleaned', 'energy', 'intervalHistory', 'processedData'], `pointTags`)
);

CREATE OR REPLACE FUNCTION `bqtools.isPowerPoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `bqtools.includes`(['power', 'sensor'], `pointTags`)
);

CREATE OR REPLACE FUNCTION `bqtools.isPerformancePoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `bqtools.includes`(['pf', 'sensor'], `pointTags`)
);

CREATE OR REPLACE FUNCTION `bqtools.cleanTags`(
  `tags` ARRAY<STRING>
) RETURNS ARRAY<STRING>
LANGUAGE js AS """
  const keep = [
    'his','sensor','intervalHistory','energy','raw','reactiveEnergy','cleaned','apparentPower',
    'reactivePower','pf','power','meterQuality','kwh','kvarh','decommissioned','lowUsage','cumulative',
    'performanceMeter','meter','elec','mda','siteMeter','equip','crucialMeter','noUsage',
    'alarmIssueMeter','highTemp','mediumTemp','lowTemp','virtualMeter'
  ]
  return tags.filter(tag => keep.includes(tag))
""";
