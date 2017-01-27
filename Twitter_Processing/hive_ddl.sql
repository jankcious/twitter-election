--Original table, SERDE will turn all fields to string
DROP TABLE tweetsInit;
CREATE EXTERNAL TABLE IF NOT EXISTS tweetsInit (
id int, 
place string,
retweet_count int,
text string,
user_geo_enabled string,
user_id int,
user_location string,
user_name string,
user_screen_name string,
candidate string,
subjectivity float,
polarity float,
date_time timestamp,
city string,
state string,
dma_name string,
five_minute_interval int,
ten_minute_interval int,
fifteen_minute_interval int,
date timestamp
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
        "separatorChar" = ",",
        "quoteChar" = "\"",
        "escapeChar" = "\\")
STORED AS TEXTFILE LOCATION '/user/w205/twitterdata/temp_data';
