#
# Tractor Push: Node.js, socket.io, Ruby, MongoDB tailed cursor demo
# writer.rb - writes documents into MongoDB database.  Randomly
# chooses from three types to demonstrate schema flexibility of
# MongoDB as a queue.
#

#
# See also: https://github.com/mongolab/tractorpush-server
#

#
# ObjectLabs is the maker of MongoLab.com a MongoDB-as-a-Service
# provider.
#

#
# Copyright 2012, 2013 ObjectLabs Corp.  
# 

# MIT License

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:  

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 

#
# writer.rb - inserts sample documents into a MongoLab hosted
# MongoDB.  This is the writing half of the demo.  The other half,
# the tractorpush-server, reads from this database and presents to a
# browser.  For use with Heroku's platform as a service.
#

#
# Ben Wen, ObjectLabs
#

require 'rubygems' 
require 'uri'
require 'mongo'
require 'pp'

STDOUT.sync = true # Write in real-time

uristring = ENV['MONGOLAB_URI'] || 'mongodb://localhost/testdatabase'
debug = ENV['WRITER_DEBUG'] ? ENV['WRITER_DEBUG'] == "true" : false
rate = ENV['WRITER_RATE'] ? ENV['WRITER_RATE'].to_i : 1 # Every second, write a message 

uri = URI.parse(uristring)
conn = Mongo::Connection.from_uri(uristring)
db   = conn.db(uri.path.gsub(/^\//, ''))

db.drop_collection('messages')
coll = db.create_collection('messages', {capped: true, size: 8000000})

docs = [{messagetype: 'simple', ordinal: 0, somename: 'somevalue'}, 
        {messagetype: 'array', ordinal: 0, somearray: ['a', 'b', 'c', 'd']}, 
        {messagetype: 'complex', ordinal:0, subdocument: {fname: 'George', lname: 'Washington', subproperty: 'US-president'}}]

# Run until killed
i = 1
while(true)
  doc = docs[rand(3)].dup             # MongoDB collection.insert mutates document, editing the _id key; we need a deep dup (copy). 
  doc['time'] = Time.now().to_f * 1000 # Switch to Javascript's convention
  doc['ordinal'] = i
  print i
  coll.insert(doc, :safe => true)
  debug ? pp(doc) : puts("Inserting #{doc['messagetype']} message")
  sleep(rate)
  if i == 2**30 -1 then         # Not like we'll ever hit this at 1/sec, but someone could crank up the speed.
    i = 1 else 
    i = i + 1
  end

end
