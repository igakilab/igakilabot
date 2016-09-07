Trello = require 'node-trello'
TrelloBoard = require './trello-board'

class TrelloConfigSection
  @getInstance: (client, listId, callback) ->
    url = "/1/lists/#{listId}/cards"
    params = {}
    client.get url, params, (err, res) ->
      if err? then callback err, null; return
      callback err, new TrelloConfigSection client, res, listId

  constructor: (client, data, listId) ->
    this.client = client
    this.data = data
    this.listId = listId
    this.autoReload = true

  reload: (callback) ->
    url = "/1/lists/#{this.listId}/cards"
    params = {}
    thisp = this
    this.client.get url, params, (err, res) ->
      if err then callback err, res; return
      thisp.data = res
      callback err, res

  findCardByName: (key) ->
    for card in this.data
      if card.name is key
        return card
    return null

  get: (key) ->
    card = this.findCardByName key
    return if card? then card.desc else null

  set: (key, value, callback) ->
    thisp = this
    wcallback = (err, res) ->
      if thisp.autoReload
        thisp.reload(callback)
      else
        callback err, res

    card = this.findCardByName key
    if card?
      url = "/1/cards/#{card.id}"
      params = {desc: value}
      this.client.put url, params, wcallback
    else
      url = "/1/lists/#{this.listId}/cards"
      console.log url
      params = {name: key, desc: value}
      this.client.post url, params, wcallback

  getAll: () ->
    values = []
    for card in this.data
      values.push({
        key: card.name, value: card.desc
      })
    return values


class TrelloConfigBoard extends TrelloBoard
  @getInstance: (client, boardId, callback) ->
    url = "/1/boards/#{boardId}"
    options = {lists: "all", cards:"all"}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      board = new TrelloConfigBoard client, data
      callback? err, board

  @getInstanceByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = if idOrg? then "/1/organizations/#{idOrg}/boards"
    else "/1/members/me/boards"
    options = {fields: "name"}
    client.get url, options, (err, boards) ->
      if err then callback? err, null; return
      for board in boards
        if board.name is boardName
          TrelloBoardConfig.getInstance client, board.id, callback
          return
      callback "board not found : #{boardName}", null


  getConfigSection: (listId, callback) ->
    TrelloConfigSection.getInstance this.client, listId, callback

  getConfigSectionByName: (listName, autoCreate, callback) ->
    unless callback? then callback = autoCreate; autoCreate = false
    thisp = this
    list = this.getListByName listName
    if list?
      TrelloConfigSection.getInstance this.client, list.id, callback
    else if autoCreate
      this.createList listName, (err, res) ->
        if err? then callback err, null; return
        TrelloConfigSection.getInstance thisp.client, res.id, callback
    else
      callback "section(list) not found: #{listName}", null


module.exports = TrelloConfigBoard
