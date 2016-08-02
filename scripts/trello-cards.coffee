getCardByName = (client, boardId, cardName, callback) ->
  client.get "/1/boards/#{boardId}/cards", (err, data) ->
    if err then callback err, null; return
    target = null
    for edata in data
      if edata.name is cardName
        target = edata
        break
    callback err, target

putCard = (client, cardId, body) ->
  client.put "/1/cards/#{cardId}", body, (err, data) ->
    callback err, data
