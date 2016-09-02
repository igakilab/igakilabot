# Description:
#   hubot-trello-numbered-borad.coffeeをテストするスクリプトです。
#
# Commadns:


Trello = require 'node-trello'
TrelloNumberedBoard = require './module/trello-numbered-board'

API_KEY = process.env.HUBOT_TRELLO_KEY
API_TOKEN= process.env.HUBOT_TRELLO_TOKEN
BOARD_ID = "5791b6f247501b7202d6f9c7"
LIST_ID = "5791b6f973756bf8354409b7"

getTaskNumber = (str) ->
  matches = str.match /#([0-9]+)/i
  console.log matches
  if matches?[1]
    return matches[1] - 0
  else
    return null

getBoardId = (client, boardName, callback) ->
  TrelloBOardCollection.getInstanceByMember client, (err, collection) ->
    unless err
      board = collection.getBoardByName boardName
      callback err, if board isnt null then board.id else null
    else
      callback err, null

module.exports = (robot) ->
  robot.hear /sharp (.*)/i, (msg) ->
    number = getTaskNumber msg.match[1]
    if number?
      msg.send "番号は #{number} だよ"
    else
      msg.send "番号が見つからなかったよ"

  robot.hear /ttn createInstance/i, (msg) ->
    client = new Trello API_KEY, API_TOKEN
    console.log TrelloNumberedBoard
    TrelloNumberedBoard.getInstance client, BOARD_ID, (err, board) ->
      console.log board.data

  robot.hear /tnn show/i, (msg) ->
    client = new Trello API_KEY, API_TOKEN
    TrelloNumberedBoard.getInstance client, BOARD_ID, (err, board) ->
      cards = board.getAllCards();
      for card in cards
        num = TrelloNumberedBoard.parseNumber card.name
        msg.send "[#{num}] #{card.name}"

  robot.hear /tnn add (.*)/i, (msg) ->
    cardName = msg.match[1];
    client = new Trello API_KEY, API_TOKEN
    TrelloNumberedBoard.getInstance client, BOARD_ID, (err, board) ->
      board.createNumberedCard LIST_ID, cardName, (err, res) ->
        msg.send res
