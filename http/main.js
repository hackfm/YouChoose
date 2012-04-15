var username;
var player;

function userEntrySubmit() {
    username=$("#usernameEntry").val();
    if (username=="") { return; }
    $("#userEntry").dialog("close");
    $("#videoArea").show();
}

function videoSubmit() {
    var textbox = $("#videoSubmitInput");
    nodeClient.add(username, textbox.val());
    textbox.val("");
}

function chatSubmit() {
    var msgbox = $("#chatInput");
    nodeClient.chat(username, msgbox.val());
    msgbox.val("");
}



function onYouTubePlayerReady(playerId) {
    player = document.getElementById("ytplayer");
    pushClient.startListening();
    
    $("#videoSubmitInput").keypress(function(e) {
        if(e.which == 13) {
            videoSubmit();
        }
    });
    $("#videoSubmitSubmit").click(videoSubmit);
    
    $("#chatInput").keypress(function(e) {
        if(e.which == 13) {
            chatSubmit();
        }
    });
    
}

$(document).ready(function() {
    $("#userEntry").dialog({buttons: {"OK": userEntrySubmit}, "modal":true });
    $("#usernameEntry").keypress(function(e) {
        if (e.which==13) {
            userEntrySubmit();
        }
    });
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

