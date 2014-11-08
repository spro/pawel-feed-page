somata_socketio = require 'somata-socketio'
hashpipe = require 'hashpipe'
request = require 'request'
util = require 'util'
_ = require 'underscore'

# Get available avatars from uiavatars and messages from file

pipeline = new hashpipe.Pipeline().use('files').use('http').use('html')
loaded = pipeline.execFile './random-data.hp', (err, going) -> console.log going
get_random_messages = (n, cb) ->
    pipeline.exec "get-random-messages #{ n }", {}, loaded, cb

# Routes

app = somata_socketio.setup_app
    port: 4333

app.get '/', (req, res) ->
    res.render 'base'

randomTime = (since) ->
    dt = 1000*60*60*24*Math.random() # Up to a day since
    since - dt
attachRandomTime = (o, since) ->
    o.time = randomTime(since)
    return o

app.get '/messages.json', (req, res) ->
    since = parseInt(req.query.since) || new Date().getTime()
    get_random_messages 1, (err, messages) ->
        messages = messages.map((q) -> attachRandomTime q, since)
        oldest = messages.reduce (a, b) -> if a.time < b.time then a else b
        response =
            data: messages.sort (a, b) -> a.time < b.time
            meta: since: oldest.time
        res.json response

app.start()

