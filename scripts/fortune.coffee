# fortunes
module.exports = (robot) ->
    robot.respond /(運|fortune)/i, (msg) ->
        result = fortunes.get()
        msg.reply "あなたの運勢は #{result.sub} \n #{result.des}"


fortunes =
    subjects: [
        "大吉"
        "吉"
        "凶"
        "大凶"
        "絶凶"
        "破滅級"
    ]
    descriptions: [
        "よかったね！"
        "今日はいたって普通の一日になるでしょう"
        "ちょっとしたミスに注意"
        "今日はついてないね、でも明日があるさ"
        "大事なことは避けよう、慎重に"
        "背中に気を付けてね、ぼくが迎えに行くよ(○_○)"
    ]
    get: () ->
        idx = Math.floor(Math.random() * this.subjects.length)
        result = {}
        result.sub = this.subjects[idx]
        result.des = this.descriptions[idx]
        return result
