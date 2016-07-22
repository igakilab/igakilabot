# Description:
#   trelloからタスクボードの内容を取ってくるスクリプトです
#
# Commadns:
#   タスク - ボードのリストとカードを一覧表示
#   trello test - trelloへの接続を試行、自身のアカウントの情報を取得
#   trellogetcmd <cmd> - <cmd>で指定されたアドレスへGETリクエストを投げる

# trello api key 67ad72d3feb45f7a0a0b3c8e1467ac0b
# trello api token 268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65

TRELLO_API_KEY = "67ad72d3feb45f7a0a0b3c8e1467ac0b"
TRELLO_API_TOKEN = "268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65"
DEFAULT_BOARD = "slackbot-test"

Trello = require 'node-trello'

getBoardByName = (client, boardName, callback) ->
  client.get "/1/members/me/boards", (err, data) ->
    if err then callback err, null; return
    target = null
    for edata in data
      if edata.name is boardName
        target = edata
        break
    callback err, target

getListsByBoardId = (client, boardId, callback) ->
  client.get "/1/boards/#{boardId}/lists", {cards:"open", fields:"name"}, (err, data) ->
    if err then callback err, null; return
    callback err, data


module.exports = (robot) ->
  robot.respond /trello test/i, (msg) ->
    trello = new Trello TRELLO_API_KEY, TRELLO_API_TOKEN
    trello.get "/1/members/me", (err, data) ->
      if err
        msg.send "保存に失敗しました"
        return
      msg.send "取得ok"
      console.log data
      msg.send data

  robot.hear /タスク/, (msg) ->
    trello = new Trello TRELLO_API_KEY, TRELLO_API_TOKEN
    getBoardByName trello, "slackbot-test", (err, data) ->
      if err then msg.send "エラーが発生しました(00)"; return
      unless data? then msg.send "ボードが見つかりません"; return
      getListsByBoardId trello, data.id, (err, data) ->
        if err then msg.send "エラーが発生しました(01)"; return
        msg.send "タスクボードだよ"
        for edata in data
          console.log edata
          msg.send "- #{edata.name} (#{edata.cards.length}) -"
          for card in edata.cards
            msg.send "\t○#{card.name}"



  robot.hear /trellogetcmd (.*)/, (msg) ->
    trello = new Trello TRELLO_API_KEY, TRELLO_API_TOKEN
    cmd = msg.match[1]
    trello.get cmd, (err, data) ->
      if err then msg.send "保存に失敗しました"; return
      console.log data
      msg.send data
