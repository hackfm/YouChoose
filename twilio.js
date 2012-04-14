module.exports = {};
var http = require("http");
var url = require("url");
var qs = require("querystring");

var handle_request = function(req, res, callback) {
    var data = "";
    req.on("data", function(chunk) { data += chunk; });
    req.on("end", function() { req_complete(req, res, callback, data); }.bind(this) );
};

var req_complete = function(req, res, callback, incoming_data) {
    try
    {
        var data = qs.parse(incoming_data);
        callback(data.Body, data.From);
        
        res.setHeader("Content-type", "text/plain");
        res.writeHead(200);
        res.write("Your vote has been counted. Thank you.");
        res.end();
    }
    catch (e)
    {
        console.log("Twilio callback server caught an exception");
    }
};

var TwilioServer = module.exports = function(callback, port) {
    this.port = port || 8070;
    this.callback = callback;
    
    this.httpserver = http.createServer(function(req, res) {
        handle_request(req, res, callback);
    }).listen(this.port);
};
