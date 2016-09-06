Trello = require 'node-trello'
TrelloBoard = require './trello-board'

class TrelloConfigSection
  @getInstance: (client, listId, callback) ->
    url = "/1/lists/#{listId}/cards"
    params = {}
    client.get url, params, (err, res) ->
      if err? then callback err, null; return
      callback err, new TrelloConfigSection client, res

  constructor: (client, data) ->
    this.client = client;
    this.data = data
    this.autoReload = true

  reload: (callback) ->
    url = "/1/lists/#{listId}/cards"
    params = {}
    thisp = this
    client.get url, params, (err, res) ->
      if err then callback err, res; return
      thisp.data = res

  findCardByName: (key) ->
    for card in this.data
      if card.name? is key
        return card
    return null

  get: (key) ->
    card = findCardByName key
    return if card? then card.desc else null

  set: (key, value, callback) ->
    thisp = this
    wcallback = (err, res) ->
      if thips.autoReload
        thisp.reload(callback)
      else
        callback err, res

    card = findCardByName key
    if card?
      url = "/1/cards/#{card.id}"
      params = {desc: value}
      this.client.put url, params, wcallback
    else
      url = "/1/lists/#{listId}/cards"
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
  getConfigSection: (listId, callback) ->
    TrelloConfigSection.getInstance listId, callback

  getConfigSectionByName: (listName, callback) ->
    list = this.getListByName listName
    if list?
      TrelloConfigSection.getInstance list.id, callback
    else
      callback "section(list) not found: #{listName}", null
