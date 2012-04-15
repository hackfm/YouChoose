var ui = function() {
    function loadVideoDetails(container,videoDetails) {
        container.empty();
        $.each(videoDetails, function(i, vd) {
            var videoEntry=$(document.createElement("div"));
            videoEntry.addClass("videoEntry");
            var score=vd.users.length;
            videoEntry.append("<img class='thumbnail' src='"+vd.img+"' />");
            videoEntry.append("<span class='score'>"+score+"</span>");
            if (vd.users.indexOf(username)==-1) {
                videoEntry.append("<span class='upvoteButton'></span>");
                videoEntry.find(".upvoteButton").click(function() {
                    nodeClient.upvote(username, vd.id); 
                });
            } else {
                videoEntry.append("<span class='upvoteDisabled'></span>");
            }
            var mins = Math.floor(vd["videoLength"]/60);
            var secs = (vd["videoLength"]%60);
            durationString = mins+":"+(secs<10?"0":"")+secs;
            
            videoEntry.append("<span class='videoTitle'>"+vd.title+" ("+durationString+")</span>");
            container.append(videoEntry);
        });
    }
    
    function updateSkipBox(container, skippedUsers, skipsNeeded) {
        container.empty();
        container.append("Vote to skip ");
        if (skippedUsers.indexOf(username)==-1) {
            container.append("<span class='skipButton'></span> ");
            container.find(".skipButton").click(function() {
                nodeClient.skip(username); 
            });
        } else {
            container.append("<span class='skipDisabled'></span> ");
        }
        container.append(skippedUsers.length +" of "+skipsNeeded + " required");
    }
    
    function addChatMessage(container, username, text) {
    
        var chatLine = $(document.createElement("div"));
        chatLine.addClass("chatLine");
        var chatUser = $(document.createElement("span"));
        chatUser.addClass("chatUser");
        chatUser.append(document.createTextNode(username+": " ));
        var chatMessage = $(document.createElement("span"))
        chatMessage.addClass("text");
        chatMessage.append(document.createTextNode(text));
        chatLine.append(chatUser);
        chatLine.append(chatMessage);
        container.append(chatLine);
        container.scrollTop(100000);
    }
    return {
        "loadVideoDetails":loadVideoDetails,
        "addChatMessage":addChatMessage,
        "updateSkipBox":updateSkipBox
    };
}();
