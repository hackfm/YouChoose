_      = require 'underscore'
events = require 'events'

class Queue extends events.EventEmitter
    constructor: () ->
        @videos = []
        @currentVideo = null
        @startedVideoOn = null

    addVideo: (entry) =>
        if @currentVideo is null
            @setCurrentVideo entry
            @emit 'currentVideo'
        else
            @videos.push entry
            @emit 'update'

    setCurrentVideo: (entry) =>
        @currentVideo = entry
        @startedVideoOn = new Date().getTime()

    getSortedList: (sortFunction) =>
        listSorted = _.sortBy @videos, sortFunction
        list = []
        _.each listSorted, (element) =>
            list.push element.getElement()
        return list

    getTopList: () =>
        return @getSortedList (a) ->
            return -a.getScore()

    getRecentList: () =>
        return @getSortedList (a) ->
            return -a.timestamp

    getQueue: () =>
        top    = @getTopList() 
        recent = @getRecentList() 
        return {type: "updatePlaylist", content: {top: top, recent: recent}}

    hasCurrentVideo: () =>
        return @currentVideo isnt null 

    getCurrentVideo: () =>
        if @currentVideo is null
            return {type: "loadVideo", content: null}
        position = new Date().getTime()
        position = position - @startedVideoOn
        position = position - @currentVideo.videoLength
        position = Math.round position / 1000
        content = _.clone @currentVideo
        content.position = position
        return {type: "loadVideo", content: content}

    getVideoById: (id) =>
        video = null
        _.each @videos, (element) =>
            video = element
        return video

    sendPlaylistUpdate: () =>
        @emit 'update'

module.exports = Queue 