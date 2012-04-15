_      = require 'underscore'
events = require 'events'

class Queue extends events.EventEmitter
    constructor: () ->
        @videos = []
        @currentVideo = null
        @startedVideoOn = null
        @setMaxListeners 0
        @connections = 0
        @timeoutId = null

    addVideo: (entry) =>
        if @currentVideo is null
            @setCurrentVideo entry
        else
            @videos.push entry
            @emit 'update'

    shiftTopVideo: () =>
        topVideoId = @getTopList()[0].id
        newVideoList = []
        topVideo = null
        _.each @videos, (element) =>
            if element.id is topVideoId
                topVideo = element
            else
                newVideoList.push element
        @videos = newVideoList
        return topVideo


    setCurrentVideo: (entry) =>
        if entry is null
            @currentVideo = null
            @startedVideoOn = null
            return 
        @currentVideo = entry
        @startedVideoOn = new Date().getTime()
        @timeoutId = setTimeout @skipToNextVideo, (entry.videoLength * 1000)
        @emit 'currentVideo'
        @emit 'update'
        @updateSkip()

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
        top    = @getTopList().slice 0,5
        recent = @getRecentList().slice 0,5
        return {type: "updatePlaylist", content: {top: top, recent: recent}}

    skipCurrent: (user) =>
        if @currentVideo?
            @currentVideo.skip(user)
            @updateSkip()

    updateSkip: () =>
        skipsNeeded = Math.ceil(@connections/2)
        if @currentVideo.skipsters.length >= skipsNeeded
            #skip
            @skipToNextVideo()
        else
            @emit 'skipCount', skipsNeeded, @currentVideo.skipsters

    updateConnectionNumber: (count) =>
        @connections = count


    skipToNextVideo: () =>
        if @videos.length 
            newEntry = @shiftTopVideo()
            @setCurrentVideo newEntry
        else
            @setCurrentVideo null
        clearTimeout @timeoutId

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
            if element.id is id
                video = element
        return video

    sendPlaylistUpdate: () =>
        @emit 'update'

module.exports = Queue 