_      = require 'underscore'
events = require 'events'

class Queue extends events.EventEmitter
    constructor: () ->
        @videos = []
        @currentVideo = null
        @startedVideoOn = null

    addVideo: (entry) =>
        console.log entry
        if @currentVideo is null
            @setCurrentVideo entry
            @emit 'currentVideo'
        else
            @videos.push entry
            console.log 'updateQueue'
            @emit 'update'

    setCurrentVideo: (entry) =>
        @currentVideo = entry
        @startedVideoOn = new Date().getTime()

    getSortedList: (sortFunction) =>
        list = []
        _.each @videos, (element) =>
            list.push element.getElement()
        # sort here
        return list

    getTopList: () =>
        return @getSortedList (a) ->
            return a.getSortedList()

    getRecentList: () =>
        return @getSortedList (a) ->
            return a.timestamp

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

module.exports = Queue 