Cheerio = require 'cheerio-httpcli'

DEFAULT_URL = "http://dajare.jp/ranking/"

module.exports =
  getDajareList: (url, callback) ->
    unless callback? then callback = url; url = DEFAULT_URL

    Cheerio.fetch url, (err, $, res) ->
      if err? then callback? err, null; return

      list = []
      $(".ListWorkBody a").each () ->
        list.push $(this).text()
      callback err, list
