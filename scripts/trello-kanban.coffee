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

module.exports = (robot) ->
  robot.respond /(.*)を追加/i, (msg) ->
    title = msg.match[1]
    room = msg.message.room
    TrelloTools.addNumberedCard room, title, msg

  robot.respond /今から(.*)/i, (msg) ->
    arrCards = msg.match[1].split(",")
    for val, i in arrCards
      title = val
      num = TrelloTools.parseTaskNumber val
      room = msg.message.room
      if num?
        TrelloTools.cardMoveToByNumber room, num, "doing", msg
      else
        TrelloTools.cardMoveTo room, title, "doing", msg

  robot.respond /(.*)が終わり/i, (msg) ->
    arrCards = msg.match[1].split(",")
    for val, i in arrCards
      title = val
      num = TrelloTools.parseTaskNumber val
      room = msg.message.room
      if num?
        TrelloTools.cardMoveToByNumber room, num, "done", msg
      else
        TrelloTools.cardMoveTo room, title, "done", msg

  robot.respond /タスク.*表示/i, (msg) ->
    room = msg.message.room
    TrelloTools.printKanban room, msg

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
