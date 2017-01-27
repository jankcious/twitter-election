#!/bin/bash

# This will get the addata, clean the addaata, and add the sql file.
wget -O /data/test.csv "http://politicaladarchive.org/api/v1/ad_instances?start_time=10/1/2016%2000:00:00&end_time=12/31/2016%2023:59:59&output=csv"
wget -O /home/w205/hive_base_ddl.sql "https://www.dropbox.com/s/ziofjm3oz54a1uk/hive_base_ddl.sql?dl=0"
tail -n +2 /data/test.csv > /data/addata.csv

# hive -- goal here is to create tables with hive/spark
su - w205

# I haven't been able to have scripts run successfully as w205 user.
hdfs dfs -mkdir /user/w205/ads
hdfs dfs -rm /user/w205/ads/addata.csv
hdfs dfs -put -f /data/addata.csv /user/w205/ads
hive -f hive_base_ddl.sql
