_ = require 'underscore'

class QueueEntry
    constructor: (@id, @title, @videoLength, @img) ->
        @users = []
        @skipsters = []
        @timestamp = new Date().getTime()
        

    upvote: (user) =>
        if _.include @users, user
            # user has already voted
            return false
        @users.push user
        @timestamp = new Date().getTime()

    skip: (user) =>
        if _.include @skipsters, user
            # user has already voted
            return false
        @skipsters.push user

    getElement: () =>
        return {
            id:          @id
            title:       @title
            img:         @img
            users:       @users
            videoLength: @videoLength,
            score:       @getScore(),
            timestamp:   @timestamp
        }

    getScore: () =>
        return @users.length

module.exports = QueueEntry
