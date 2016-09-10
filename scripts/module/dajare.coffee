Cheerio = require 'cheerio-httpcli'

DEFAULT_URL = "http://dajare.jp/ranking/"

module.exports =
  list: (url, callback) ->
    unless callback? then callback = url; url = DEFAULT_URL

    Cheerio.fetch url, (err, $, res) ->
      if err? then callback? err, null; return

      list = []
      $(".ListWorkBody a").each () ->
        list.push $(this).text()
      callback err, list


  random: (url, callback) ->
    unless callback? then callback = url; url = DEFAULT_URL

    this.list url, (err, res) ->
      if err? then callback? err, null; return
      if res.length > 0
        callback? err, res[Math.floor(Math.random() * res.length)]
      else
        callback? "ダジャレがありません", null
