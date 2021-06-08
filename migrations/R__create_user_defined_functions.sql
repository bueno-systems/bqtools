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
