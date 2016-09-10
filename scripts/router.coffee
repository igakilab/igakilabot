# Description:
#   httpリクエストを受信して処理をするスクリプトです
#
# Commadns:
#   GET  /hubot/gettest - テスト用のurlです。「http request received」を返します
#   POST /hubot/send_message - 与えられた文字列を指定のチャンネルに送信します
#                              json形式で、roomとmessageを指定する必要があります

Dajare = require './module/dajare'

module.exports = (robot) ->
  robot.router.get "/hubot/gettest/", (req, res) ->
    console.log "http request received"
    res.end "http request received"

  robot.router.post "/hubot/send_message", (req, res) ->
    if req.body.message? and req.body.room?
      robot.send {room:req.body.room}, req.body.message
      res.end "send to #{req.body.room} : #{req.body.message}"
    else
      res.end "messages undefined : #{req.body.room} #{req.body.message}"

  robot.router.post "/hubot/dajare", (req, res) ->
    if req.body.room?
      Dajare.getDajareList (err, list) ->
        if err? then res.end "取得できませんでした"; return
        if list.length > 0
          msg = ""
          if req.body.message? then msg = req.body.message + "\n";
          msg += list[Math.floor(Math.random() * list.length)]
          robot.send {room:req.body.room}, msg
          res.end "ダジャレを送信しました\n room:#{req.body.room}\n msg:#{msg}"
        else
          res.end "送信できるダジャレがありません"
    else
      res.end "送信先を指定してください。"
