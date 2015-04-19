var nodeClient = function() {
    return {
        "add": function(user, title) {
            $.post("/add", {"user": user, "title": title});
        },
        "upvote": function(user, videoId) {
            $.post("/upvote", {"user": user, "id": videoId});
        },
        "chat": function(user, msg) {
            $.post("/chat", {"user": user, "msg": msg});
        },
        "skip": function(user) {
            $.post("/skip", {"user": user});
        }
    };
}();
