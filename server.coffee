http       = require 'http'
sockjs     = require 'sockjs'
url        = require 'url'
path       = require 'path'
fs         = require 'fs'
Queue      = require './Queue'
QueueEntry = require './QueueEntry'
youtube    = require './youtube'

# MIME Types
mimeTypes = 
    html: "text/html"
    jpeg: "image/jpeg"
    jpg:  "image/jpeg"
    png:  "image/png"
    js:   "text/javascript"
    css:  "text/css"

# Socket Server
sockServer = sockjs.createServer()
sockServer.on 'connection', (conn) ->
    #conn.on 'data', (message) ->
    #    conn.write message
    conn.on 'close', () ->
        console.log 'close'

    sendUpdate = () =>
        conn.write JSON.stringify queue.getQueue()

    sendCurrentVideo = () =>
        conn.write JSON.stringify queue.getCurrentVideo()

    queue.on 'update', sendUpdate
    queue.on 'currentVideo', sendCurrentVideo

    # Send updates
    if queue.hasCurrentVideo()
        sendCurrentVideo()
    sendUpdate()

# Start queue
queue = new Queue()
youtube 'heretics - don\'t be late', (id, title, length, image) =>
    entry = new QueueEntry id, title, length, image
    entry.upvote 'default user'
    queue.addVideo entry
youtube 'Google Maps 8-bit for NES', (id, title, length, image) =>
    entry = new QueueEntry id, title, length, image
    entry.upvote 'default user'
    queue.addVideo entry


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


# Start a http server
server = http.createServer (req, res) ->

    crossDomainHeaders req, res

    uri = url.parse(req.url).pathname; 
    query = url.parse(req.url, true).query;
    # TODO: check some special case uris
    console.log uri
    
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

        youtube title, (id, title, length, image) =>
            entry = new QueueEntry id, title, length, image
            entry.upvote user
            queue.addVideo entry

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
        video.upvote query.user
        queue.sendPlaylistUpdate()

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
         

# Add ws server to http server
sockServer.installHandlers server, {prefix:'/sock'}
server.listen 8888, '0.0.0.0'