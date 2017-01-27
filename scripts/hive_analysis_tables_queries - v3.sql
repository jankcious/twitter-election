--create analysis tables for Tableau dashboards
-------------------------------------------------------------------------------------
drop table addata_analysis;
create table addata_analysis as 
    select location as dma_name, candidates as candidate, cast(to_date(ad_date) as date) as ad_date, five_minute_interval, 
    count(*) as ad_count,
    sum(case when message > 'pro' then 1 else 0 end) as pro_ads_count,
    sum(case when message > 'con' then 1 else 0 end) as con_ads_count
    from addata
    Group by location, candidates, cast(to_date(ad_date) as date), five_minute_interval;

describe addata_analysis;

-------------------------------------------------------------------------------------
drop table tweet_analysis;
create table tweet_analysis as 
    select a.dma_name, candidate, cast(to_date(date) as date) as tweet_date, five_minute_interval, 
    count(*) as tweetcount, 
    sum(case when Polarity > 0 then 1 else 0 end) as positive_tweet_count,
    sum(case when Polarity < 0 then 1 else 0 end) as negative_tweet_count,
    avg(polarity) as avg_polarity,
    avg(subjectivity) as avg_subjectivity,
    avg(case when b.score > 0.4 then polarity else null end) as avg_bot_polarity,
    avg(case when b.score < 0.4 then polarity else null end) as avg_non_bot_polarity,
    sum(case when b.score > 0.4 then 1 else 0 end) as bot_tweet_count,
    sum(case when b.score < 0.4 then 1 else 0 end) as non_bot_tweet_count
    from tweetdata2 as a left outer join user_dma_bot_scores as b on a.user_screen_name = b.screen_name
    where (a.dma_name is not null or trim(a.dma_name) <> '') and candidate in ('clinton','trump','both')
    group by a.dma_name, candidate, cast(to_date(date) as date), five_minute_interval
;
-------------------------------------------------------------------------------------
create table user_dma_bot_scores as 
    select screen_name, b.dma_name, score, content_classification, temporal_classification, network_classification, friend_classification
    sentiment_classification, user_classification
    from user_bot_scores as a left outer join  
    (select distinct user_screen_name, dma_name from tweetdata) as b 
    on a.screen_name = b.user_screen_name
;
-------------------------------------------------------------------------------------

 








