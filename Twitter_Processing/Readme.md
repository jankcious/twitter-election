# Tweet Processing

### Overview
These are scripts meant to process tweets.  At this point, batches of 10,000 tweets have been saved into an S3 bucket.  
The goal is to download them one by one, extract the needed information, add additional insights, and then save them out
in a .csv format so they can be loaded into a Hive table.

### hive_loader.sh
This shell script will run `S3_Parser.py` through initialization.  The result is a csv that gets put into HDFS.  Then, the script will run `hive_ddl.sql` in
order to initialize the Hive table.  It will then call `S3_Parser` in a loop until all of the `.tweet` files in S3 have been parsed and placed into HDFS.  
At this point, you can either wait for additional tweets to come in (and run this script again), or execute `hive -f hive_finalTable.sql`.  The final
table will use Hive to create a final tweets table that is properly cast for analysis.

##hive_ddl.sql
Defines a Hive table build off of .csv files store in the `/user/w205/twitterdata` folder within HDFS into the `tweetInit` table.  Although columns are cast properly here, the SERDE process 
will turn everything into strings, which is why you need to run `hive_finalTable.sql` in order to make a useable table.

|Column Name				|Type		|Description							|
|---------------------------|-----------|---------------------------------------|
|id 						|int		|Unique tweet ID						|
|place 						|string		|Twitter validated place				|
|retweet_count 				|int		|Number of retweets						|
|text 						|string		|Contents of tweet						|
|user_geo_enabled 			|string		|T/F, user enabled geolocation			|
|user_id 					|int		|Unique user ID							|
|user_location 				|string		|User defined location					|
|user_name 					|string		|User defined name						|
|user_screen_name 			|string		|Twitter Handle							|
|candidate 					|string		|Which candidate was mentioned			|
|subjectivity 				|float		|Measure of tweet sentiment				|
|polarity 					|float		|Measure of tweet sentiment				|
|date_time 					|timestamp	|Timestamp of tweet						|
|city 						|string		|Validated city, blank if unknown		|
|state 						|string		|Validated state, blank if unknown		|
|dma_name 					|string		|Name of TV market for city/state		|
|five_minute_interval 		|int		|Count of 5 min buckets since midnight	|
|ten_minute_interval 		|int		|Count of 5 min buckets since midnight	|
|fifteen_minute_interval	|int		|Count of 5 min buckets since midnight	|
|date 						|timestamp	|Date of tweet							|

##hive_finalTable.sql
This file will take the table above and recast each column in the correct data format.  Requires tweetInit table to be present, and produces the tweetdata table.

##S3_Parser.py
This file connects to an S3 bucket and retrieves a list of all `.tweets` files present.  It takes the oldest unprocessed .tweet file and parses the JSON into columns of 
interest.  This becomes a Pandas DataFrame object for ease of manipulation.  
First we search through the tweet text for mentions of Clinton, Trump, both, or none.  This is recorded in the `candidate` column.  Next, we grade each sentence of the tweet 
using sentiment analysis and record the subjectivity and polarity scores for each tweet.  
Next, we check for valid geolocation information provided by Twitter in 
the `place` column.  This is typically only 5-10% of all tweets, but valid city and state names can be easily extracted if present.  If no official place exists, we check the user provided `location` column for valid state names (either abbreviated or spelled out).  If we find a match, 
it's recorded in the `state` column.  We then search within dictionaries for all cities within the appropriate state for valid cities.  Each city-state combination has 
been paired with a corresponding Designated Marketing Area (DMA), which will be important for comparing to TV Ad data.  Although this cannot successfully interpret 
'Philly burbs', we are very confident in the matches that were found.  Exploratory looks into the data showed many missing, made up, or intentionally snarky user locations.  
Lastly, we process the date and time of the tweet into several categories for later comparisons.  This produces the date of the tweet, as well as the 5/10/15 minute bucket of the day 
that the tweet fell into.  For example, a tweet at 12:35 AM would have a five min bucket of 7, ten min bucket of 4, and fifteen min bucket of 3.
This script can be run with an argument of 1 for initial processing, or `all` for subsequent runs.  The only difference in the initial run is that the status log is not checked for which tweets
have been processed so far.  

##Status.csv
A simple list of completed filenames

##cities_wDMA.csv
A reference file for every name place in the United States as well as the corresponding state (full name and abbreviations), as well as the DMA to which that state belongs.

