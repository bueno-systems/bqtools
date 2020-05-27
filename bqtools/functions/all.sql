 -- Retrieves operating hours of the weekday.
 CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(
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

-- Checks if the timestamp is within the operating hours.
 CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.inOperatingHours`(
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
  TIME(`ts`, `tz`) >= `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`,  `hours`).`start`
    AND
  TIME(`ts`, `tz`) < `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `hours`).`end`
);

-- Checks if the timestamp is outside the operating hours.
 CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.notInOperatingHours`(
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
  (TIME(`ts`, `tz`) >= TIME(00, 00, 00) AND TIME(`ts`, `tz`) < `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `hours`).`start`)
    OR
  (TIME(`ts`, `tz`) >= `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `hours`).`end` AND TIME(`ts`, `tz`) <= TIME(23, 59, 59))
);

-- Checks if the timestamp is within the operating hours.
 CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.timeInHours`(
  `time` TIME,
  `hours` STRUCT<`start` TIME, `end` TIME>
) RETURNS BOOL AS (
  `time` >= `hours`.`start`
    AND
  `time` < `hours`.`end`
);

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.timeNotInHours`(
  `time` TIME,
  `hours` STRUCT<`start` TIME, `end` TIME>
) RETURNS BOOL AS (
  (`time` >= TIME(00, 00, 00) AND `time` < `hours`.`start`)
    OR
  (`time` >= `hours`.`end` AND `time` <= TIME(23, 59, 59))
);

-- Retrieves operating hours of the weekday, considering equip hours, site hours and default operating hours respectively.
CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.getEventualOperatingHours`(
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
    WHEN `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `equipHours`) IS NOT NULL
      THEN `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `equipHours`)
    WHEN `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `siteHours`) IS NOT NULL
      THEN `{{ project_id }}.{{ dataset_id }}.getOperatingHours`(`ts`, `tz`, `siteHours`)
    ELSE
      STRUCT(TIME(06, 00, 00), TIME(19, 00, 00))
  END
);


CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.includes`(
  `tags` ARRAY<STRING>,
  `inList` ARRAY<STRING>
) RETURNS BOOL
LANGUAGE js AS """
  return tags.every(tag => inList.includes(tag))
""";

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.excludes`(
  `tags` ARRAY<STRING>,
  `inList` ARRAY<STRING>
) RETURNS BOOL
LANGUAGE js AS """
  return !tags.some(tag => inList.includes(tag))
""";

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.isMdaMeter`(
  `equipTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `{{ project_id }}.{{ dataset_id }}.includes`(['meter', 'mda', 'siteMeter'], `equipTags`)
);

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.isSolarMeter`(
  `equipTags` ARRAY<STRING>,
  `equipTotalMeterType` STRING
) RETURNS BOOL AS (
  `{{ project_id }}.{{ dataset_id }}.includes`(['meter'], `equipTags`) AND `equipTotalMeterType` = 'SOLAR'
);

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.isEnergyPoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `{{ project_id }}.{{ dataset_id }}.includes`(['cleaned', 'energy', 'intervalHistory', 'processedData'], `pointTags`)
);

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.isPowerPoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `{{ project_id }}.{{ dataset_id }}.includes`(['power', 'sensor'], `pointTags`)
);

CREATE OR REPLACE FUNCTION `{{ project_id }}.{{ dataset_id }}.isPerformancePoint`(
  `pointTags` ARRAY<STRING>
) RETURNS BOOL AS (
  `{{ project_id }}.{{ dataset_id }}.includes`(['pf', 'sensor'], `pointTags`)
);
