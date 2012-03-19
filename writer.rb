#
# Tractor Push: Node.js, socket.io, Ruby, MongoDB tailed cursor demo
# writer.rb - writes documents into MongoDB database.  Randomly
# chooses from three types to demonstrate schema flexibility of
# MongoDB as a queue.
#

#
# Copyright 2012 ObjectLabs Corp.  ObjectLabs is the maker of
# MongoLab.com a cloud, hosted MongoDb service
#

# Licensed under the Apache License, Version 2.0 (the "Apache License");
# you may not use this file except in compliance with the Apache License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Apache License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License for the specific language governing permissions and

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

uristring = ENV['MONGOLAB_URI'] || 'mongodb://localhost/testdatabase'
debug = ENV['WRITER_DEBUG'] || "false"
rate = ENV['WRITER_RATE'].to_f 
if (rate = 0.0) then rate = 10.0


uri = URI.parse(uristring)
conn = Mongo::Connection.from_uri(uristring)
db   = conn.db(uri.path.gsub(/^\//, ''))

coll = db.collection('messages')

docs = [{'messagetype' => 'simple', 'ordinal' => 0, 'somename' => 'somevalue'}, 
        {'messagetype' => 'array', 'ordinal' => 0, 'somearray' => ['a', 'b', 'c', 'd']}, 
        {'messagetype' => 'complex', 'ordinal' =>0, 'subdocument' => {'fname' => 'George', 'lname' => 'Washington', 'subproperty' => 'US-president'}}]


count = 500
print("starting insertion of ", count, " documents into ", uri.scheme, "://", uri.host, uri.path, "\n")
for i in 1..count
  doc = docs[rand(3)].dup             # MongoDB collection.insert mutates document, editing the _id key; we need a deep dup (copy). 
  doc['time'] = Time.now().to_f * 1000 # Switch to Javascript's convention
  doc['ordinal'] = i
  coll.insert(doc, :safe => true)
  if (debug == "true") then pp (doc) end
  sleep(1.0/rate) 
  print rate
end

print("Finished. Inserted ", count, " messages.\n")

