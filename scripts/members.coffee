#
# robot exports
#
memberJsonUrl = "https://raw.githubusercontent.com/igakilab/igakilabot-info/master/labmember/reply.json"

module.exports = (robot) ->

    robot.respond /show\smember\srules/i, (res) ->
      members.httpGetMemberData robot, memberJsonUrl, (er, rs, data) ->
        if er
          res.send "error: #{er}"
        else
          for mb in data
            buffer = ""
            buffer += "tokens: #{members.arrayToRegs mb.tokens}\n"
            buffer += "messages: \n"
            for msg in mb.messages
              buffer += "  #{msg}\n"
            res.send buffer
        return

    members.httpGetMemberData robot, memberJsonUrl, (er, rs, data) ->
      if er
        console.error er
      else
        regex = members.createRegex data
        robot.hear regex, (res) ->
          msgs = members.getMemberMessages data, res.match
          res.send res.random(msgs)

#
# modules
#
members =
  arrayToRegs: (ary) ->
    regex = "("
    for i in [0...ary.length]
      regex = "#{regex}#{ary[i]}"
      if i isnt ary.length - 1
        regex = "#{regex}|"
      else regex = "#{regex})"
    return new RegExp("#{regex}", "i")

  createRegex: (data) ->
    total = []
    for mem in data
      total = [total..., mem.tokens...]
    return this.arrayToRegs total

  getMemberMessages: (data, str) ->
    num = 0
    for mem in data
      regex = this.arrayToRegs mem.tokens
      if regex.test(str)
        return mem.messages
    return ["not found"]

  httpGetMemberData: (robot, url, callback) ->
    req = robot.http(url).get()
    req (err, res, body) ->
      if err
        callback err, res, null
      else
        data = null
        try
          data = JSON.parse body
        catch error
          callback error, res, null
          return
        callback err, res, data
    return
