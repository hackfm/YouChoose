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
            durationString = Math.floor(vd["videoLength"]/60)+":"+(vd["videoLength"]%60);
            
            videoEntry.append("<span class='videoTitle'>"+vd.title+" ("+durationString+")</span>");
            container.append(videoEntry);
        });
    }
    
    function addChatMessage(container, username, text) {
        var chatLine = $(document.createElement("div"));
        chatLine.addClass("chatLine");
        chatLine.append("<span class='chatUser'>"+username+": </span><span class='text'>"+text+"</span>");
        
    }
    return {
        "loadVideoDetails":loadVideoDetails
    };
}();
