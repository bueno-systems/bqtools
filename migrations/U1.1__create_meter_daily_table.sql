CREATE TABLE IF NOT EXISTS `bueno.meter_daily`
(
  `date` DATE NOT NULL,
  `project_key` STRING NOT NULL,
  `site_id` STRING NOT NULL,
  `mda_meter_id` STRING,
  `solar_meter_id` STRING,
  `mda_total_energy` FLOAT64,
  `mda_total_op_energy` FLOAT64,
  `mda_total_ooh_energy` FLOAT64,
  `mda_avg_power` FLOAT64,
  `mda_avg_op_power` FLOAT64,
  `mda_avg_ooh_power` FLOAT64,
  `mda_avg_pf` FLOAT64,
  `mda_avg_op_pf` FLOAT64,
  `mda_avg_ooh_pf` FLOAT64,
  `solar_total_energy` FLOAT64,
  `solar_total_op_energy` FLOAT64,
  `solar_total_ooh_energy` FLOAT64
)
PARTITION BY `date`
CLUSTER BY `date`, `project_key`, `site_id`
OPTIONS (
  description="Daily metering data"
);
