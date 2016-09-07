Trello = require 'node-trello'
TrelloBoardConfig = require './trello-board-config'

configBoardId = "57cf85f5cdd3d02fbead62b6"
client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN

console.log "start!"
TrelloBoardConfig.getInstance client, configBoardId, (err, res) ->
  if err? then console.log err; return
  res.getConfigSectionByName "test", true, (err, res0) ->
    if err? then console.log err; return
    res0.set "key1", "val2", (err, res1) ->
      if err? then console.log err; return
      console.log res0.get("key1")
