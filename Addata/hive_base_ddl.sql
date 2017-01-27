DROP TABLE addatafirst;
CREATE EXTERNAL TABLE IF NOT EXISTS addatafirst
(id string,
wp_identifier string,
network string,
location string,
program string,
program_type string,
start_time timestamp,
end_time timestamp,
archive_id string,
embed_url string,
sponsors string,
sponsor_types string,
race string,
cycle int,
subjects string,
candidates string,
type string,
message string,
date_created string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
        "separatorChar" = ",",
        "quoteChar" = "\"",
        "escapeChar" = "\\")
STORED AS TEXTFILE
LOCATION '/user/w205/ads';

DROP TABLE addatasecond;
CREATE TABLE IF NOT EXISTS addatasecond
as select id, wp_identifier, network, location, program, program_type, FROM_UNIXTIME(UNIX_TIMESTAMP(start_time)) as start_time, FROM_UNIXTIME(UNIX_TIMESTAMP(end_time)) as end_time, archive_id, embed_url, sponsors, sponsor_types, race, cycle, subjects, candidates, type, message, FROM_UNIXTIME(UNIX_TIMESTAMP(date_created)) as date_created from addatafirst;

DROP TABLE addatathird;
CREATE TABLE IF NOT EXISTS addatathird
as select id, wp_identifier, network, location, program, program_type, cast(start_time as timestamp) as start_time, cast(end_time as timestamp) as end_time, archive_id, embed_url, sponsors, sponsor_types, race, cycle, subjects, candidates, type, message, cast(date_created as timestamp) as date_created from addatasecond;
    
DROP TABLE addatafourth;
CREATE TABLE IF NOT EXISTS addatafourth
as select id, wp_identifier, network, location, program, program_type, start_time, end_time, archive_id, embed_url, sponsors, sponsor_types, race, cycle, subjects, candidates, type, message, date_created, TO_DATE(start_time) as ad_date from addatathird where race = 'PRES';

DROP TABLE addatatest;
CREATE TABLE IF NOT EXISTS addatatest
as select id, wp_identifier, network, location, program, program_type, start_time, cast(substr(start_time, 12, 2) as int) as hours, cast(substr(start_time, 15, 2) as int) as minutes, end_time, archive_id, embed_url, sponsors, sponsor_types, race, cycle, subjects, candidates, type, message, date_created, TO_DATE(start_time) as ad_date from addatafourth where race = 'PRES';

DROP TABLE addata;
CREATE TABLE IF NOT EXISTS addata
as select id, wp_identifier, network, b.masterdata_dma as location, program, program_type, start_time, cast(round(DOUBLE (hours * 60 + minutes) * 0.2) as int) as five_minute_interval, cast(round(DOUBLE (hours * 60 + minutes) * 0.1) as int) as ten_minute_interval, cast(round(DOUBLE (hours * 60 + minutes) * 0.0666667) as int) as fifteen_minute_interval, end_time, archive_id, embed_url, sponsors, sponsor_types, race, cycle, subjects, case when candidates like '%Trump%' and candidates not like '%Clinton%' then 'trump' when candidates like '%Clinton%' and candidates not like '%Trump%' then 'clinton' when candidates like '%Trump%' and candidates like '%Clinton%' then 'both' end as candidates, type, message, date_created, TO_DATE(start_time) as ad_date from addatatest as a left outer join dma_matches as b on a.location = b.addata_dma;

DROP TABLE addatafirst;
DROP TABLE addatasecond;
DROP TABLE addatathird;
DROP TABLE addatafourth;
DROP TABLE addatatest;
DROP TABLE addatatest2;
