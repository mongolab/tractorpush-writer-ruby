This application is the message-publishing portion of the system described in [this Heroku Dev Center article](https://devcenter.heroku.com/articles/build-realtime-polyglot-node-ruby-mongodb-socketio-app).

The Node.js web-component can be found at: https://github.com/mongolab/tractorpush-server

#### Deploy

Create the app on Heroku and add the MongoLab add-on.

```term
$ heroku create -s cedar tp-writer
$ heroku addons:add mongolab
```

Next, [configure the required MongoDB capped collection](https://devcenter.heroku.com/articles/build-realtime-polyglot-node-ruby-mongodb-socketio-app#configure_mongodb_capped_collection).

Then deploy to Heroku and scale the `worker` process.

```term
$ git push heroku master
$ heroku ps:scale worker=1
```