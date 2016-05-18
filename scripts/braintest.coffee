module.exports = (robot) ->
    robot.respond /(.*)を(覚|おぼ)/i, (res) ->
        res.send "#{res.match[1]}を覚えたよ"
        robot.brain.set "btestMsg", res.match[1]
        robot.brain.set "btestWho", res.message.user.name

    robot.respond /(何|なん).*け/i, (res) ->
        val = robot.brain.get "btestMsg"
        if val?
          res.send "#{val}だよ"
        else
          res.send "おきのどくですが ぼうけんのしょは きえてしまいました"

    robot.respond /(誰|だれ).*け/i, (res) ->
        val = robot.brain.get "btestWho"
        if val?
          res.send "#{val}だよ"
        else
          res.send "おきのどくですが ぼうけんのしょは きえてしまいました"

    robot.respond /頭の中.*(見|み)/, (res) ->
        res.send "ほらよ"
        for key, value of robot.brain.data._private
            res.send "#{key}: #{value}"
