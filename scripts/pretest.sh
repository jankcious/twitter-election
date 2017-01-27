#!/bin/bash

# Run this first. It will get the core script and create a cron job, then open the repeatable script.

wget -O /data/test.sh "https://www.dropbox.com/s/1v6pefdh1axwonh/test.sh?dl=0"
crontab -l > temp
echo "59 23 * * * /data/test.sh" >> temp
crontab temp
rm temp
bash test.sh