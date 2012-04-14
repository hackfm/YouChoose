var pushClient=function() {
    function startListening() {
        var sock = new SockJS('http://ec2-176-34-79-126.eu-west-1.compute.amazonaws.com:8080/sock');

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

    function handleUpdatePlaylist(content) {
        ui.loadVideoDetails($("#recent"),content.recent);
        ui.loadVideoDetails($("#top"),content.top);
    }
    
    function handleLoadVideo(content) {
        youtube.playVideo(content.id);
    }
    function handleMessage (msg) {
            if (msg.type=="loadVideo") {
                handleLoadVideo(msg.content);
            } else if (msg.type=="updatePlaylist") {
                handleUpdatePlaylist(msg.content);
            }
    }
    
    return {
        "startListening":startListening
        };
}();
