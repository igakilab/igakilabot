module.exports = (robot) ->
  robot.router.get "/hubot/gettest/", (req, res) ->
    console.log "http request received"
    res.send "test request received!"
