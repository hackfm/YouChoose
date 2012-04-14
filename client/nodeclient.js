var nodeClient = function() {
    var clientUrl="http://ec2-176-34-79-126.eu-west-1.compute.amazonaws.com:8080";
    return {
        "add": function(user, title) {
            $.ajax(clientUrl+"/add", {data: {"user": user, "title": title} });
        },
        "upvote": function(user, videoId) {
            $.ajax(clientUrl+"/upvote", {data: {"user": user, "id": videoId}});
        }
    };
}();
