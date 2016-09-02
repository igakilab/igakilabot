TrelloBoard = require './trello-board'

class TrelloNumberedBoard extends TrelloBoard
  @getInstance: (client, boardId, callback) ->
    super client, boardId, (err, board) ->
      if err then callback? err, null; return
      nboard = new TrelloNumberedBoard client, board.data
      callback? err, nboard

  @getInstanceByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    super client, boardName, idOrg, (err, board) ->
      if err then callback? err, null; return
      nboard = new TrelloNumberedBoard client, board.data
      callback? err, nboard

  @parseNumber: (str) ->
    matches = str.match /#([0-9]+)/i
    if matches?[1]
      return matches?[1] - 0
    else
      return null

  @parseCardName: (str) ->
    cardName = str.replace /\s*#([0-9]+)\s*/g, ""
    return cardName

  constructor: (client, data) ->
    super(client, data)

  reloadCards: (callback) ->
    url = "/1/boards/#{this.data.id}/cards"
    options = {}
    thisp = this
    this.client.get url, options, (err, data) ->
      if err then callback? err, null; return
      thisp.data.cards = data
      callback? err, data

  getMaxNumber: () ->
    max = 0
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseNumber card.name
      if tmp isnt null and tmp > max
        max = tmp
    return max

  getCardByName: (cardName) ->
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseCardName card.name
      if tmp is name
        return card
    return null

  getCardByNumber: (cardNumber) ->
    for card in this.data.cards
      tmp = TrelloNumberedBoard.parseNumber card.name
      if tmp is cardNumber
        return card
    return null

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
