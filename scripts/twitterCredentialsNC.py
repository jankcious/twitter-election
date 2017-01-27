import tweepy

consumer_key = 'zeGmJagks4kncLdpKILFcbsy4'
consumer_secret = 'mBaOCMEHUDKgKbaADX0BWAksHg9eBionJ9KqjnrWDFxhKykUEC'
access_token = '784087155941449728-yVO61JEBuknaGsOEYhUn2jJWJV0DLAO'
access_token_secret = 'S5BJsGLv26oB9SRkfxAmFaWmoXO1d9qMsfCKFeraCbOgd'

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)
