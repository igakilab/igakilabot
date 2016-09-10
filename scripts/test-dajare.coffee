# Description:
#  this is description
# Commadns:
#

Dajare = require './module/dajare'

module.exports = (robot) ->
  robot.hear /dajare test/i, (msg) ->
    Dajare.getDajareList null, (err, res) ->
      console.log res
