TrelloTools = require './module/hubot-trello-tools'

module.exports = (robot) ->
  buttons = ["one", "two", "three", "four", "five"];

  cache = {};

  addReactions = (ts, channel, reactions, callback) ->
    if reactions.length > 0
      tmp = reactions.shift()
      query =
        name: tmp
        timestamp: ts
        channel: channel
      console.log query
      robot.adapter.client._apiCall 'reactions.add', query, (res) ->
        console.log res
        addReactions ts, channel, reactions, callback
    else
      callback?()

  robot.router.post "/hubot/task_notify", (req, res) ->
    if req.body.message? and req.body.room? and req.body.cards?
      #メッセージ整形
      buffer = req.body.message + "\n";
      btns = []
      req.body.cards.forEach (e, i, a) ->
        #絵文字設定
        btn = null
        if i < buttons.length then btn = buttons[i]; btns.push btn
        buffer += "\n#{if btn? then ":#{btn}: " else ""}#{e}"
        req.body.cards[i] = {button:btn, name:e}
      buffer += "\nリアクションを押すとdoneに移動します"
      #クエリ作成
      channelId = robot.adapter.client.getChannelGroupOrDMByName(req.body.room)?.id
      query =
        channel: channelId
        text: buffer
        as_user: true
      #送信
      robot.adapter.client._apiCall 'chat.postMessage', query, (res0) ->
        addReactions res0.ts, channelId, btns, () ->
          #キャッシュに保存
          console.log res0
          cache[channelId] = {board:req.body.room, cards:req.body.cards, ts:res0.ts}
          console.log cache
          #httpレスポンス送信
          res.end "send to #{req.body.room} : #{req.body.message}"
    else
      res.end "messages undefined : #{req.body.room} #{req.body.message}"
  

  robot.adapter.client?.on? 'raw_message', (message) ->
    robotUserId = robot.adapter.client.getUserByName(robot.name).id
    if (/^reaction_(added|removed)$/.test message.type) && (message.user isnt robotUserId)
      #キャッシュ検索
      inf = cache[message.item.channel] ? null
      if inf?
        # ボタンの対応をチェック
        idx = inf.cards.findIndex (e) -> return e.button == message.reaction;
        console.log "CHANNEL: #{message.item.channel}, INDEX: #{idx}"
        if idx >= 0
          #ボタンを無効化
          inf.cards[idx].button = null
          #カードを解析
          target = inf.cards[idx].name
          console.log target
          num = TrelloTools.parseTaskNumber target
          #送信インスタンス生成とカードの移動
          msg = {send: (str) ->
            robot.send {room: inf.board}, str}
          if num?
            TrelloTools.cardMoveToByNumber inf.board, num, "done", msg
          else
            TrelloTools.cardMoveTo inf.board, target, "done", msg
          

