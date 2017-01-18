_ = require 'lodash'

{Promise} = require 'es6-promise'

Trello = require 'node-trello'
TrelloTools = require "./module/hubot-trello-tools"
TrelloBoard = require './module/trello-board'
TrelloBoardCollection = require './module/trello-board-collection'
TrelloNumberedBoard = require "./module/trello-numbered-board"

Emoji = {

  up : 'point_up'

}

module.exports = (robot) ->
  games = {}

  postMessage = (message, channelId) -> new Promise (resolve) ->
    robot.adapter.client._apiCall 'chat.postMessage',
      channel: channelId
      text   : message
      as_user: true
    , (res) -> resolve res

  updateMessage = (message, channelId, ts) -> new Promise (resolve, reject) ->
    robot.adapter.client._apiCall 'chat.update',
      channel: channelId
      text   : message
      ts     : ts
    , (res) ->
      if res.ok then resolve(res) else reject(new Error res.error)

  addReaction = (name, channelId, ts) -> new Promise (resolve) ->
    robot.adapter.client._apiCall 'reactions.add',
      name     : name
      timestamp: ts
      channel  : channelId
    , (res) -> resolve res

  genBtn = (game, channelId) ->
    postMessage(game, channelId)
    .then (res) ->
      games[res.ts] = game
      [Emoji.up].reduce((curr, name) ->
        curr.then(-> addReaction(name, channelId, res.ts))
      , Promise.resolve())

###
  robot.adapter.client?.on? 'raw_message', (message) ->
    robotUserId = robot.adapter.client.getUserByName(robot.name).id
    if (/^reaction_(added|removed)$/.test message.type) && (message.user isnt robotUserId)
      emojiKey = _.findKey Emoji, (emoji) -> emoji is message.reaction
      ts = message.item.ts
      channelId = message.item.channel
      client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN
      TrelloBoard.getInstanceByName client, channelId, (err, board) ->
        if err then console.log err; return
        list = TrelloBoard.getListByName "doing"
        CDlist = TrelloBoard.getCardsByListId list
      game = games[ts]
      if game && /^(up)$/.test emojiKey
        for i,val of CDlist
          TrelloTools.cardMoveTo(channelId,val.name,"done",message)
        updateMessage('カードを移動しました。', channelId, ts)
        .catch (e) ->
          if e.message is 'edit_window_closed' and games[ts]?
            delete games[ts]
            genBtn(game, channelId)
          else
            Promise.reject e

  robot.respond /testbtn/, (msg) ->
    unless robot.adapter?.client?._apiCall?
      msg.send 'This script runs only with hubot-slack.'
      return

    channelId = robot.adapter.client.getChannelGroupOrDMByName(msg.envelope.room)?.id
    genBtn('ok', channelId)

###

###
  robot.router.post "/hubot/task_notify", (req, res) ->
    if req.body.room?
      TrelloTools.cardString req.body.room, (err, res) ->
        if err? then msg.send err; return
        robot.send {room:req.body.room}, res
        channelId = robot.adapter.client.getChannelGroupOrDMByName(msg.envelope.room)?.id
        genBtn(req.body.room, channelId)
      res.end "room: #{req.body.room}"
    else
      res.end "room name is undefined"
###
