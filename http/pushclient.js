var pushClient=function() {
    function startListening() {
        var sock = new SockJS('http://youchoose.cloudfoundry.com/sock');

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
            alert("Video not found");
        }
        youtube.playVideo(content.id, content.position);
        $("#videoTitle").text(content.title);
    }
    function handleMessage (msg) {
            if (msg.type=="loadVideo") {
                handleLoadVideo(msg.content);
            } else if (msg.type=="updatePlaylist") {
                handleUpdatePlaylist(msg.content);
            } else if (msg.type=="chat") {
                handleChatMessage(msg.content);
            }
    }
    
    return {
        "startListening":startListening
        };
}();
