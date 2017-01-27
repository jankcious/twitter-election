-- Setup Reference tables for DMA attribution
DROP TABLE cities;
CREATE EXTERNAL TABLE IF NOT EXISTS cities (
name string,
key int,
dma_key int,
dma_name string,
state_name string,
state_abbrev string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
        "separatorChar" = ",",
        "quoteChar" = "\"",
        "escapeChar" = "\\")
STORED AS TEXTFILE LOCATION '/user/w205/citiesdata';
