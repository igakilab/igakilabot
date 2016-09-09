module.exports = (robot) ->
  robot.router.get "/hubot/gettest/", (req, res) ->
    console.log "http request received"
    res.send "test request received!"

  robot.router.post "/hubot/send_message", (req, res) ->
    if req.body.message? and req.body.room?
      robot.send {room:req.body.room}, req.body.message
      res.end "send to #{req.body.room} : #{req.body.message}"
    else
      res.end "messages undefined : #{req.body.room} #{req.body.message}"
