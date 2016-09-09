# Description:
#   httpリクエストを受信して処理をするスクリプトです
#
# Commadns:
#   GET  /hubot/gettest - テスト用のurlです。「http request received」を返します
#   POST /hubot/send_message - 与えられた文字列を指定のチャンネルに送信します
#                              json形式で、roomとmessageを指定する必要があります

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
