Trello = require 'node-trello'
TrelloBoard = require './trello-board'

###
リスト移動例:
  trello = new Trello TRELLO_KEY, TRELLO_TOKEN
  TrelloBoard.getInstanceByName trello, "testboard1", (err, board) ->
    if err then console.log err; return
    card = board.getCardByName "報告書を書く"
    list = board.getListByName "doing"
    board.cardMoveTo card.id, list.id, (err, res) ->
      console.log (if err then "エラー" else "成功しました")
###

createClient = () ->
  apiKey = process.env.HUBOT_TRELLO_KEY
  apiToken = process.env.HUBOT_TRELLO_TOKEN
  return new Trello apiKey, apiToken

assertError = (err, msg) ->
  if err?
    msg.send "エラーが発生しました"
    msg.send err
  return err

getBoardByName = (client, boardName, msg, callback) ->
  TrelloBoard.getInstanceByName client, boardName, (err, board) ->
    if assertError err, msg then return
    callback board

class HubotTrelloTools
  @createKanban: (boardName, orgId, msg) ->
    unless msg? then msg = orgId; orgId = null
    client = createClient();
    TrelloBoard.createBoard client, boardName, orgId,  (err, res) ->
      if assertError err, msg then return
      unless res.id?
        assertError "ボード情報が取得できません", msg; return
      board = new TrelloBoard client, res
      func0_createList = (err, listNames, results) ->
        if assertError err, msg then return
        if listNames.length > 0
          ln = listNames.shift()
          board.createList ln, {pos: "bottom"}, (err, res) ->
            results.push res
            func0_createList err, listNames, results
        else
          msg.send "かんばんを作成しました#{board.data.name}"
      func0_createList null, ["todo", "doing", "done"], []

  @addCard: (boardName, cardName, params, msg) ->
    unless msg? then msg = params; params = {}
    client = createClient();
    TrelloBoard.getInstanceByName client, boardName, (err, board) ->
      if assertError err, msg then return
      lists = board.getAllLists();
      if lists.length > 0
        board.createCard lists[0].id, cardName, params, (err, data) ->
          if assertError err, msg then return
          msg.send "カードを追加しました #{data.name}"
      else
        msg.send "追加可能なリストがありません"

  @cardMoveTo: (boardName, cardName, listName, msg) ->
    client = createClient();
    TrelloBoard.getInstanceByName client, boardName, msg, (board) ->
      card = board.getCardByName cardName
      unless card? then msg.send "カードが見つかりません: #{cardName}"; return
      list = board.getListBYName listName
      unless list? then msg.send "リストが見つかりません: #{listName}"; return
      board.cardMoveTo card.id, list.id, (err, data) ->
        if assertError err, msg then return
        msg.send "カードを#{data.name}に移動しました"


module.exports = HubotTrelloTools
