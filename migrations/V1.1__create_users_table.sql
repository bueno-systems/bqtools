CREATE TABLE IF NOT EXISTS `bqtools.users`
(
  `date` DATE NOT NULL,
  `username` STRING NOT NULL,
  `firstname` STRING NOT NULL,
  `lastname` STRING NOT NULL
)
OPTIONS (
  description="Daily metering data"
);
