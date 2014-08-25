$el = $('#app')

$el.html """
    <div class='challenge'></div>
    <div class='attempt'></div>
    <input class='regex-input'>
    <div class='help-container'>
      <div class='show-hint'>Hint</div>
      <div class='show-answer'>Show</div>
    </div>
    <div class='answer'></div>
"""

$challenge = $el.find '.challenge'
$attempt = $el.find '.attempt'
$input = $el.find '.regex-input'
$hint = $el.find '.show-hint'
$show = $el.find '.show-answer'
$answer = $el.find '.answer'

loadData = _.once -> $.ajax url: './challenges.json'

pickChallenge = (challenge, level = 0) ->
    return loadData().then (json) ->
      setChallenge _.find json[challenge], (c) -> return c.level is level

setChallenge = (challenge) ->
    $challenge.html challenge.text
    highlightMatch $challenge, challenge.match
    $attempt.html challenge.text

    $input.focus()
    $input.on 'keyup', -> onInput(challenge)

    $hint.css 'opacity', 0
    $hint.on 'click', -> showHint(challenge)
    setTimeout (() -> $hint.css('opacity', 1)), 3000

    $show.css 'opacity', 0
    $show.hide()
    $show.on 'click', -> showAnswer(challenge)

    $answer.hide()

onInput = (challenge) ->
    input = $input.val()
    $attempt.html challenge.text
    highlightMatch $attempt, input
    checkInputCorrect challenge, input

showHint = (challenge) ->
    $input.val challenge.hint
    onInput(challenge)
    $hint.hide()
    $show.show()
    setTimeout (() -> $show.css('opacity', 1)), 3000
    $input.focus()

showAnswer = (challenge) ->
    $answer.html challenge.match
    $answer.show()
    $show.hide()
    $input.focus()

highlightMatch = (el, regex) ->
    return if regex is ""
    el.html el.text().replace checkRegex(regex), (text) ->
        return '<span class="highlight">'+ text + '</span>'

checkRegex = (string) ->
    try
        $input.removeClass('invalid')
        return new RegExp(string, 'g')
    catch e
        $input.addClass('invalid')
        return new RegExp('NOPE_NOPE', 'g')

checkInputCorrect = (challenge, input) ->
    userSolution = challenge.text.match(checkRegex(input))
    realSolution = challenge.text.match(new RegExp(challenge.match, 'g'))
    if _.isEqual(userSolution, realSolution)
        makeSuccess()

makeSuccess = ->
    $el.addClass 'great-success'

# --- #

pickChallenge 'esc', 0
