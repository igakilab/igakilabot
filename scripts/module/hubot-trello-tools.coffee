Trello = require 'node-trello'
TrelloBoard = require './trello-board'
TrelloBoardCollection = require './trello-board-collection'
TrelloNumberedBoard = require "./trello-numbered-board"

ORGANIZATION_ID = "igakilab1"

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

createKanban = (boardCollection, boardName, callback) ->
  boardCollection.createBoard boardName, (err, res) ->
    if err? then callback err, null; return
    board = new TrelloBoard boardCollection.client, res
    func0_createList = (err, listNames, results) ->
      if err? then callback err, null; return
      if listNames.length > 0
        ln = listNames.shift()
        board.createList ln, {pos: "bottom"}, (err, res0) ->
          results.push res0
          func0_createList err, listNames, results
      else
        callback null, res
    func0_createList null, ["todo", "doing", "done"], []

getCollection = (client, orgId, callback) ->
  unless callback? then callback = orgId; orgId = null;
  if orgId?
    TrelloBoardCollection.getInstanceByOrganization client, orgId, callback
  else
    TrelloBoardCollection.getInstanceByMember client, callback

getBoardByName = (client, boardName, autoCreate, msg, callback) ->
  getCollection client, ORGANIZATION_ID, (err, collection) ->
    if assertError err, msg then return
    board = collection.getBoardByName boardName
    if board?
      TrelloNumberedBoard.getInstance client, board.id, (err, res) ->
        if assertError err, msg then return
        callback res
    else if autoCreate
      createKanban collection, boardName, (err, res0) ->
        if assertError err, msg then return
        TrelloNumberedBoard.getInstance client, res0.id, (err, res1) ->
          if assertError err, msg then return
          callback res1
    else
      assertError "ボードがみつかりません", msg


class HubotTrelloTools
  # かんばんを作成します。
  # - ボードを新規作成
  # - 「todo」「doing」「done」のリストを追加
  # 古いまま
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

  #カードを新規作成します。
  @addCard: (boardName, cardName, params, msg) ->
    unless msg? then msg = params; params = {}
    client = createClient();
    getBoardByName client, boardName, true, msg, (board) ->
      lists = board.getAllLists();
      if lists.length > 0
        board.createCard lists[0].id, cardName, params, (err, data) ->
          if assertError err, msg then return
          msg.send "カードを作成しました#{data.name}"
      else
        msg.send "追加可能なリストがありません"

  # カードを移動します。
  @cardMoveTo: (boardName, cardName, listName, msg) ->
    client = createClient();
    getBoardByName client, boardName, false, msg, (board) ->
      card = board.getCardByName cardName
      unless card? then msg.send "カードが見つかりません: #{cardName}"; return
      list = board.getListByName listName
      unless list? then msg.send "リストが見つかりません: #{listName}"; return
      board.cardMoveTo card.id, list.id, (err, data) ->
        if assertError err, msg then return
        msg.send "カードを#{list.name}に移動しました"

  # 看板のタスクを一覧表示します。
  # 古いまま
  @printKanban: (boardName, orgId, msg) ->
    unless msg? then msg = orgId; orgId = null
    client = createClient()
    printBoard = (boardId, msg) ->
      TrelloBoard.getInstance client, boardId, (err, board) ->
        if assertError err, msg then return
        lists = board.getAllLists()
        for list in lists
          cards = board.getCardsByListId list.id
          msg.send "--- #{list.name} (#{cards.length}) ---"
          for card in cards
            msg.send "> #{card.name}"
    getCollectionCallback = (err, collection) ->
      if assertError err, msg then return
      bdata = collection.getBoardByName boardName
      if bdata?
        printBoard bdata.id, msg
      else
        msg.send "かんばんがみつかりません"
    if orgId?
      TrelloBoardCollection.getInstanceByOrganization client, orgId, getCollectionCallback
    else
      TrelloBoardCollection.getInstanceByMember client, getCollectionCallback

  # カードを追加します。そのとき、タスクの番号を自動的にふります。
  # すでにcardName内に番号を指定していた場合は、それを上書きしません。
  @addNumberedCard: (boardName, cardName, params, msg) ->
    unless msg? then msg = params; params = {}
    client = createClient();
    getBoardByName client, boardName, true, msg, (board) ->
      lists = board.getAllLists();
      if lists.length > 0
        board.createNumberedCard lists[0].id, cardName, params, (err, data) ->
          if assertError err, msg then return
          msg.send "カードを追加しました #{data.name}"
      else
        msg.send "追加可能なリストがありません"

  # カード番号でカードを識別して、目的のリストに移動させます。
  @cardMoveToByNumber: (boardName, taskNumber, listName, msg) ->
    client = createClient();
    getBoardByName client, boardName, false, msg, (board) ->
      card = board.getCardByNumber taskNumber
      unless card? then msg.send "カードが見つかりません: No.#{taskNumber}"; return
      list = board.getListByName listName
      unless list? then msg.send "リストが見つかりません: #{listName}"; return
      board.cardMoveTo card.id, list.id, (err, data) ->
        if assertError err, msg then return
        msg.send "カードを#{list.name}に移動しました"

  @parseTaskNumber: (str) ->
    return TrelloNumberedBoard.parseNumber str

  @setAssign = (boardName, cardName, msg) ->
    client = createClient();
    getBoardByName client, boardName, false, msg, (board) ->
      lists = board.getAllLists();
      if lists.length > 0
        card = board.getCardByName cardName
        if card.length > 0
          board.setAssign card.id, msg.message.name

module.exports = HubotTrelloTools
