module.exports =
  trello:
    key: "67ad72d3feb45f7a0a0b3c8e1467ac0b"
    token: "268c74e1d0d1c816558655dbe438bb77bcec6a9cd205058b85340b3f8938fd65"
    dataPrinter: (err, data) ->
      if err then console.log "ERROR"; console.log err; return
      console.log data
    
