events = require 'events'

class Chat extends events.EventEmitter
    constructor: () ->
        @setMaxListeners 0

    chat: (user, message) =>
        @emit 'chat', user, message

    sysMessage: (user, message) =>
        @emit 'chat', user, message

module.exports = Chat 