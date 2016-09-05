# Description:
#   trello apiからboardの情報を取得して、その中からリストやカードを取り出すクラスです
#   GET /1/boards/[idBoard] で取得できるデータを dataフィールドに保持して取り出します。
#   また、addCardやaddListでカードとリストを追加できますが、一度取得しているデータは
#   更新されないので、getInstanceやreloadでtrelloから最新の情報を取得する必要があります。
#
#   例えば、ボード「test1」のリスト「todo」のカード一覧を出力コードは以下の通りです。
#     api = new Trello TRELLO_API_KEY, TRELLO_API_TOKEN
#     TrelloBoard.getInstanceByName api, "test1", (err, board) ->
#       var listTodo = board.getListByName "todo"
#       var cards = board.getCardsByListId listTodo.id
#       for card in cards
#         console.log "- #{card.name}"


class TrelloBoard
  # trelloからボードの情報を取得して、TrelloBoardインスタンスを新規作成します。
  @getInstance: (client, boardId, callback) ->
    url = "/1/boards/#{boardId}"
    options = {lists: "all", cards:"all"}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      board = new TrelloBoard client, data
      callback? err, board

  # boardNameに該当するボードを検索して、インスタンスを新規作成します。
  @getInstanceByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = if idOrg? then "/1/organizations/#{idOrg}/boards"
    else "/1/members/me/boards"
    options = {fields: "name"}
    client.get url, options, (err, boards) ->
      if err then callback? err, null; return
      for board in boards
        if board.name is boardName
          TrelloBoard.getInstance client, board.id, callback
          return
      callback "board not found : #{boardName}", null

  # ボードを新規作成をします。
  @createBoard: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = "/1/boards"
    options =
      name: boardName
      defaultLists: "false"
      prefs_permissionLevel: "org"
    if idOrg? then options.idOrganization = idOrg
    client.post url, options, callback

  constructor: (client, data) ->
    this.client = client
    this.data = data

  # インスタンス内のdataの情報を更新します。
  reload: (callback) ->
    url = "/1/boards/#{this.data.id}"
    options = {lists: "all", cards:"all"}
    thisp = this
    this.client.get url, options, (err, data) ->
      if err then callback? err, null; return
      thisp.data = data
      callback? err, board

  # listIdで指定されたリストの情報を返します。
  getList: (listId) ->
    for list in this.data.lists
      if list.id is listId
        return list
    return null

  # リスト名がlistNameのリストを検索して、一番最初に該当したものを返します。
  getListByName: (listName) ->
    for list in this.data.lists
      if list.name is listName
        return list
    return null

  # すべてのリストを配列で返します。
  getAllLists: () ->
    return this.data.lists

  # リストを新規作成します。
  createList: (listName, params, callback) ->
    unless callback? then callback = params; params = null
    url = "/1/boards/#{this.data.id}/lists"
    params = params ? {}
    params.name = listName
    this.client.post url, params, callback

  # cardIdで指定されたカードの情報を返します。
  getCard: (cardId) ->
    for card in this.data.cards
      if card.id is cardId
        return card
    return null

  # カード名がcardNameのカードを検索して、一番最初に該当したものを返します。
  getCardByName: (cardName) ->
    for card in this.data.cards
      if card.name is cardName
        return card
    return null

  # listIdで指定されたリストに属するカード一覧を返します。
  getCardsByListId: (listId) ->
    hit = []
    for card in this.data.cards
      if card.idList is listId
        hit.push card
    return hit

  # すべてのカードを返します。
  getAllCards: () ->
    return this.data.cards

  # カードを新規作成します。
  createCard: (listId, cardName, params, callback) ->
    unless callback? then callback = params; params = null
    url = "/1/cards"
    params = params ? {}
    params.name = cardName
    params.idList = listId
    this.client.post url, params, callback

  # cardIdで指定されたカードをlistIdで指定されたリストに移動します。
  cardMoveTo: (cardId, listId, callback) ->
    url = "/1/cards/#{cardId}"
    options = {idList: listId}
    this.client.put url, options, callback

module.exports = TrelloBoard
