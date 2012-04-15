http       = require 'http'
sockjs     = require 'sockjs'
url        = require 'url'
path       = require 'path'
fs         = require 'fs'
#process    = require 'process'
Queue      = require './Queue'
QueueEntry = require './QueueEntry'
youtube    = require './youtube'
Twilio     = require './twilio'
Chat       = require './Chat'

# MIME Types
mimeTypes = 
    html: "text/html"
    jpeg: "image/jpeg"
    jpg:  "image/jpeg"
    png:  "image/png"
    js:   "text/javascript"
    css:  "text/css"

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


# Cross origin
crossDomainHeaders = (req, res) ->
    #Allow any domain to make x-domain requests to the API
    res.setHeader 'Access-Control-Allow-Origin', '*'

    # We support GET and POST as part of the API and we enable OPTIONS
    # for x-domain preflight requests (see CORS specification)
    res.setHeader 'Access-Control-Allow-Methods', 'POST, GET, OPTIONS'

    # Let's not get hammered with preflight requests unnecessarily (cache for a day)
    res.setHeader 'Access-Control-Max-Age', '86400'

    # If the requester wishes to set random headers (e.g. Prototype likes to add X-Prototype-Version)
    # we MUST echo them here or the request will be restricted by the browser. And, no, we can't
    # use * as in the Access-Control-Allow-Origin header.
    if req.headers['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']?
        res.setHeader 'Access-Control-Allow-Headers', req.headers['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']

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

# Twilio 
try 
    twilio = new Twilio.twilio addVideo
catch e
    console.log 'Wasn\'t able to start twilio since the port is already in use'


# Start a http server
server = http.createServer (req, res) ->

    crossDomainHeaders req, res

    uri = url.parse(req.url).pathname; 
    query = url.parse(req.url, true).query;
    # TODO: check some special case uris
    console.log uri

    if uri is '/'
        uri = '/index.html'
    
    # Add a song to list
    if uri is '/add'

        console.log query
        unless query.title? 
            res.write '404 No title found\n';
            return

        unless query.user? 
            res.write '404 No user found\n';
            return

        title = query.title
        user = query.user

        addVideo title, user



        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.write '200 OK\n'
        res.end() 
        return

    # upvote a song
    if uri is '/upvote'
        
        unless query.id? 
            res.write '404 No id found\n';
            return

        unless query.user? 
            res.write '404 No user found\n';
            return

        video = queue.getVideoById query.id
        if video is null
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.write '404 Video not found\n'
            res.end()   
            return
        video.upvote query.user
        queue.sendPlaylistUpdate()

        chat.sysMessage query.user, "has upvoted "+video.title

        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.write '200 OK\n'
        res.end()   
        return

    if uri is '/chat'
        unless query.user? 
            res.write '404 No user found\n';
            return

        unless query.msg? 
            res.write '404 No message found\n';
            return

        chat.chat query.user, query.msg

        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.write '200 OK\n'
        res.end()   
        return

    if uri is '/twilio'
        Twilio.httpcall req,res
        return

    if uri is '/geckoboard'
        currentText = 'Nothing'
        currentNumber = 0
        currentVideo = queue.getCurrentVideo()
        if currentVideo.content?
            currentText = currentVideo.content.title 
            currentNumber = currentVideo.content.getScore()
        topList = queue.getTopList()
        
        nextText = 'Nothing'
        nextNumber = 0
        if topList.length > 0
            topElement = topList[0]
            nextText = topElement.title 
            nextNumber = topElement.score

        result = '<?xml version="1.0" encoding="UTF-8"?> 
            <root>  
                <item>  <value>'+currentConnections+'</value>  <text>Connections</text>  </item>  
                <item>  <value>'+currentNumber+'</value>   <text>Currently playing: '+currentText+'</text>  </item> 
                <item>  <value>'+nextNumber+'</value>   <text>Next video: '+nextText+'</text>  </item> 
            </root>'
        res.writeHead 200, {'Content-Type': 'text/xml'}
        res.write result
        res.end() 
        return

    if uri is '/skip'
        unless query.user? 
            res.write '404 No user found\n';
            return

        queue.skipCurrent query.user

        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.write '200 OK\n'
        res.end()   
        return



    # no special case, so use the filesystem
    filename = path.join process.cwd()+"/http/", uri

    path.exists filename, (exists) ->
        unless exists
            console.log "not exists: " + filename
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.write '404 Not Found\n'
            res.end()   
            return
        mimeType = mimeTypes[path.extname(filename).split(".")[1]]
        res.writeHead 200, mimeType
        fileStream = fs.createReadStream filename
        fileStream.pipe res
         



args = process.argv.splice(2);
if args.length < 1 
    port = process.env.VCAP_APP_PORT || 8080
else
    port = args[0]
port = Number(port)
if isNaN port 
    port = process.env.VCAP_APP_PORT || 8080 
# Add ws server to http server
sockServer.installHandlers server, {prefix:'/sock'}

console.log 'Listening on port', port
server.listen port, '0.0.0.0'
    