module.exports =
  httpGetJson: (robot, url, callback) ->
    req = robot.http(url).get()
    req (err, res, body) ->
      if err
        callback err, res, null; return

      else
        pjson = null
        try
          pjson = JSON.parse body
        catch error
          callback error, res, null; return

        callback err, res, pjson; return

    return
