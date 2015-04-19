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

$(document).ready(function() {
    $("#userEntry").dialog({buttons: {"OK": userEntrySubmit}, "modal":true });
    $("#usernameEntry").keypress(function(e) {
        if (e.which==13) {
            userEntrySubmit();
        }
    });
});
var player;
function onYouTubeIframeAPIReady() {
    player = new YT.Player('viedoPlayer', {
        height: '390',
        width: '640',
        playerVars: { 'controls': 0, showinfo: 0, modestbranding: 1, disablekb: 1 },
        events: {
            'onReady': onPlayerReady,
            'onStateChange': onPlayerStateChange
        }
    });
}

function onPlayerReady() {
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

function onPlayerStateChange() {
    console.log('onPlayerStateChange');
}