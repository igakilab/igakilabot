Trello = require 'node-trello'

class TrelloBoardCollection
  @getInstanceByMember: (client, memberId, callback) ->
    unless callback? then callback = memberId; memberId = "me"
    url = "/1/members/#{memberId}/boards"
    options = {}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      collection = new TrelloBoardCollection client, data

  @getInstanceByOrganization: (client, orgId, callback) ->
    url = "/1/organizations/#{orgId}/boards"
    options = {}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      collection = new TrelloBoardCollection client, data, orgId

  constructor: (client, data, orgId) ->
    this.client = client
    this.data = data
    this.organizationId = orgId ? null

  getBoard: (boardId) ->
    for board in this.data
      if board.id is boardId
        return board
    return null

  getBoardByName: (boardId) ->
    for board in this.data
      if board.name is boardId
        return board
    return null

  getAllBoards: () ->
    return this.data

  createBoard: (boardName, params, callback) ->
    unless callback? then callback = params; params = {}
    url = "/1/boards"
    params.name = boardName
    params.defaultLists = "false"
    if this.organizationId?
      params.idOrganization = this.organizationId
      pramas.prefs_permissionLevel = "org"
    client.post url, params, callback
