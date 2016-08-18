getTaskNumber = (str) ->
  matches = str.match /#([0-9]+)/i
  console.log matches
  if matches?[1]
    return matches[1] - 0
  else
    return null

module.exports = (robot) ->
  robot.hear /sharp (.*)/i, (msg) ->
    number = getTaskNumber msg.match[1]
    if number?
      msg.send "番号は #{number} だよ"
    else
      msg.send "番号が見つからなかったよ"
