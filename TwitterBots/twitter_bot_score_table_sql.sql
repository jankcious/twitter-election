DROP TABLE user_bot_scores;
CREATE EXTERNAL TABLE IF NOT EXISTS user_bot_scores
(screen_name string,
score float,
content_classification float,
temporal_classification float,
network_classification float,
friend_classification float,
sentiment_classification float,
user_classification float
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
        "separatorChar" = ",",
        "quoteChar" = "\"",
        "escapeChar" = "\\")
STORED AS TEXTFILE;


LOAD DATA LOCAL INPATH '/home/w205/TwitterBotScores.csv' INTO TABLE user_bot_scores;
--OVERWRITE;

select count(*) from user_bot_scores;

select * from user_bot_scores limit 100;

select * from user_bot_scores where screen_name = 'dale_je';




