class TrelloBoard
  @getBoardData: (client, boardId, callback) ->
    url = "/1/boards/#{boardId}"
    options = {lists: "all", cards:"all"}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      board = new TrelloBoard client, data
      callback? err, board

  @getBoardDataByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = if idOrg? then "/1/organizations/#{idOrg}/boards"
    else "/1/members/me/boards"
    options = {fields: "name"}
    client.get url, options, (err, boards) ->
      if err then callback? err, null; return
      for board in boards
        if board.name is boardName
          TrelloBoard.getBoardData client, board.id, callback
          return
      callback "board not found : #{boardName}", null

  @createBoard: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = "/1/boards"
    options = {name: boardName}
    if idOrg? then options.idOrganization = idOrg
    client.post url, options, callback

  constructor: (client, data) ->
    this.client = client
    this.data = data

  getList: (listId) ->
    for list in this.data.lists
      if list.id is listId
        return list
    return null

  getListByName: (listName) ->
    for list in this.data.lists
      if list.name is listName
        return list
    return null

  getAllLists: () ->
    return this.data.lists

  createList: (listName, callback) ->
    url = "/1/boards/#{this.data.id}/lists"
    options = {name: listName}
    this.client.post url, options, callback

  getCard: (cardId) ->
    for card in this.data.cards
      if card.id is cardId
        return card
    return null

  getCardByName: (cardName) ->
    for card in this.data.cards
      if card.name is cardName
        return card
    return null

  getCardsByListId: (listId) ->
    hit = []
    for card in this.data.cards
      if card.idList is listId
        hit.push card
    return hit

  getAllCards: () ->
    return this.data.cards

  createCard: (listId, cardName, callback) ->
    url = "/1/cards"
    options = {name: cardName, idList: listId}
    this.client.post url, options, callback

  cardMoveTo: (cardId, listId, callback) ->
    url = "/1/cards/#{cardId}"
    options = {idList: listId}
    this.client.put url, options, callback

module.exports = TrelloBoard
