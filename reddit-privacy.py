#!/usr/bin/env python

# To delete anything over 30 days old:
# ./reddit-privacy.py -d 30 -p -c

# put your username and password here
USERNAME = ""
PASSWORD = ""

import urllib, urllib2, cookielib, json, sys, datetime
from optparse import OptionParser


# handle command line arguments
parser = OptionParser()

parser.add_option("-p", "--del-posts", help = "delete posts",
                  action="store_true", default = False)
parser.add_option("-c", "--del-comments", help = "delete comments",
                  action="store_true", default = False)
parser.add_option("-d", "--days", dest = "DAYS",
                  help = "delete posts after a number of days")
parser.add_option("-a", "--delete-all", action="store_true", default = False,
                  help = "delete everything, overriding all other settings")

options, args = parser.parse_args()

def read(fd):
  data = fd.read()
  fd.close()
  return data

def should_delete_type(post):
  if options.delete_all:
    return True
  if options.del_posts and 'num_comments' in post:
    return True
  if options.del_comments and 'num_comments' not in post:
    return True
  return False

def should_delete(post):
  if not should_delete_type(post): return False
  if options.DAYS is not None:
    # what time is it right now?
    current_time = int(datetime.datetime(2000, 1, 1).utcnow().strftime("%s"))

    # when should we delete posts after?
    del_time = current_time - 24 * 60 * 60 * int(options.DAYS)

    # trim posts that are not old enough from the start
    if int(post['created_utc']) < del_time:
      return True
    return False

def delete_post(post):
  params = urllib.urlencode({ 'id': post['name'],
                              'executed': 'deleted',
                              'r': post['subreddit'],
                              'uh': modhash })
  opener.open('http://www.reddit.com/api/del', params)
  print(f"deleted {post['name']} on {post['subreddit']}")

if options.delete_all:
  print("Deleting everything.")
elif options.del_posts or options.del_comments:
  # print what we're deleting
  print("Deleting")
  if options.del_posts and options.del_comments:
    print("posts and comments")
  elif options.del_posts: print("posts")
  else: print("comments")

  # print when we are deleting things
  if options.DAYS is not None:
    if int(options.DAYS) == 1:
      print(f"more than {options.DAYS} day old")
    else:
      print(f"more than {options.DAYS} days old")
  else: print
else:
  print("Deleting nothing, exiting...")
  sys.exit()

# save us some cooookies
cookies = urllib2.HTTPCookieProcessor(cookielib.LWPCookieJar())
opener = urllib2.build_opener(cookies)
opener.addheaders = [('User-agent', 'Reddit-privacy/0.0')]

# log in
params = urllib.urlencode({ 'user': USERNAME,
                            'passwd': PASSWORD,
                            'api_type': 'json' })
data = read(opener.open('http://www.reddit.com/api/login/', params))

# get the modhash
login_json = json.loads(data)
modhash = login_json['json']['data']['modhash']

# get user's posts
data = read(opener.open('http://www.reddit.com/user/%s/.json' % USERNAME))

print("Reading posts...")
num = 0
todelete = []
while True:
  posts_json = json.loads(data)
  for d in todelete:
    delete_post(d)
  todelete = []

  # add each post to the list of posts
  for p in posts_json['data']['children']:
    post = p['data']
    if should_delete(post):
      todelete.append(post)
    num += 1

  # when we run out of pages, stop
  if posts_json['data']['after'] is None:
    break
  else:
    data = read(opener.open('http://www.reddit.com/user/{0}.json?after={1}'.
                            format(USERNAME, posts_json['data']['after'])))
  print("{0} posts read so far...".format(num))

for d in todelete:
  delete_post(d)
