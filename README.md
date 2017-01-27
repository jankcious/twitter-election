Final Project presentation : Documents/Sentiment Analysis on Political Ads_Final.pdf  
Final Project Paper: Documents/SentimentAnalysisOnPoliticalAds_FinalPaper.pdf  

Following are the steps to recreate an instance and start twitter stream and analyze the data:  

1. Create a new EC2 instance with UCB AMI(UCB MIDS W205 EX2-FULL AMI)and attach a volume  

2. Run the complete set up script:  
	wget https://s3.amazonaws.com/ucbdatasciencew205/setup_ucb_complete_plus_postgres.sh  
	chmod +x ./setup_ucb_complete_plus_postgres.sh  
	./setup_ucb_complete_plus_postgres.sh /dev/xvdf  

3. Install python libraries  
	pip install tweepy  
	pip install boto  
	pip install textblob  
	
4. Clone the project repository  
	cd /data  
	git clone https://github.com/brianhschneider/w205_Group_Project.git  

5. Start the twitter stream python script  
	cd /data/w205_Group_Project/scripts  
	python streamTwitterDataS3.py > output.txt 2>&1 &  

6. Run the following command to get the Ad data and also load to hive  
	bash /data/w205_Group_Project/scripts/pretest.sh  
	bash /data/w205_Group_Project/scripts/test.sh  

7. Run the following bash script to start tweet parsing from S3 and create a file in EC2 instance  
	/data/w205_Group_Project/scripts/hive_loader.sh  
	
8. Analysis tables script  
	su - w205    
	hive -f /data/w205_Group_Project/scripts/hive_finalTable.sql    
	hive -f /data/w205_Group_Project/twitter_bot_score_table_sql.sql  
	hive -f /data/w205_Group_Project/scripts/hive_analysis_tables_queries - v3.sql    

9. Tableau
	Start hive server with command   
		hive --service hiveserver2   
	Open the Tableau dashboard on the desktop and connect to the EC2 instance using hiveserver   
