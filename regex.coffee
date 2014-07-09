$el = $('#app')

$el.html """
    <div class='challenge'></div>
    <div class='attempt'></div>
    <input class='regex-input'>
    <div class='show-answer-container'>
      <div class='show-answer'>Show</div>
    </div>
    <div class='answer'></div>
"""

$challenge = $el.find '.challenge'
$attempt = $el.find '.attempt'
$input = $el.find '.regex-input'
$show = $el.find '.show-answer'
$answer = $el.find '.answer'

loadData = _.once -> $.ajax url: './challenges.json'

pickChallenge = (challenge) ->
    return loadData().then (json) -> setChallenge json[challenge][0]

setChallenge = (challenge) ->
    $challenge.text challenge.text
    highlightMatch $challenge, challenge.match
    $attempt.text challenge.text
    $input.focus()
    $input.on 'keyup', -> onInput(challenge)
    $show.css('opacity', 0)
    setTimeout (() -> $show.css('opacity', 1)), 3000
    $show.on 'click', -> showAnswer(challenge.match)
    $answer.hide()

onInput = (challenge) ->
    input = $input.val()
    $attempt.text challenge.text
    highlightMatch $attempt, input
    checkInputCorrect challenge, input

showAnswer = (answer) ->
    $answer.text answer
    $answer.show()
    $show.hide()

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

pickChallenge '*'
