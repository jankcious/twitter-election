#SETUP NEW TABLE
mkdir -p /data/scripts/temp_data
cd /data/scripts

#Setup Cities Table
hdfs dfs -mkdir /user/w205/citiesdata
hdfs dfs -put /data/scripts/cities_wDMA.csv /user/w205/citiesdata
hive -f /data/scripts/cities_ddl.sql

#First file setup
python S3_Parser.py 1 > first
firstfile=$(head -1 first)
echo "firstfile = $firstfile"
#hdfs dfs -rm /user/w205/twitterdata/FirstTweetsForHive.csv
hdfs dfs -put /data/scripts/temp_data/$firstfile /user/w205/twitterdata
hive -f /data/scripts/hive_ddl.sql
#PARSE A BUNCH OF FILES
status=$firstfile
echo $status
size=${#firstfile}
echo "initialsize = $size"
while [ $size = 18 ]
do
	python /data/scripts/S3_Parser.py "all" > file
	filename=$(head -1 file)
	echo "file = $filename"
	hdfs dfs -put /data/scripts/temp_data/$filename /user/w205/twitterdata
	size=${#filename}
done
#ADD NEW FILES TO HIVE
#hive -f /data/scripts/hive_ddl.sql
