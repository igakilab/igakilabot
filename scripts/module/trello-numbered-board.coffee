# Description:
#    trello apiからboardの情報を取得して、リストやカードを取り出すクラスです。
#    このクラスにはタスクに#から始まるタスク番号をつけたり、番号でタスクを操作するための
#    実装がされています。trello-boardを継承したクラスで実装されています。
#    番号でタスクを取得するときは、getCardByNumberで、
#    番号を付けてタスクを追加するときはcreateNumberedCardを使用します。
#
#    例えば、ボード「test1」からタスク番号が3のカードを取得し、
#    「doing」のリストに移動するコードは以下の通りです。
#      api = new Trell TRELLO_API_KEY, TRELLO_API_TOKEN
#      TrelloBoard.getInstanceByName api, "test1", (err, board) ->
#        var listDoing = board.getListByName("todo");
#        var cardN3 = board.getCardsByNumber(3);
#        if( listDoing? and cardN3? ){
#          board.cardMoveTo cardN3.id, listDoing.id, null
#        }

TrelloBoard = require './trello-board'

class TrelloNumberedBoard extends TrelloBoard
  # trelloからボードの情報を取得して、TrelloNumberedBoardインスタンスを新規作成します。
  @getInstance: (client, boardId, callback) ->
    super client, boardId, (err, board) ->
      if err then callback? err, null; return
      nboard = new TrelloNumberedBoard client, board.data
      callback? err, nboard

  # boardNameに該当するボードを検索して、インスタンスを新規作成します。
  @getInstanceByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    super client, boardName, idOrg, (err, board) ->
      if err then callback? err, null; return
      nboard = new TrelloNumberedBoard client, board.data
      callback? err, nboard

  # 文字列の中から"#[数字]"のマッチングを調べて、数字を返します。
  @parseNumber: (str) ->
    matches = str.match /#([0-9]+)/i
    if matches?[1]
      return matches?[1] - 0
    else
      return null

  # 文字列の中から"#[数字]"のマッチングがあればそこを削除して、
  # 数字がない状態の文字列を返します。
  @parseCardName: (str) ->
    cardName = str.replace /\s*#([0-9]+)\s*/g, ""
    return cardName

  constructor: (client, data) ->
    super(client, data)

  # カードの情報のみを更新します。
  reloadCards: (callback) ->
    url = "/1/boards/#{this.data.id}/cards"
    options = {}
    thisp = this
    this.client.get url, options, (err, data) ->
      if err then callback? err, null; return
      thisp.data.cards = data
      callback? err, data

  # カードの中で一番大きいタスク番号を返します。
  getMaxNumber: () ->
    max = 0
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseNumber card.name
      if tmp isnt null and tmp > max
        max = tmp
    return max

  # カード名がcardNameのカードを検索します。
  # タスク番号の記述があった場合はそれを削除して、比較します。
  getCardByName: (cardName) ->
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseCardName card.name
      if tmp is name
        return card
    return null

  # タスク番号でカードを検索します。
  getCardByNumber: (cardNumber) ->
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseNumber card.name
      if tmp is cardNumber
        return card
    return null

  # タスク番号を自動的に付加してタスクを登録します。
  # もし#[番号]を含んだカード名が指定された場合は、
  # 自動的に新しい番号をつけようとしません。
  createNumberedCard: (listId, cardName, params, callback) ->
    unless callback? then callback = params; params = null
    if TrelloNumberedBoard.parseNumber(cardName) isnt null
      this.createCard listId, cardName, params, callback
    else
      thisp = this;
      this.reloadCards (err, res) ->
        if err then callback? err, null; return
        num = thisp.getMaxNumber() + 1
        thisp.createCard listId, "\##{num} #{cardName}", params, callback


module.exports = TrelloNumberedBoard
