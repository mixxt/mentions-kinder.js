###
  Base class
###
class MentionsKinder
  KEY = { BACKSPACE: 8, TAB: 9, RETURN: 13, ESC: 27, LEFT: 37, UP: 38, RIGHT: 39, DOWN: 40, COMMA: 188, SPACE: 32, HOME: 36, END: 35 }
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    trigger:
      '@': {
        triggerName: 'member'
      } # inherit default

  triggerDefaultOptions:
    autocompleter: Autocompleter
    formatter: (data)->
      $trigger = $("<span class='#{data.triggerOptions.triggerName}-trigger'></span>").text(data.trigger)
      $value = $("<span class='#{data.triggerOptions.triggerName}-value'></span>").text(data.name)
      $('<span class="mention label" contenteditable="false"></span>').append($trigger).append($value)
    serializer: (data)->
      "[#{data.trigger}#{data.name}](#{data.triggerOptions.triggerName}:#{data.value})"

  # le constructor
  constructor: (element, options)->
    @_ensureInput(element)
    @_buildOptions(options)

    @_setupElements()
    @_setupEvents()

  handleInput: (e)=>
    charCode = e.charCode || e.which || e.keyCode
    char = String.fromCharCode(charCode)
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
    if @isAutocompleting() && !@_isCaretInTempMention()
      @abortAutocomplete()

    # set plaintext to our hidden field
    @populateInput()

  handlePaste: =>
    # defer, content is not in yet
    setTimeout(@cleanEditable, 0)

  # un**** our editable after paste or other ****
  cleanEditable: =>
    @cleanChildNodes(@$editable[0])

  startAutocomplete: (triggerChar)->
    console?.log "Start autocomplete for #{triggerChar}"
    @_current = {
      trigger: triggerChar,
      triggerOptions: @trigger[triggerChar],
      $tempMention: $("<span class='mention temp-mention label'>#{triggerChar}</span>")
    }

    tempMention = @_current.$tempMention.get(0)
    selection = rangy.getSelection()
    range = selection.getRangeAt(0)
    range.insertNode(tempMention)
    range.selectNodeContents(tempMention)
    selection.setSingleRange(range)
    selection.collapseToEnd()

    @_current.autocompleter = new @_current.triggerOptions.autocompleter(mentionsKind: @)
    @_current.autocompleter.done(@handleAutocompleteDone)
    @_current.autocompleter.fail(@handleAutocompleteFail)
    @_current.autocompleter.always(@populateInput)
    @_current.autocompleter.search('')

  updateAutocomplete: ->
    text = @_current.$tempMention.text()
    triggerLength = @_current.trigger.length

    # slice trigger off if text starts with it
    if text.slice(0, triggerLength) == @_current.trigger
      @_current.autocompleter.search(text.slice(triggerLength))
    # else trigger char has been removed, abort
    else
      @abortAutocomplete()

  isAutocompleting: ->
    @_current?

  abortAutocomplete: ->
    @isAutocompleting() && @_current.autocompleter.abort()

  handleAutocompleteDone: (data)=>
    console?.log "Autocomplete done", data

    # add current trigger state to data to allow access from formatters and serializers
    data = $.extend({}, @_current, data)

    # create mention
    $mention = @_current.triggerOptions.formatter(data)
    serializedMention = @_current.triggerOptions.serializer(data)
    $mention.attr('serialized-mention', serializedMention)

    # convert temp mention to mention
    node = document.createTextNode(String.fromCharCode(160)) # &nbsp;
    $(node).insertAfter(@_current.$tempMention)
    @_setCaretToEndOf(node)

    @_current.$tempMention.replaceWith($mention)

    @_current = null

  handleAutocompleteFail: =>
    console?.log "Autocomplete fail"

    # convert to text
    textNode = document.createTextNode(@_current.$tempMention.text())
    @_current.$tempMention.replaceWith(textNode)
    # set caret to original position
    @_setCaretToEndOf(textNode)

    @_current = null

  populateInput: =>
    val = @serializeEditable()
    @$originalInput.val(val)
    @$input?.val(val)

  serializeEditable: ->
    @serializeNode(@$editable[0]).join('')

  serializeNode: (parentNode)->
    textNodes = []
    for node in parentNode.childNodes
      if node.nodeType == 3 # nodeType 3 is a text node
        textNodes.push node.data #">#{node.data}<"
      else if node.nodeName == 'BR'
        textNodes.push "\n"
      else if serializedMention = $(node).attr('serialized-mention')
        textNodes.push serializedMention
      else
        textNodes = textNodes.concat @serializeNode(node)
    textNodes

  # if we remove items from nodeList it is updated live, that results in missed nodes
  # therefore we save the node references in an array and iterate over that
  cloneReferences = (nodes)->
    for node in nodes
      node

  # iterate over child nodes and clean them
  cleanChildNodes: (parentNode)->
    for node in cloneReferences(parentNode.childNodes)
      @cleanNode(node)

    true

  # clean a single node
  # recurses into child nodes
  # TODO keep <br>'s
  cleanNode: (node)->
    # dont clean text nodes or mention nodes
    if node.nodeType == 3 || node.nodeName == 'BR'
      # do nothing
    else if $(node).attr('serialized-mention')
      $(node).attr('contenteditable', false) # ensure contenteditable is set after paste
    else
      # clean all children and replace node with them
      if node.childNodes?.length > 0
        @cleanChildNodes(node)
        $(node).replaceWith(node.childNodes)
      # remove node
      else
        $(node).remove()

    true

  deserializeInput: ->
    # TODO implement
    document.createTextNode(@$originalInput.val())

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
    @$editable = $('<div class="mentions-kinder-input form-control" contenteditable="true"></div>')
    @$input = $("<input type='hidden' name='#{@$originalInput.attr('name')}'/>")
    @$input.val(@$originalInput.val())
    @$editable.addClass(@$originalInput.attr("class")).html(@deserializeInput())

    @$wrap.insertAfter(@$originalInput)
    @$originalInput.hide().appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$editable.appendTo(@$wrap)

  _setupEvents: ->
    @$editable.bind 'keypress', @handleInput
    @$editable.bind 'keyup', @handleKeyup
    @$editable.bind 'paste', @handlePaste

  _setCaretToEndOf: (node)->
    selection = rangy.getSelection()
    range = selection.getRangeAt(0)
    range.selectNodeContents(node)
    selection.setSingleRange(range)
    selection.collapseToEnd()

  _isCaretInTempMention: ->
    if @isAutocompleting()
      range = rangy.getSelection().getRangeAt(0)
      range?.compareNode(@_current.$tempMention.get(0)) == range.NODE_BEFORE_AND_AFTER


MentionsKinder.Autocompleter = Autocompleter
