# trello api key 67ad72d3feb45f7a0a0b3c8e1467ac0b
# trello api token 268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65

TRELLO_API_KEY = "67ad72d3feb45f7a0a0b3c8e1467ac0b"
TRELLO_API_TOKEN = "268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65"

Trello = require 'node-trello'

module.exports = (robot) ->
  robot.hear /trello test/i, (msg) ->
    trello = new Trello TRELLO_API_KEY, TRELLO_API_TOKEN
    trello.get "/1/members/me", (err, data) ->
      if err
        msg.send "保存に失敗しました"
        return
      msg.send "取得ok"
      console.log data
      msg.send data
