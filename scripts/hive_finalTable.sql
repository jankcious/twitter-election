--Create final table, casting appropriate field types
DROP TABLE tweetdata;
CREATE TABLE IF NOT EXISTS tweetdata AS 
SELECT cast(id AS bigint) as id, 
place, 
CAST(retweet_count AS int) as retweet_count, 
text, 
user_geo_enabled, 
CAST(user_id AS bigint) as user_id, 
user_location, 
user_name, 
user_screen_name, 
candidate,
CAST(subjectivity AS float) AS subjectivity, 
CAST(polarity AS float) AS polarity, 
CAST(date_time AS timestamp) as date_time, 
city, 
state,
dma_name,
CAST(five_minute_interval AS int) AS five_minute_interval,
CAST(ten_minute_interval AS int) AS ten_minute_interval,
CAST(fifteen_minute_interval AS int) AS fifteen_minute_interval,
CAST(date AS date) as date
FROM tweetsInit;