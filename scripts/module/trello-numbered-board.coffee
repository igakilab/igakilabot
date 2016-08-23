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
