module.exports = (robot) ->
    robot.hear /いつやるの/, (msg) ->
        reps = [
            "今でしょ！щ（ﾟдﾟщ）"
            "ლ (╯⊙ ⊱ ⊙╰ ლ)今でしょ！"
            "今でしょ！ლ (╯◕◞౪◟◕╰ლ) "
            "（ ´థ౪థ）╭☞ 今でしょ！"
            "今でしょ！(」ﾟωﾟ)」 "
        ]
        msg.send msg.random(reps)

    robot.hear /When\sare\syou\sgonna\sdo\sit\?/, (msg) ->
        reps = [
            "Do it now! щ（ﾟдﾟщ）"
            "ლ (╯⊙ ⊱ ⊙╰ ლ)Do it now!"
            "Do it now! ლ (╯◕◞౪◟◕╰ლ) "
            "（ ´థ౪థ）╭☞ Do it now！"
            "Do it now！(」ﾟωﾟ)」 "
        ]
        msg.send msg.random(reps)
