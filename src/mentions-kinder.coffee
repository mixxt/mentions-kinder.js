###
  Base class
###
class MentionsKinder
  KEY = { BACKSPACE : 8, TAB : 9, RETURN : 13, ESC : 27, LEFT : 37, UP : 38, RIGHT : 39, DOWN : 40, COMMA : 188, SPACE : 32, HOME : 36, END : 35 }
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    trigger:
      '@': {} # inherit default

  triggerDefaultOptions:
      autocompleter: Autocompleter
      # formatter
      # serializer

  # le constructor
  constructor: (element, options)->
    @_ensureInput(element)
    @_buildOptions(options)

    @_setupElements()
    @_setupEvents()

    window.foo = @

  handleInput: (e)=>
    char = String.fromCharCode(e.charCode)
    if @isAutocompleting()
      @autocomplete()
    else
      if @trigger[char]
        e.preventDefault()
        @startAutocomplete(char)

  handleKeydown: (e)=>
    switch e.keyCode
      when KEY.ESC
        @abortAutocomplete()

  startAutocomplete: (triggerChar)->
    console.log "Start autocomplete for #{triggerChar}"
    triggerOptions = @trigger[triggerChar]
    @$tempMention = $("<span class='temp-mention'>#{triggerChar}</span>").appendTo @$editable
    @_setCaretPosition(@$tempMention, 1)
    @_autocompleter = new triggerOptions.autocompleter
    @_autocompleter.done(@handleAutocompleteDone)
    @_autocompleter.fail(@handleAutocompleteFail)
    @_autocompleter.search('')

  autocomplete: ->
    console.log "autocomplete", @$tempMention.text()
    @_autocompleter.search(@$tempMention.text())

  isAutocompleting: ->
    !!@_autocompleter

  abortAutocomplete: ->
    @_autocompleter?.abort()

  handleAutocompleteDone: =>
    console.log "Autocomplete done"
    @_autocompleter = null
    $mention = $('<button class="mention" disabled contenteditable="false">').text(Utils.escape(@$tempMention.text()))
    @$tempMention.replaceWith($mention)
    @$tempMention = null

  handleAutocompleteFail: =>
    console.log "Autocomplete fail"
    @_autocompleter = null
    @$tempMention.replaceWith(Utils.escape(@$tempMention.text()))
    @$tempMention = null

  _ensureInput: (element)->
    @$originalInput = $(element)
    unless @$originalInput.is('input[type=text],textarea')
      $.error("$.mentionsKinder works only on input[type=text] or textareas, was #{element && element.tagName}")

  _buildOptions: (options)->
    # build options
    @options = $.extend {}, @defaultOptions, options
    # build trigger options
    $.each @options.trigger, (trigger, triggerOptions)=>
      @options.trigger[trigger] = $.extend {}, @triggerDefaultOptions, triggerOptions

    @trigger = @options.trigger || {}

  _setupElements: ->
    @$wrap = $('<div class="mentions-kinder-wrap"></div>')
    @$editable = $('<pre class="mentions-kinder-input" contenteditable="plaintext-only"></pre>')
    @$input = $("<input type='hidden' name='#{@$originalInput.attr('name')}'/>")
    @$wrap.insertAfter(@$originalInput)
    @$originalInput.hide().appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$editable.appendTo(@$wrap)

  _setupEvents: ->
    @$editable.bind 'keypress', @handleInput
    @$editable.bind 'keyup', @handleKeydown

  _setCaretPosition: ($element, position)->
    $element[0].focus()
    if document.selection
      sel = document.selection.createRange()
      sel.moveStart('character', position)
      sel.select()
    else
      window.getSelection().collapse($element[0].firstChild, position)


MentionsKinder.Autocompleter = Autocompleter