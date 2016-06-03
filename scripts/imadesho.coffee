module.exports = (robot) ->
    robot.hear /いつやるの/, (msg) ->
        reps = [
            "今でしょ！щ（ﾟдﾟщ）"
            "ლ (╯⊙ ⊱ ⊙╰ ლ)今でしょ！"
            "今でしょ！ლ (╯◕◞౪◟◕╰ლ) "
            "（ ´థ౪థ）╭☞ 今でしょ！"
            "今でしょ！(」ﾟωﾟ)」 "
        ]
        msg.send msg.random(reps)

    robot.hear /When\sare\syou\sgonna\sdo\sit\?/, (msg) ->
        reps = [
            "Do it now! щ（ﾟдﾟщ）"
            "ლ (╯⊙ ⊱ ⊙╰ ლ)Do it now!"
            "Do it now! ლ (╯◕◞౪◟◕╰ლ) "
            "（ ´థ౪థ）╭☞ Do it now！"
            "Do it now！(」ﾟωﾟ)」 "
        ]
        msg.send msg.random(reps)

    robot.respond /hayashi\sbomb\s(.*)/i, (msg) ->
      httpget = require './module/httpget.coffee'
      url = "https://raw.githubusercontent.com/igakilab/igakilabot-info/master/imadesho/images.json"
      count = 1
      input = msg.match[1] ? 1
      if 0 <= input <= 10
        count = input
      httpget.httpGetJson robot, url, (er, rs, data) ->
        if er
          msg.send "http get error: #{er}"
        else
          for i in [0...count]
            msg.send msg.random(data)
      
