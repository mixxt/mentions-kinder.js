###
  Base class
###
class MentionsKinder
  KEY = { RETURN: 13, ESC: 27 }
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    trigger:
      '@': {
        triggerName: 'member'
      } # inherit default
    deserialize: (matchedToken, trigger, name, triggerName, value)->
      formatter = @options.trigger[trigger]?.formatter
      if formatter
        formatter(
          trigger: trigger,
          name: name,
          value: value,
          triggerOptions: {triggerName: triggerName},
          serializedMention: matchedToken
        ).get(0)
      else
        document.createTextNode(matchedToken)

    deserializeRegex: /\[(.)(.+?)\]\((\w+):(.+?)\)/g


  triggerDefaultOptions:
    autocompleter: Autocompleter
    formatter: (data)->
      $trigger = $("<span class='#{data.triggerOptions.triggerName}-trigger'></span>").text(data.trigger)
      $value = $("<span class='#{data.triggerOptions.triggerName}-value'></span>").text(data.name)
      $mention = $('<span class="mention label" contenteditable="false"></span>')
      $deleteHandle = $("<span class='delete-mention #{data.triggerOptions.triggerName}-delete'><i class='icon-remove'></i></span>")
      $mention.append([$trigger, $value, $deleteHandle])
      $mention.attr('serialized-mention', data.serializedMention)
      $mention
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

    # don't allow newline in singleline input
    if charCode == KEY.RETURN && !@multiline
      e.preventDefault()
      if @submitOnEnter
        @$form.submit()

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
    if @_current?
      if $.contains(@$editable, @_current.$tempMention)
        true
      else
        @_current.autocompleter.abort()
        @_current = null
        false
    else
      false


  abortAutocomplete: ->
    @isAutocompleting() && @_current.autocompleter.abort()

  handleAutocompleteDone: (data)=>
    # add current trigger state to data to allow access from formatters and serializers
    data = $.extend({}, @_current, data)

    # create mention
    data.serializedMention = @_current.triggerOptions.serializer(data)
    $mention = @_current.triggerOptions.formatter(data)

    # convert temp mention to mention
    node = document.createTextNode(String.fromCharCode(160)) # &nbsp;
    $(node).insertAfter(@_current.$tempMention)
    @$editable.focus() # refocus editable, required for firefox
    @_setCaretToEndOf(node)

    @_current.$tempMention.replaceWith($mention)

    @_current = null

  handleAutocompleteFail: =>
    # convert to text
    textNode = document.createTextNode(@_current.$tempMention.text())
    @_current.$tempMention.replaceWith(textNode)
    # set caret to original position
    @_setCaretToEndOf(textNode)

    @_current = null

  handleReset: =>
    @$editable.empty()
    @$input.val(@$originalInput.val())

  handlePlaceholder: (e)=>
    if e.type == 'focus'
      @$placeholder?.detach()
    else if e.type == 'blur' || e.type == 'reset'
      if @_strip(@serializeEditable()) == ''
        @$editable.empty().append(@$placeholder)

  handleDelete: (e)=>
    e.preventDefault()
    $currentMentionNode = $(e.target).parents('.mention')
    if $currentMentionNode
      nextNode = $currentMentionNode.get(0).nextSibling
      @_setCaretToStartOf(nextNode) if nextNode
      $currentMentionNode.remove()

  populateInput: =>
    val = @serializeEditable()
    @$input?.val(val)

  serializeEditable: ->
    @serializeNode(@$editable[0]).join('')

  serializeNode: (parentNode)->
    textNodes = []
    for node in parentNode.childNodes
      # is text node, append text
      if node.nodeType == 3 # nodeType 3 is a text node
        textNodes.push node.data
      # is br node, append newline
      else if node.nodeName.toUpperCase() == 'BR'
        textNodes.push "\n"
      # is mention, append serializedMention
      else if serializedMention = $(node).attr('serialized-mention')
        textNodes.push serializedMention
      # is p or div, append newline and serialize children
      else if node.nodeName.toUpperCase() == 'P' || node.nodeName.toUpperCase() == 'DIV'
        # add newline only if first child is not a br-node, prevent endless new line duplicating
        textNodes.push("\n") unless node.childNodes[0]?.nodeName?.toUpperCase() == 'BR'
        textNodes = textNodes.concat @serializeNode(node)
      # is any other tag, serialize children
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
    if node.nodeType == 3
      # do nothing
    else if node.nodeName == 'BR'
      $(node).replaceWith(' ') unless @multiline # clean breaks in single line inputs
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

  deserializeFromInput: =>
    @$editable.html @_deserialize(@$originalInput.val())

  _deserialize: (text)->
    result = []
    regex = @options.deserializeRegex
    #console.log "START", text
    pointer = 0

    # deserialize magic
    loop
      match = regex.exec(text)
      if match
        # add text before matched token
        unless match.index == 0
          #console.log "LOOP substring from #{pointer} to #{match.index}", text.substring(pointer, match.index)
          @_deserializeText.call(result, text.substring(pointer, match.index))
          #result.push document.createTextNode(text.substring(pointer, match.index))
        pointer = regex.lastIndex
        # deserialize matched token
        #console.log "LOOP deserialize", match[0]
        result.push @options.deserialize.apply(@, match)
      else
        unless pointer == text.length
          #console.log "LAST substring from #{pointer} to #{text.length}", text.substring(pointer, text.length)
          lastText = text.substring(pointer, text.length)
          @_deserializeText.call(result, lastText) unless lastText == ''
          #result.push document.createTextNode(lastText)  unless lastText == ''
        break
    # return array of nodes
    #console.log "RESULT", result, "\n\n"
    result

  # Split text into lines and add br-nodes to keep line breaks
  # musst be called with array as context (this), for example see _deserialize a few lines above
  _deserializeText: (text)->
    #console.log "_deserializeText", text
    lines = text.split("\n")
    for line, i in lines
      @push document.createTextNode(line)
      @push document.createElement('br') unless i == lines.length - 1

  _ensureInput: (element)->
    @$originalInput = $(element)
    unless @$originalInput.is('input[type=text],textarea')
      $.error("$.mentionsKinder works only on input[type=text] or textareas, was #{element && element.tagName}")

    @multiline = @$originalInput.is('textarea')

  _buildOptions: (options)->
    # build options
    @options = $.extend {}, @defaultOptions, options
    # build trigger options
    $.each @options.trigger, (trigger, triggerOptions)=>
      @options.trigger[trigger] = $.extend {}, @triggerDefaultOptions, triggerOptions

    @trigger = @options.trigger || {}

  # Converts the given input/textarea to an editable that hopefully looks the same
  # called from constructor
  # assigns @$wrap, @$editable and @$input
  # requires @$originalInput
  _setupElements: ->
    @$wrap = $('<div class="mentions-kinder-wrap"></div>')
    @$editable = $('<div class="form-control mentions-kinder" contenteditable="true"></div>')
    @$editable.addClass("mentions-kinder-#{if @multiline then 'multiline' else 'singleline'}")
    @$input = $("<input type='hidden'/>")
    @$input.attr('name', @$originalInput.attr('name'))
    @$input.val(@$originalInput.val())
    @$editable.addClass(@$originalInput.attr("class"))
    @deserializeFromInput() unless @$originalInput.val() == ''
    if placeholder = @$originalInput.attr('placeholder')
      @$placeholder = $("<span class='placeholder'>#{placeholder}</span>").appendTo(@$editable)

    @$wrap.insertAfter(@$originalInput)
    @$originalInput.hide().appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$editable.appendTo(@$wrap)

    undefined

  _setupEvents: ->
    # editable events
    @$editable.bind 'keypress', @handleInput
    @$editable.bind 'keyup', @handleKeyup
    @$editable.bind 'paste', @handlePaste
    @$editable.bind 'focus blur', @handlePlaceholder
    @$editable.on 'click', '.delete-mention', @handleDelete
    # input events
    @$originalInput.bind 'change', @deserializeFromInput
    # form related events
    if form = @$originalInput.get(0).form
      @$form = $(form)
      @submitOnEnter = true if !@multiline
      @$form.on('reset', @handleReset)
      @$form.on('reset', @handlePlaceholder)

  _prepareSetCaretTo: (node)->
    selection = rangy.getSelection()
    range = selection.getRangeAt(0)
    range.selectNodeContents(node)
    selection.setSingleRange(range)
    selection

  _setCaretToEndOf: (node)->
    @_prepareSetCaretTo(node).collapseToEnd()

  _setCaretToStartOf: (node)->
    @_prepareSetCaretTo(node).collapseToStart()

  _isCaretInTempMention: ->
    if @isAutocompleting()
      range = rangy.getSelection().getRangeAt(0)
      range?.compareNode(@_current.$tempMention.get(0)) == range.NODE_BEFORE_AND_AFTER

  _strip: (text)->
    text.replace(/^\s*(.*?)\s*$/gm, '$1')

MentionsKinder.Autocompleter = Autocompleter
