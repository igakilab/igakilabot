# Description:
#   trelloからタスクを取ってくるコマンド集です
#
# Commands:
#   タスクを表示 - ボードのリストとカードを一覧表示
#   [タスク名]を表示 - [タスク名]をボードに追加します。
#   今から([タスク名],#[タスク番号]) - [タスク名]のタスクをdoingに移動します
#   ([タスク名],#[タスク番号])が終わり - [タスク名]のタスクをdoneに移動します
#   タスクヘルプ - ヘルプを表示します

# trello api key 67ad72d3feb45f7a0a0b3c8e1467ac0b
# trello api token 268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65

TrelloTools = require './module/hubot-trello-tools'
urlBase = 'http://150.89.234.253:8096/'

module.exports = (robot) ->
  robot.respond /(.*)を追加/i, (msg) ->
    title = msg.match[1]
    room = msg.message.room
    TrelloTools.addNumberedCard room, title, msg
    card = TrelloTools.parseCard title, msg
    robot.brain.data "setcard", card
    msg.send "追加したカードを今のイテレーションに追加しますか？"

  robot.respond /(.*)はい/i, (msg) ->
    card = robot.brain.get "setcard"
    if card is null 
    boardId = TrelloTools.parseBoard msg.message.room, msg
    msg.http(urlBase+'tasks-monitor/dwr/jsonp/HubotApi/getCurrentSprint/'+boardId).get() (err, res, body) ->
      msg.http(urlBase+'tasks-monitor/dwr/jsonp/HubotApi/addSprintCard/'+boardId+'/'+card.id+'/'+"#{msg.message.user.name}").post() (err, res, body) ->
        msg.send "カードをイテレーションに追加しました"


  robot.respond /今から(.*)/i, (msg) ->
    arrCards = msg.match[1].trim().split /\s+/
    console.log arrCards
    for val, i in arrCards
      title = val
      num = TrelloTools.parseTaskNumber val
      room = msg.message.room
      if num?
        TrelloTools.cardMoveToByNumber room, num, "doing", msg
      else
        TrelloTools.cardMoveTo room, title, "doing", msg

  robot.respond /(.*)が終わり/i, (msg) ->
    arrCards = msg.match[1].trim().split /\s+/
    console.log arrCards
    for val, i in arrCards
      title = val
      num = TrelloTools.parseTaskNumber val
      room = msg.message.room
      if num?
        TrelloTools.cardMoveToByNumber room, num, "done", msg
      else
        TrelloTools.cardMoveTo room, title, "done", msg
    TrelloTools.nokoriString room, msg

  robot.respond /タスク.*表示/i, (msg) ->
    room = msg.message.room
    TrelloTools.printKanban room, msg

  robot.respond /testd/i, (msg) ->
    room = msg.message.room
    TrelloTools.cardString room, msg

  robot.respond /タスクヘルプ/i, (msg) ->
    desc = [
      "トレロと連携しているかんばんタスク管理です。"
      "ここで登録されたタスクは、trelloでチャンネル名のボードに登録されます"
      "<使い方>"
      "  タスクを表示 - ボードのリストとカードを一覧表示"
      "  [タスク名]を表示 - [タスク名]をボードに追加します。"
      "  今から([タスク名],#[タスク番号]) - [タスク名]のタスクをdoingに移動します "
      "  ([タスク名],#[タスク番号])が終わり - [タスク名]のタスクをdoneに移動します"
      "  タスクヘルプ - ヘルプを表示します"
    ]
    for line in desc
      msg.send line
