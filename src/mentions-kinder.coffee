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
    if !@isAutocompleting() && @trigger[char]
      e.preventDefault()
      @startAutocomplete(char)

  handleKeyup: (e)=>
    if @isAutocompleting()
      @updateAutocomplete()

    switch e.keyCode
      # abort if escape is pressed
      when KEY.ESC
        @abortAutocomplete()

    # abort if the cursor left the temp mention
    @abortAutocomplete() if !@_isCaretInTempMention()

  startAutocomplete: (triggerChar)->
    console.log "Start autocomplete for #{triggerChar}"
    triggerOptions = @trigger[triggerChar]
    @$tempMention = $("<span class='temp-mention'>#{triggerChar}</span>").appendTo @$editable
    textNode = document.createTextNode(' ')
    $(textNode).insertAfter(@$tempMention)
    @_setCaretPosition(@$tempMention[0], 1)

    @_autocompleter = new triggerOptions.autocompleter
    @_autocompleter.done(@handleAutocompleteDone)
    @_autocompleter.fail(@handleAutocompleteFail)
    @_autocompleter.search('')

  updateAutocomplete: ->
    @_autocompleter.search(@$tempMention.text())

  isAutocompleting: ->
    !!@_autocompleter

  abortAutocomplete: ->
    @_autocompleter?.abort()

  handleAutocompleteDone: (data)=>
    console.log "Autocomplete done", data
    @_autocompleter = null
    $mention = $('<button class="mention" disabled contenteditable="false">').text(data.name).data('mentionData', data)
    @$tempMention.replaceWith($mention)
    @_setCaretPosition(@$editable[0], 1, $mention[0].nextSibling)
    @$tempMention = null

  handleAutocompleteFail: ()=>
    console.log "Autocomplete fail"
    @_autocompleter = null

    # store original caret position
    placeCaret = if @_isCaretInTempMention() then @_getCaretPosition(@$tempMention[0])

    textNode = document.createTextNode(@$tempMention.text())
    @$tempMention.replaceWith(textNode)
    @$tempMention = null

    # set cursor to original position
    @_setCaretPosition(@$editable[0], placeCaret, textNode) if placeCaret

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
    @$editable = $('<pre class="mentions-kinder-input" contenteditable="true"></pre>')
    @$input = $("<input type='hidden' name='#{@$originalInput.attr('name')}'/>")
    @$wrap.insertAfter(@$originalInput)
    @$originalInput.hide().appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$editable.appendTo(@$wrap)

  _setupEvents: ->
    @$editable.bind 'keypress', @handleInput
    @$editable.bind 'keyup', @handleKeyup

  _setCaretPosition: (element, position, node)->
    node ||= element.firstChild
    element.focus()
    if document.selection
      sel = document.selection.createRange()
      sel.moveStart('character', position)
      sel.select()
    else
      window.getSelection().collapse(node, position)

  _getCaretPosition: ->
    window.getSelection().baseOffset

  _isCaretInTempMention: ->
    window.getSelection().baseNode?.parentElement == @$tempMention?[0]


MentionsKinder.Autocompleter = Autocompleter