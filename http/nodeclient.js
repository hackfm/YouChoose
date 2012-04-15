var nodeClient = function() {
    var clientUrl="http://youchoose.cloudfoundry.com";
    return {
        "add": function(user, title) {
            $.ajax(clientUrl+"/add", {data: {"user": user, "title": title} });
        },
        "upvote": function(user, videoId) {
            $.ajax(clientUrl+"/upvote", {data: {"user": user, "id": videoId}});
        },
        "chat": function(user, msg) {
            $.ajax(clientUrl+"/chat", {data: {"user": user, "msg": msg}});
        }
    };
}();
