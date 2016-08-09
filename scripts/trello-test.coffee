Trello = require 'node-trello'
TrelloBoard = require './module/trello-board'

BOARD_ID = "5791b6f247501b7202d6f9c7"
BOARD_NAME = "slackbot-test"
echoData = (err, data) ->
  if err then console.log "ERROR"; console.log err; return
  console.log data

assertError = (err) ->
  if err
    console.log "ERROR"
    console.log err
    return true
  else
    return false

boardGet = (callback) ->
  client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN
  TrelloBoard.getBoardDataByName client, BOARD_NAME, (err, board) ->
    if assertError err then return
    callback board

module.exports = (robot) ->
  robot.hear /tretes boardget/i, (msg) ->
    client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN
    TrelloBoard.getBoardDataByName client, "slackbot-test", echoData

  robot.hear /tretes lists/i, (msg) ->
    boardGet (board) ->
      console.log board.getAllLists()

  robot.hear /tretes cards/i, (msg) ->
    boardGet (board) ->
      console.log board.getAllCards()

  robot.hear /tretes card (.*)/i, (msg) ->
    cardName = msg.match[1]
    boardGet (board) ->
      list = board.getAllLists()[0]
      if list? then board.createCard list.id, cardName, echoData

  robot.hear /tretes list (.*)/i, (msg) ->
    listName = msg.match[1]
    boardGet (board) ->
      board.createList listName, echoData
