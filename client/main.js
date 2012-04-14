var username;

function userEntrySubmit() {
    username=$("#username").val();
    if (username=="") { return; }
    $(this).dialog("close");
    $("#videoArea").show();
}

var player;

function onYouTubePlayerReady(playerId) {
    player = document.getElementById("ytplayer");
    
    //username="DavW";
    pushClient.startListening();
    $("#videoSubmission").submit(function() {
        var textbox = $(this).find("[name='title']")
        nodeClient.add(username, textbox.val());
        textbox.val("");
        return false;
    });
}

$(document).ready(function() {
    $("#userEntry").dialog({buttons: {"OK": userEntrySubmit}, "modal":true });
});
var youtube=function() {
    function playVideo(videoId) {
        //var player = document.getElementById("ytplayer");
        player.loadVideoById(videoId);
    }
    
    swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&version=3&playerapiid=ytplayer",
                       "ytapiplayer", "720", "480", "8", null, null, { allowScriptAccess: "always" }, { id: "ytplayer" });
    
    return {"playVideo":playVideo};
}();

