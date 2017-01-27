DROP TABLE dma_matches;
CREATE EXTERNAL TABLE IF NOT EXISTS dma_matches
(addata_dma string,
masterdata_dma string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
        "separatorChar" = ",",
        "quoteChar" = "\"",
        "escapeChar" = "\\")
STORED AS TEXTFILE;


LOAD DATA LOCAL INPATH '/home/w205/matches_dma.csv' INTO TABLE dma_matches OVERWRITE;

select * from dma_matches;

select * from dma_matches where addata_dma = 'San Francisco-Oakland-San Jose, CA';


select id,wp_identifier,network, b.masterdata_dma as location, 
program,program_type,start_time,five_minute_interval,
ten_minute_interval,fifteen_minute_interval,end_time,archive_id,embed_url,sponsors,
sponsor_types,race,cycle,subjects,candidates,type,message,date_created,ad_date 
from addata as a left outer join dma_matches as b on a.location  = b.addata_dma



select a.location as old_location, b.masterdata_dma as new_location
from addata as a left outer join dma_matches as b on a.location  = b.addata_dma
where a.location <> b.masterdata_dma;


update a.location as old_location, b.masterdata_dma as new_location
from addata as a left outer join dma_matches as b on a.location  = b.addata_dma
where a.location <> b.masterdata_dma;



select id,wp_identifier,network,location, b.masterdata_dma, program,program_type,start_time,end_time,archive_id,
embed_url,sponsors,sponsor_types,race,cycle,subjects,candidates,type,message,date_created
from addata as a left outer join dma_matches as b on a.location  = b.addata_dma;
