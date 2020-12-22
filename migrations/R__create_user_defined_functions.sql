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
    'coldDeck','dew','refrigerant','unocc','dc','solar','valve','water','elecHeat','minPress','performanceMeter','pressure','siteMeter','heatExchanger','cooling','dehumidification','mixing','occupancyIndicator','pwm','speed','steam','thd','unit','dualDuct','humidity','singleDuct','steamHeat','volume','device','export','float','gas','lightLevel','temp','antiSweat','floorRef','vsd','chiller','co2','direction','discharge','freezeStat','wind','air','bakery','centrifugal','heatWheel','hotWaterPlant','network','primaryLoop','raw','spill','visibility','equip','reciprocal','subPanelOf','area','clean','ductArea','filter','his','kwh','zone','glassDoorFridge','primaryFunction','suction','volt','ahu','alarm','heatPump','hvac','oilSeparator','reactivePower','reheating','hotWaterReheat','makeup','noUsage','point','barometric','liquidReceiver','lowUsage','occ','power','reclaim','refrig','rooftop','gasHeat','leakDetector','meter','defrost','dxCool','fcu','isolation','outside','return','screw','steamMeterLoad','condenser','effective','elec','floatEnable','kvarh','vavZone','apparentPower','chilledBeam','leak','reheat','standby','entering','meterQuality','reactiveEnergy','secondaryLoop','avg','chilledWaterCool','damper','directZone','efficiency','irradiance','pressureIndependent','heating','max','mda','minVal','mixed','circ','constantVolume','elecPanel','flue','lights','coolingTower','hotDeck','protocol','pump','reactive','total','closedLoop','floor','frequency','hot','sensor','uv','delta','run','vavMode','coolOnly','enable','humidifier','minSpeed','status','gasMeterLoad','multiZone','neutralDeck','absorption','boiler','cool','crucialMeter','edh','fault','tradeFloor','waterCooled','condenserPlant','elecReheat','evaporator','level','door','lighting','pid','sitePanel','waterMeterLoad','case','dis','fanPowered','heat','onCoil','blowdown','condensate','lowTemp','mag','oil','steamPlant','bool','cumulative','energy','faceBypass','lightsGroup','precipitation','sp','apparent','bypass','pf','chilled','cloudage','imbalance','intervalHistory','occupied','mediumTemp','min','diverting','doorSwitch','mau','chilledWaterPlant','cleaned','connection','decommissioned','load','maxVal','openLoop','saturated','tripleDuct','compressor','flow','maxPress','offCoil','pressureDependent','airCooled','avgTemp','coil','header','highTemp','vacuum','wetBulb','cmd','perimeterHeat','submeterOf','domestic','freq','net','parallel','series','tank','active','compressorPlant','coolingCapacity','leaving','variableVolume','alwaysOccupied','co','fan','stub','vav','ahuRef','circuit','current','exhaust','hotWaterHeat','phase','stage'
  ]
  return tags.filter(tag => keep.includes(tag))
""";
