#
# robots
#
jsonUrl = "https://raw.githubusercontent.com/igakilab/igakilabot-info/master/wcatgacha/gachameta.json"

module.exports = (robot) ->
  robot.respond /(白猫.*(11|単)|白猫)/, (res) ->
    gcount = 1
    gmsg = "白猫ガチャシミュレーターだよ"
    if res.match[2] is "11"
      gcount = 11
      gmsg = "白猫ガチャ11連!"

    wcatgacha.httpGetMetadata robot, jsonUrl, (err, hr, meta) ->
      res.send gmsg
      result = wcatgacha.excute meta, gcount
      if not wcatgacha.inTerm meta
        res.send "このガチャは期間外です"
      if wcatgacha.getImageUrl meta
        res.send wcatgacha.getImageUrl(meta)
      resultStr = ""
      for i in [0...result.length]
        resultStr += "#{wcatgacha.getStarString(result[i].rare, 4)}: "
        resultStr += "#{result[i].name} "
        resultStr += "(#{wcatgacha.getJobString(result[i].jobn)})"
        if i < (result.length - 1) then resultStr += "\n"
      res.send resultStr

#shironeko commands
  robot.respond /shironeko\sjsonurl/i, (res) ->
    res.send jsonUrl
  robot.respond /shironeko\shttpgetmeta/i, (res) ->
    robot.http(jsonUrl).get() (err, hr, body) ->
      if err then res.send err
      else res.send body

#
# module
#
wcatgacha =
  defaultMeta: {
    term: null
    charactors: [
      #STAR 2
      {rare:2, jobn:1, name:"ダリア"}
      {rare:2, jobn:1, name:"チャンクス"}
      {rare:2, jobn:1, name:"青銅兵士"}
      {rare:2, jobn:2, name:"ティッツアーノ"}
      {rare:2, jobn:2, name:"フリージア"}
      {rare:2, jobn:2, name:"ブリキ兵士"}
      {rare:2, jobn:3, name:"オデッセイ"}
      {rare:2, jobn:3, name:"コロナリア"}
      {rare:2, jobn:3, name:"黒鋼兵士"}
      {rare:2, jobn:4, name:"セロシア"}
      {rare:2, jobn:4, name:"フライハイト"}
      {rare:2, jobn:4, name:"緑玉兵士"}
      {rare:2, jobn:5, name:"イグニ"}
      {rare:2, jobn:5, name:"ポプラ"}
      {rare:2, jobn:5, name:"白鉄兵士"}
      {rare:2, jobn:6, name:"トムボイ"}
      {rare:2, jobn:6, name:"ルピナス"}
      {rare:2, jobn:6, name:"赤石兵士"}

      #STAR 3
      {rare:3, jobn:1, name:"タツノシン"}
      {rare:3, jobn:1, name:"シャロン"}
      {rare:3, jobn:1, name:"ヨシオ"}
      {rare:3, jobn:1, name:"アヤメ"}
      {rare:3, jobn:2, name:"ウィリアム"}
      {rare:3, jobn:2, name:"ハリム"}
      {rare:3, jobn:2, name:"ヒュウガ"}
      {rare:3, jobn:2, name:"ラズィーヤ"}
      {rare:3, jobn:3, name:"グリーズ"}
      {rare:3, jobn:3, name:"テツヤ"}
      {rare:3, jobn:3, name:"タイキ"}
      {rare:3, jobn:3, name:"アレクサンダー"}
      {rare:3, jobn:4, name:"ヴォルワーグ"}
      {rare:3, jobn:4, name:"マコト"}
      {rare:3, jobn:4, name:"コムギ"}
      {rare:3, jobn:4, name:"セレスティア"}
      {rare:3, jobn:5, name:"フウカ"}
      {rare:3, jobn:5, name:"クリストファー"}
      {rare:3, jobn:5, name:"ミィニャ"}
      {rare:3, jobn:5, name:"ジェニー"}
      {rare:3, jobn:6, name:"アセト"}
      {rare:3, jobn:6, name:"モモ"}
      {rare:3, jobn:6, name:"パン"}
      {rare:3, jobn:6, name:"フィリップ"}
      {rare:3, jobn:7, name:"カグラ"}
      {rare:3, jobn:7, name:"ナップル"}
      {rare:3, jobn:8, name:"テムル"}
      {rare:3, jobn:8, name:"ゼシカ"}

      #STAR 4
      {rare:4, jobn:1, name:"ミカン"}
      {rare:4, jobn:1, name:"トモエ"}
      {rare:4, jobn:2, name:"ジェガル"}
      {rare:4, jobn:2, name:"チャッピー"}
      {rare:4, jobn:3, name:"カルディナ"}
      {rare:4, jobn:3, name:"ロザリー"}
      {rare:4, jobn:4, name:"リンデ"}
      {rare:4, jobn:4, name:"コッペリア"}
      {rare:4, jobn:5, name:"ジョバンニ"}
      {rare:4, jobn:5, name:"ミラ"}
      {rare:4, jobn:6, name:"チェルシー"}
      {rare:4, jobn:6, name:"ミスモノクローム"}
      {rare:4, jobn:7, name:"ノブナガ"}
      {rare:4, jobn:7, name:"エスメラルダ"}
      {rare:4, jobn:8, name:"カモメ"}
      {rare:4, jobn:8, name:"レザール"}
      {rare:4, jobn:9, name:"エイジ"}
      {rare:4, jobn:9, name:"パルメ"}
    ]
    imgUrl: "http://cdn.img-conv.gamerch.com/img.gamerch.com/shironekoproject/1461654671.jpg"
  }

  jobString: [
      "剣士", "武闘家", "ウォリアー", "ランサー", "アーチャー"
      "魔導士", "クロスセイバー", "ドラゴンライダー", "ヴァリアント"
  ]

  probabilities: [
    {value:4, p:7}
    {value:3, p:42}
    {value:2, p:51}
  ]

  random: (ary) ->
    return ary[Math.floor (Math.random() * ary.length)]

  randomRare: (prob, count) ->
    tmp = []
    for pel in prob
      for i in [0...pel.p]
        tmp.push pel.value
    result = []
    for i in [0...count]
      result.push this.random(tmp)
    return result

  getCharactorsByRare: (meta, rnum) ->
    charas = meta.charactors ? defaultMeta.charactors
    result = []
    for ch in charas
      if ch.rare is rnum
        result.push ch
    return result

  getJobString: (jnum) ->
    return this.jobString[jnum - 1]

  getStarString: (scnt, max) ->
    tmax = max ? scnt
    str = ""
    for i in [0...tmax]
      if i < scnt then str += "★"
      else str += "　"
    return str

  getImageUrl: (meta) ->
    return if meta? then meta.imgUrl else null

  termobjToDate: (td) ->
    if td? then return new Date(td.y, td.m, td.d, td.h)
    else return null

  inTerm: (meta) ->
    if !meta? then return false
    if meta.term?
      today = new Date()
      tStart = this.termobjToDate(meta.term.start)
      tEnd = this.termobjToDate(meta.term.end)
      return tStart <= today < tEnd
    else
      return false

  # callback args: (err, res, meta)
  httpGetMetadata: (robot, url, callback) ->
    req = robot.http(url).get()
    req (err, res0, body) ->
      if err
        callback err, res0, null
      else
        meta = null
        try
          meta = JSON.parse body
        catch perr
          callback perr, res0, null
          return
        callback err, res0, meta

  excute: (meta, count) ->
    tmeta = meta ? this.defaultMeta
    rares = this.randomRare this.probabilities, count
    result = []
    for r in rares
      chs = this.getCharactorsByRare tmeta, r
      result.push this.random(chs)
    return result
