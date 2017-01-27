# streamTwitterDataS3.py: Stream Twitter data using Tweepy Stream API and copy the files to S3 using boto

from tweepy.streaming import StreamListener
from twitterCredentialsNC import *
from awsCredentials import *
from time import gmtime, strftime
from boto.s3.connection import S3Connection
from boto.s3.key import Key
import sys
import os

class TwitterStream(StreamListener):
	file = None
	count = 0
	s3 = None

	def __init__(self):
		StreamListener.__init__(self)
		self.s3 = S3Connection(aws_access_key, aws_secret_key)
		self.open_new_tweet_file()


	def open_new_tweet_file(self):
		old_file = self.file

		filename = strftime("%Y%m%d%H%M%S.tweets", gmtime())
		self.file = open(filename, "w")
		self.count = 0

		print filename

		if old_file is not None:
			print old_file.name
			old_file.close()
			self.move_to_s3(old_file.name)

	def on_data(self, data):
		try:
			self.file.write(data[:-1])
			self.count += 1
			if self.count >= 10000:
				self.open_new_tweet_file()
			return True

		except Exception, e:
			pass

	def move_to_s3(self, filename):
		bucket = self.s3.get_bucket('twitterstorencbsjb')
		entry = Key(bucket)
		entry.key = filename
		b = entry.set_contents_from_filename(filename)
		print "{}: wrote {} bytes to s3".format(filename, b)
		#os.remove(filename)

if __name__ == '__main__':
	print "Streaming started"
	while True:
		try:
			stream1 = tweepy.Stream(auth, TwitterStream())
			stream1.filter(languages=["en"], track=["hillary", "clinton", "donald", "trump", "@HillaryClinton","@realDonaldTrump"])
		except:
			print "Unexpected error:", sys.exc_info()[0]

	print "Streaming ended"