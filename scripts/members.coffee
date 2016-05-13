#
# robot exports
#
module.exports = (robot) ->

    robot.hear /mem_test/i, (msg) ->
        msg.send memberRegs()

    robot.hear memberRegs(), (msg) ->
        list = getMemberMessages msg.match
        msg.send(msg.random(list))


#
# response rules
#
rules = [
    {
        tokens: ["ueyama", "うえやま", "上山"]
        messages: [
            "井垣研に迷い込んだ小学生"
            "子供か！"
            "かもがわデルタは上山のソウルスポットです"
        ]
    }
    {
        tokens: ["ueda", "うえだ", "上田", "林"]
        messages: [
            "今でしょ\nhttp://cdn-ak.f.st-hatena.com/images/fotolife/y/yuichi724/20150419/20150419161647.jpg"
            "今でしょ\nhttp://dot.asahi.com/S2000/upload/2016021200154_1.jpg"
            "今でしょ\nhttp://suuul.com/wp-content/uploads/2016/04/3375.jpg"
            "今でしょ\nhttp://cdn.advertimes.com/wp-content/uploads/bbd5780e49dc36d4af0bf7d8d69e2e0c.png"
            "今でしょ\nhttp://news.mynavi.jp/news/2013/10/04/051/images/001.jpg"
        ]
    }
    {
        tokens: ["uchida", "うちだ", "内田", "うっち"]
        messages: [
            "内定がないってぇぇぇー！？"
            "卒業に必要なのは単位です"
            "let me share the love with U"
        ]
    }
    {
        tokens: ["yanagida", "ぎだ", "やなぎだ"]
        messages: [
            "ぎださんは..."
            "ほもぎだ？"
            "筋トレグッズはなるべく棚の上に置かないように"
        ]
    }
]

#
# supporter modules
#
arrayToRegs = (ary) ->
    regex = "("
    for i in [0...ary.length]
        regex = "#{regex}#{ary[i]}"
        if i isnt ary.length - 1
            regex = "#{regex}|"
        else regex = "#{regex})"

    return new RegExp("#{regex}", "i")


memberRegs = () ->
    total = []
    for rule in rules
        total = [total..., rule.tokens...]
    return arrayToRegs(total)


getMemberMessages = (str) ->
    num = 0
    for rule in rules
        regex = arrayToRegs(rule.tokens)
        if regex.test(str)
            return rule.messages

    return ["not found"]
