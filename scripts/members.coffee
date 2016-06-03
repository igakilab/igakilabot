#
# robot exports
#
memberJsonUrl = "https://raw.githubusercontent.com/igakilab/igakilabot-info/master/labmember/reply.json"

module.exports = (robot) ->

  httpget = require './module/httpget.coffee'


  httpget.httpGetJson robot, memberJsonUrl, (er, rs, data) ->
    if er
      res.send "error: #{er}"
    else
      reg = members.createRegex data
      robot.hear reg, (res) ->
        msglist = members.getMemberMessages data, res.match
        res.send res.random(msglist)



  robot.respond /show\smember\srules/i, (res) ->
    httpget.httpGetJson robot, memberJsonUrl, (er, rs, data) ->
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
