var username;

function userEntrySubmit() {
    username=$("#username").val();
    if (username=="") { return; }
    $("#userEntry").dialog("close");
    $("#videoArea").show();
}

var player;

function onYouTubePlayerReady(playerId) {
    player = document.getElementById("ytplayer");
    pushClient.startListening();
    
    $("#videoSubmission").submit(function() {
        var textbox = $(this).find("[name='title']");
        nodeClient.add(username, textbox.val());
        textbox.val("");
        return false;
    });
    
    $("#chatForm").submit(function() {
        var msg = $(this).find("[name='message']");
        nodeClient.chat(username, msg);
        msg.val("");
        return false;
    });
}

$(document).ready(function() {
    $("#userEntry").dialog({buttons: {"OK": userEntrySubmit}, "modal":true });
    $("#userEntryForm").submit(userEntrySubmit);
});
var youtube=function() {
    function playVideo(videoId,startTime) {
        //var player = document.getElementById("ytplayer");
        player.loadVideoById(videoId,startTime);
    }
    
    swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&version=3&playerapiid=ytplayer",
                       "ytapiplayer", "720", "480", "8", null, null, { allowScriptAccess: "always" }, { id: "ytplayer" });
    
    return {"playVideo":playVideo};
}();

