var http = require("http");
var url = require("url");

var youtube = module.exports = function(query, callback, errorcallback) {
    var data = "";
    var request = http.get({
        host: "gdata.youtube.com",
        port: 80,
        path: url.format({
            pathname: "/feeds/api/videos",
            query: {
                q: query,
                "max-results": 1,
                alt: "json",
                v: 2
            }
        })
    }, function(res) {
        if (res.statusCode == 200)
        {
            res.on("data", function(chunk) { data += chunk; });
            res.on("end", function() { 
                var results = JSON.parse(data);
                
                var title = results.feed.entry[0].title["$t"];
                var id = results.feed.entry[0]["media$group"]["yt$videoid"]["$t"];
                var length = results.feed.entry[0]["media$group"]["yt$duration"].seconds;
                var thumbnail = results.feed.entry[0]["media$group"]["media$thumbnail"][0]["url"];

                callback(id, title, length, thumbnail);
            });
        }
        else
        {
            errorcallback();
        }
    });
};
