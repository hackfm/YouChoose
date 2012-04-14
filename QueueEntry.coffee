_ = require 'underscore'

class QueueEntry
    constructor: (@id, @title, @videoLength, @img) ->
        @users = []
        @timestamp = new Date().getTime()
        

    upvote: (user) =>
        if _.include @users, user
            # user has already voted
            return false
        @users.push user

    getElement: () =>
        return {
            id:          @id
            title:       @title
            img:         @img
            users:       @users
            videoLength: @videoLength
        }

    getScore: () =>
        return @users.length

module.exports = QueueEntry
