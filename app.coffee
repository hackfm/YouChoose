express    = require 'express'
sockjs     = require 'sockjs'
url        = require 'url'
path       = require 'path'
fs         = require 'fs'
http       = require 'http'
Queue      = require './Queue'
QueueEntry = require './QueueEntry'
youtube    = require './youtube'
Chat       = require './Chat'
bodyParser = require 'body-parser'

args = process.argv.splice(2);
if args.length < 1
    port = process.env.VCAP_APP_PORT || 8080
else
    port = args[0]
port = Number(port)
if isNaN port
    port = process.env.VCAP_APP_PORT || 8080

#Chat
chat = new Chat()

# Socket Server
currentConnections = 0;
sockServer = sockjs.createServer()
sockServer.on 'connection', (conn) ->
    ++currentConnections
    queue.updateConnectionNumber currentConnections
    #conn.on 'data', (message) ->
    #    conn.write message
    conn.on 'close', () ->
        console.log 'close'
        --currentConnections
        queue.updateConnectionNumber currentConnections

    sendUpdate = () =>
        conn.write JSON.stringify queue.getQueue()

    sendCurrentVideo = () =>
        conn.write JSON.stringify queue.getCurrentVideo()

    queue.on 'update', sendUpdate
    queue.on 'currentVideo', sendCurrentVideo
    queue.on 'noVideo', () =>
        json = {type: 'loadVideo', content:null}
        conn.write JSON.stringify json

    queue.on 'skipCount', (needed, users) =>
        json = {type: 'skipCount', content:{needed:needed, users:users}}
        conn.write JSON.stringify json

    chat.on 'chat', (user, message) =>
        json = {type: 'chat', content:{user:user, message:message}}
        conn.write JSON.stringify json

    # Send updates
    if queue.hasCurrentVideo()
        sendCurrentVideo()
        queue.updateSkip()
    sendUpdate()

# Start queue
queue = new Queue()

# Generic add Video function
addVideo = (title, user) ->
    youtube title, (id, title, length, image) =>
        console.log id
        if videoInQueue = queue.getVideoById id
            videoInQueue.upvote user
            queue.sendPlaylistUpdate()
            chat.sysMessage user, "has upvoted "+videoInQueue.title
        else
            entry = new QueueEntry id, title, length, image
            entry.upvote user
            queue.addVideo entry
            chat.sysMessage user, "has added "+title
    () =>
        console.log 'YouTube error callback'

app = express();
server = http.createServer(app);

app.use(bodyParser.urlencoded())
app.use(express.static(__dirname + '/http'));

sockServer.installHandlers server, {prefix:'/sock'}

console.log 'Listening on port', port
server.listen(port);

app.post '/add', (req, res) ->
    if (req.body.title && req.body.user)
        addVideo(req.body.title, req.body.user);
        res.send('OK');
        return
    res.status(400).send('Nope');


app.post '/upvote', (req, res) ->
    if (req.body.id && req.body.user)
        video = queue.getVideoById(req.body.id);
        if (video)
            video.upvote query.user
            queue.sendPlaylistUpdate();
            chat.sysMessage query.user, "has upvoted "+video.title
            res.send('OK');
            return
    res.status(400).send('Nope');

app.post '/chat', (req, res) ->
    if (req.body.user && req.body.msg)
        chat.chat req.body.user, req.body.msg
        res.send('OK');
        return
    res.status(400).send('Nope');

app.post '/skip', (req, res) ->
    if (req.body.user)
        queue.skipCurrent req.body.user
        chat.sysMessage req.body.user, "has voted to skip the current video"
        res.send('OK');
        return
    res.status(400).send('Nope');

