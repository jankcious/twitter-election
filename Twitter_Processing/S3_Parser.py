from boto.s3.connection import S3Connection
import boto
from boto.s3.key import Key
import pandas as pd
import numpy as np
import json
import io
import os
import re
from textblob import TextBlob
import argparse
import csv
import sys

#Connect to S3
Access_Key_ID = 'AKIAIS7WC3LSDKW6FKMA'
Secret_Access_Key = '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'
c = S3Connection(Access_Key_ID, Secret_Access_Key)
b = c.get_bucket('twitterstorencbsjb')

#Columns to parse out
#Columns starting with 'user_' will be searched for in the user subgroup of the tweet
cols = ['created_at', 'id', 'text', 'place', 'user_id', 'user_name', 'user_screen_name', 'user_location', 'user_geo_enabled', 'retweet_count']

#Find all files for parsing
files = []
for file in b.list():
    if '.tweets' in str(file).split(',')[1]:
        files.append(str(file).split(',')[1][:-1])

def valid_state(state, regex, state_dict):
    '''Returns a valid state code if found within a string'''
    try:
        ans = state_dict[re.search(regex, state).group()]
    except:
        ans = 0
    return ans

def valid_city(city, state, regex_dict):
    '''returns a valid city if found within the state.  regex_dict is a 50 element dictionary
    containing regex strings for each state'''
    try:
        return re.search(regex_dict[state.strip()], city.strip()).group()
    except:
        return 0

def munge_loc(loc, state_dict, state_regex, regex_dict):
    '''given a location string from a user's twitter account, returns (city, state) if valid'''
    try:
        state = valid_state(loc, state_regex, state_dict)
        city = valid_city(loc, state, regex_dict)
        return state, city
    except:
        return 0,0

def tweet_to_df(bucket, filename, columns):
    '''Given a file of JSON tweets, transform them into a dataframe with additional information for database storage.
    bucket is a S3 object for connecting, a filename to process, and the desired columns to parse out'''
    k = bucket.get_key(filename)
    k.get_contents_to_filename(filename)
    with io.open(filename, 'rt') as f:
        load_dict = {col:list() for col in cols}
        for line in f:
            try:
                tweet = json.loads(line)
                if len(tweet) > 2: #exclude pacing lines
                    for col in columns:
                        if col == 'place':
                            if tweet['place']:
                                load_dict[col].append(tweet['place']['full_name'])
                            else:
                                load_dict[col].append('NA')
                        elif not col.startswith('user_'):
                            if col in tweet.keys():
                                if col == 'text':
                                    load_dict[col].append(tweet[col].replace("\r", " ").replace("\n", " "))
                                else:
                                    load_dict[col].append(tweet[col])
                            else:
                                load_dict[col].append('')
                        else:
                            if col[5:] in tweet['user'].keys():
                                load_dict[col].append(tweet['user'][col[5:]])
                            else:
                                load_dict[col].append('')
            except:
                pass
    #Convert the dictionary into a Pandas dataframe for manipulation
    load_df = pd.DataFrame(load_dict)
    #Use Regex to flag tweets based on the candidate they talk about
    both = ('both', re.compile('(hillary|clinton).+(trump|donald)', re.IGNORECASE))
    both2 = ('both', re.compile('(trump|donald).+(hillary|clinton)', re.IGNORECASE))
    don = ('trump', re.compile('(trump|donald)', re.IGNORECASE))
    hil = ('clinton', re.compile('(hillary|clinton)', re.IGNORECASE))
    non = ('none', re.compile('both|trump|clinton', re.IGNORECASE))
    checks = [both, both2, don, hil]
    ans = list(load_df['text'])
    for check in checks:
        ans = [check[0] if re.search(check[1], x) else x for x in ans]
    load_df['candidate'] = ['none' if x not in ['trump', 'both', 'clinton'] else x for x in ans]
    #Sentiment analysis of each tweet for subjectivity and polarity
    load_df['subjectivity'] = [max([x.subjectivity for x in TextBlob(y).sentences]) for y in load_df['text']]
    load_df['polarity'] = [max([x.polarity for x in TextBlob(y).sentences]) for y in load_df['text']]
    load_df['date_time'] = pd.to_datetime(load_df['created_at'], infer_datetime_format=True)
    load_df.drop('created_at', axis=1, inplace=True)
    #use place as city/state if present
    load_df['city'] = [x.split(',')[0] if len(x.split(',')) > 1 else '' for x in load_df['place']]
    load_df['state'] = [x.split(',')[1] if len(x.split(',')) > 1 else '' for x in load_df['place']]
    #find all states, create regex patterns
    cities = pd.read_csv("/data/scripts/cities_wDMA.csv", names=['name', 'key', 'dma_key', 'dma_name', 'state_name', 'state_abbrev'], encoding='latin-1')
    state_dict = {x[0]:x[1] for x in cities.groupby(['state_name', 'state_abbrev']).size().index}
    state_dict.update({x[1]:x[1] for x in cities.groupby(['state_name', 'state_abbrev']).size().index})
    state_regex = re.compile('|'.join(state_dict.keys()))
    #find all cities and create regex patterns
    city_regex = {state:re.compile('|'.join(cities[cities['state_abbrev'] == state].groupby(['name']).size().index)) for state in cities.groupby('state_abbrev').size().index}
    load_df['state'] = load_df['state'].apply(lambda x: valid_state(x, state_regex, state_dict))
    load_df['city'] = load_df.apply(lambda x: valid_city(x['city'], x['state'], city_regex), axis=1)
    load_df['state'] = load_df.apply(lambda x: valid_state(x['user_location'], state_regex, state_dict), axis=1)
    load_df['city'] = load_df.apply(lambda x: munge_loc(x['user_location'], state_dict, state_regex, city_regex)[1], axis=1)
    load_df = load_df.apply(lambda x: x.strip() if type(x) == str else x)
    load_df = load_df.merge(cities[['name', 'dma_name', 'state_abbrev']], how='left', left_on=['city', 'state'], right_on=['name', 'state_abbrev'])
    #Remove unnecessary columns
    load_df.drop('state_abbrev', axis=1, inplace=True)
    load_df.drop('name', axis=1, inplace=True)
    #Various minute buckets for comparing to AdData
    load_df['five_minute_interval'] = (load_df['date_time'] - pd.to_datetime(load_df['date_time'].dt.date)).astype('timedelta64[m]') // 5
    load_df['ten_minute_interval'] = (load_df['date_time'] - pd.to_datetime(load_df['date_time'].dt.date)).astype('timedelta64[m]') // 10
    load_df['fifteen_minute_interval'] = (load_df['date_time'] - pd.to_datetime(load_df['date_time'].dt.date)).astype('timedelta64[m]') // 15
    load_df['date'] = load_df['date_time'].dt.date
    #Remove records that do not appear to discuss either targeted candidate
    try:
        load_df = load_df[load_df['candidate'] != 'none']
    except:
        pass
    os.remove(filename)
    return load_df

if __name__ == "__main__":
    #Process arguments
    parser = argparse.ArgumentParser(description='number of files to parse')
    parser.add_argument('num', metavar = 'n', type=str, nargs=1, help='either 1 or all')
    args = parser.parse_args()
    #Process the first file (no status)
    if args.num[0] == '1':
        for file in files[0:1]:
            df = tweet_to_df(b, file, cols)
            df.to_csv('temp_data/' + file[0:-7] + '.csv', header = False, index = False, mode = 'wt', encoding='utf-8')
            print file[0:-7] + '.csv'
    elif args.num[0] == 'all':
        name = 'AllTweetsForHive.csv'
        try:
            with open('status.csv', 'rt') as f: #initialize status with already complete files
                status = []
                lines = csv.reader(f)
                status = [line[0] for line in lines]
        except:
            status = []
        for file in files:
            if file not in status:
                df = tweet_to_df(b, file, cols)
                df.to_csv('temp_data/' + file[0:-7] + '.csv', header = False, index = False, mode = 'wt', encoding='utf-8')
                status.append(file)
                with open('status.csv', 'at') as f:
                    wr = csv.writer(f, quoting=csv.QUOTE_ALL)
                    wr.writerows([[file]])
                print file[0:-7] + '.csv'