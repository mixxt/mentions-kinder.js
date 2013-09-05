###
  Base class
###
class MentionsKinder
  KEY = { BACKSPACE : 8, TAB : 9, RETURN : 13, ESC : 27, LEFT : 37, UP : 38, RIGHT : 39, DOWN : 40, COMMA : 188, SPACE : 32, HOME : 36, END : 35 }
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    trigger:
      '@': {
        triggerName: 'member'
      } # inherit default

  triggerDefaultOptions:
      autocompleter: Autocompleter
      formatter: (data)->
        $('<span class="mention label btn-primary active" disabled contenteditable="false">').text(data.name).prepend("<span style='color: #f4f4f4'>#{data.trigger}</span>")
      serializer: (data)->
        "[#{data.trigger}#{data.name}](#{data.triggerOptions.triggerName}:#{data.value})"

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
    @_current = {
      trigger: triggerChar,
      triggerOptions: @trigger[triggerChar],
      $tempMention: $("<span class='mention temp-mention label btn-info active'>#{triggerChar}</span>").appendTo(@$editable)
    }

    @_current.autocompleter = new @_current.triggerOptions.autocompleter
    @_current.autocompleter.done(@handleAutocompleteDone)
    @_current.autocompleter.fail(@handleAutocompleteFail)
    @_current.autocompleter.search('')
    
    textNode = document.createTextNode(' ')
    $(textNode).insertAfter(@_current.$tempMention)
    @_setCaretPosition(@_current.$tempMention[0], 1)

  updateAutocomplete: ->
    search = @_current.$tempMention.text().slice(@_current.trigger.length)
    @_current.autocompleter.search(search)

  isAutocompleting: ->
    @_current?

  abortAutocomplete: ->
    @isAutocompleting() && @_current.autocompleter.abort()

  handleAutocompleteDone: (data)=>
    console.log "Autocomplete done", data

    data = $.extend({}, @_current, data)

    # create mention
    $mention = @_current.triggerOptions.formatter(data).data('serializedMention', @_current.triggerOptions.serializer(data))
    # convert temp mention to mention
    @_current.$tempMention.replaceWith($mention)
    # set caret
    @_setCaretPosition(@$editable[0], 1, $mention[0].nextSibling)

    @_current = null

  handleAutocompleteFail: =>
    console.log "Autocomplete fail"

    # store original caret position
    placeCaret = if @_isCaretInTempMention() then @_getCaretPosition(@_current.$tempMention[0])
    # convert to text
    textNode = document.createTextNode(@_current.$tempMention.text())
    @_current.$tempMention.replaceWith(textNode)
    # set caret to original position
    @_setCaretPosition(@$editable[0], placeCaret, textNode) if placeCaret

    @_current = null

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
    @$editable = $('<pre class="mentions-kinder-input form-control" contenteditable="true"></pre>')
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
    @isAutocompleting() && window.getSelection().baseNode?.parentElement == @_current.$tempMention[0]


MentionsKinder.Autocompleter = Autocompleter