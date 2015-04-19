var pushClient=function() {
    var sockUrl="/sock";
    function startListening() {
        var sock = new SockJS(sockUrl);

        sock.onopen = function() {
           console.log('open');
        };
        sock.onmessage = function(e) {
           var data = JSON.parse(e.data);
           console.log(data);
           handleMessage(data);
        };
        sock.onclose = function() {
           console.log('close');
        };
    }

    function handleChatMessage(content) {
        ui.addChatMessage($("#chat"),content.user,content.message);
    }

    function handleUpdatePlaylist(content) {
        ui.loadVideoDetails($("#recent"),content.recent);
        ui.loadVideoDetails($("#top"),content.top);
    }

    function handleLoadVideo(content) {
        if (content === null) {
            player.stopVideo();
            player.clearVideo();
            $("#videoTitle").text('');
        } else {
            player.loadVideoById(content.id, content.position);
            player.playVideo();
            $("#videoTitle").text(content.title);
        }

    }

    function handleSkipMessage(content) {
        ui.updateSkipBox($("#skipArea"), content.users, content.needed);
    }

    function handleMessage (msg) {
            if (msg.type=="loadVideo") {
                handleLoadVideo(msg.content);
            } else if (msg.type=="updatePlaylist") {
                handleUpdatePlaylist(msg.content);
            } else if (msg.type=="chat") {
                handleChatMessage(msg.content);
            } else if (msg.type=="skipCount") {
                handleSkipMessage(msg.content);
            }
    }

    return {
        "startListening":startListening
    };
}();
