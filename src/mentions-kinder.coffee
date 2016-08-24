# This is sprockets manifest file, which allows easy integration into a rails project
# Just clone this repo into vendor/assets/javascripts/mentions-kinder and require mentions-kinder/src/mentions-kinder
#

#= require_self
#= require ./autocompleter
#= require ./extend-patch
#= require ./autocompleter/select2-autocompleter
#= require ./jquery-plugin

###
  MentionsKinder base class
###
class @MentionsKinder
  KEY = { RETURN: 13, ESC: 27 }
  TEXT_NODE = 3
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    trigger:
      '@': {
        triggerName: 'member'
      } # inherit default
    # default deserialize method formats the matched token with the trigger formatter
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
    # default regex for deserialize, matches will be deserialized with the method above
    deserializeRegex: /\[(.)(.+?)\]\((\w+):(.+?)\)/g

  # default trigger options, will be the defaults for trigger options
  triggerDefaultOptions:
    # an autocompleter object
    autocompleter: MentionsKinder.Autocompleter
    # a formatter must return a html node or jquery wrapped html node
    formatter: (data)->
      $trigger = $("<span class='#{data.triggerOptions.triggerName}-trigger'></span>").text(data.trigger)
      $value = $("<span class='#{data.triggerOptions.triggerName}-value'></span>").text(data.name)
      $mention = $('<span class="mention label" contenteditable="false"></span>')
      $deleteHandle = $("<span class='delete-mention #{data.triggerOptions.triggerName}-delete'><i class='icon-remove'></i></span>")
      $mention.append([$trigger, $value, $deleteHandle])
      $mention.attr('serialized-mention', data.serializedMention)
      $mention
    # serializer gets the mention data and must return a string
    serializer: (data)->
      "[#{data.trigger}#{data.name}](#{data.triggerOptions.triggerName}:#{data.value})"

  # le constructor
  # setup mentions kinder
  constructor: (element, options)->
    @_ensureInput(element)
    @_buildOptions(options)

    @_setupElements()
    @_setupEvents()
    # trigger focus, because contenteditable divs doesn't support html5 autofocus
    @$editable.focus() if @$editable.attr('autofocus')

  # serialize text and set it to the hidden field
  populateInput: =>
    val = @serializeEditable()
    @$originalInput.val(val).trigger(
      type: "change",
      mentionsKinder: true
    )
    @$originalInput.trigger('mentions-kinder-change', val) # DEPRECATED

  # serialize the editable element
  serializeEditable: ->
    @serializeNode @$editable[0]

  # Deserialize the original input into the editable
  deserializeFromInput: =>
    @$editable.html @_deserialize(@$originalInput.val())

  # Helper method
  # un**** our editable after paste or other ****
  cleanEditable: =>
    @_cleanChildNodes(@$editable[0])

  # can be called from outer space to set focus on mentions-kinder editable
  # EXAMPLE: $('textarea').data('mentionsKinder').focus()
  focus: =>
    @$editable.focus()

  # start autocompletion for trigger char
  # Create new temp mention, create autompleter and set caret correctly
  startAutocomplete: (triggerChar)->
    @_current = {
      trigger: triggerChar,
      triggerOptions: @trigger[triggerChar],
      $tempMention: $("<span class='mention temp-mention label'>#{triggerChar}</span>")
    }

    tempMention = @_current.$tempMention.get(0)
    @_insertNode(tempMention)

    @_current.autocompleter = new @_current.triggerOptions.autocompleter(mentionsKind: @)
    @_current.autocompleter.done(@handleAutocompleteDone)
    @_current.autocompleter.fail(@handleAutocompleteFail)
    @_current.autocompleter.always(@populateInput)
    @_current.autocompleter.search('')

  # update autocompletion
  updateAutocomplete: ->
    text = @_current.$tempMention.text()
    triggerLength = @_current.trigger.length

    # slice trigger off if text starts with it
    if text.slice(0, triggerLength) == @_current.trigger
      @_current.autocompleter.search(text.slice(triggerLength))
    # else trigger char has been removed, abort
    else
      @abortAutocomplete()

  # check if there is an autocompletion started
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

  # abort the autocompletion
  abortAutocomplete: ->
    @isAutocompleting() && @_current.autocompleter.abort()

  # Event handler
  # autocompleter done
  # Create valid mention and add it to the editable
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

  # Event handler
  # autocomplete fail
  # No mention created, transform temp mention to text node
  handleAutocompleteFail: =>
    # convert to text
    textNode = document.createTextNode(@_current.$tempMention.text())
    @_current.$tempMention.replaceWith(textNode)
    # set caret to original position
    @_setCaretToEndOf(textNode)

    @_current = null

  # Event handler
  # keypress
  # Invoke autocompleter if possible trigger char found
  # Check enter key in single line inputs to trigger form submit (default single line input behaviour)
  handleInput: (e)=>
    charCode = e.charCode || e.which || e.keyCode
    char = String.fromCharCode(charCode)
    if !@isAutocompleting() && @trigger[char]
      e.preventDefault()
      @startAutocomplete(char)

    # don't allow newline in singleline input
    if charCode == KEY.RETURN && !@multiline
      e.preventDefault()
      @$form.submit() if @submitOnEnter

  # Event handler
  # keyup
  # Update or cancel autocompleter
  # Update hidden field with serialized text
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

  # Event handler
  # paste
  handlePaste: (e)=>
    if (content = @_getClipboardContent(e))
      e.preventDefault()
      @_insertText(content)
    else
      setTimeout(@cleanEditable, 0)

    # set plaintext to our hidden field
    setTimeout(@populateInput, 0)

  # Event handler
  # (form) reset
  # reset editable
  handleReset: =>
    @$editable.empty().blur()
    setTimeout(=>
      @deserializeFromInput()
      @handlePlaceholder()
    , 0)

  # Event handler
  # (form) reset, blur, focus
  # show/hide the placeholder
  handlePlaceholder: (e)=>
    return unless @$placeholder? # break if no placeholder is setup
    if e?.type == 'focus'
      # do this only if placeholder is currently in DOM
      unless @placeholderDetached
        @placeholderDetached = true
        # the following code should be called detached from this focus callback function
        # otherwise rangy failed because focus isn't finished and caret has not been placed yet
        window.setTimeout(=> @$placeholder.detach())

    else
      if @serializeEditable() == ''
        @$editable.empty().append(@$placeholder)
        @placeholderDetached = false

  # Event handler
  # click
  # delete mention on click
  handleDelete: (e)=>
    e.preventDefault()
    $currentMentionNode = $(e.target).parents('.mention')
    if $currentMentionNode
      nextNode = $currentMentionNode.get(0).nextSibling
      # set caret to beginning of the next node
      @_setCaretToStartOf(nextNode) if nextNode
      # then remove the current mention node
      $currentMentionNode.remove()
      # serialize text and set it to the hidden input
      @populateInput()

  # Check if $.mentionsKinder is seting up to the correct element
  _ensureInput: (element)->
    @$originalInput = $(element)
    unless @$originalInput.is('input[type=text],textarea')
      $.error("$.mentionsKinder works only on input[type=text] or textareas, was #{element && element.tagName}")

    @multiline = @$originalInput.is('textarea')

  # Create default flavoured option objects
  _buildOptions: (options)->
    # build options
    @options = $.extend {}, @defaultOptions, options
    # build trigger options
    $.each @options.trigger, (trigger, triggerOptions)=>
      @options.trigger[trigger] = $.extend {}, @triggerDefaultOptions, triggerOptions

    @trigger = @options.trigger || {}

  # Converts the given input/textarea to an editable that hopefully looks the same
  # called from constructor
  # assigns @$wrap and @$editable
  # requires @$originalInput
  _setupElements: ->
    # create wrap, editable and hidden input
    @$wrap = $('<div class="mentions-kinder-wrap"></div>')
    @$editable = $('<div class="form-control mentions-kinder" contenteditable="true"></div>')
    @$editable.addClass("mentions-kinder-#{if @multiline then 'multiline' else 'singleline'}")
    # set relevant attributes and values
    @$editable.addClass(@$originalInput.attr("class"))
    if autofocus = @$originalInput.attr('autofocus')
      @$editable.attr('autofocus', autofocus)
    # deserialize input value
    @deserializeFromInput() unless @$originalInput.val() == ''
    # initialize Placeholder
    if placeholder = @$originalInput.attr('placeholder')
      @$placeholder = $("<span class='placeholder'>#{placeholder}</span>")
      @handlePlaceholder()
    # hide, show and append all those elements
    @$wrap.insertAfter(@$originalInput)
    @$originalInput.appendTo(@$wrap).addClass('mentions-kinder-hidden')
    @$editable.appendTo(@$wrap)
    # return
    undefined

  # Bind all necessary events
  _setupEvents: ->
    # editable events
    @$editable.bind 'keypress', @handleInput
    @$editable.bind 'keyup', @handleKeyup
    @$editable.bind 'paste', @handlePaste
    @$editable.bind 'focus blur', @handlePlaceholder
    @$editable.on 'click', '.delete-mention', @handleDelete
    # input events
    @$originalInput.on 'focus', @focus
    @$originalInput.on 'change', (e)=>
      @deserializeFromInput() unless e.mentionsKinder
    # form related events
    if form = @$originalInput.get(0).form
      @$form = $(form)
      @submitOnEnter = true if !@multiline
      @$form.on('reset', @handleReset)

  # get clipboard content from given event or windows clipboardData
  _getClipboardContent: (e)->
    if e.originalEvent?.clipboardData
      e.originalEvent.clipboardData.getData('text/plain')
    else if window.clipboardData?.getData
      window.clipboardData.getData('Text')

  _getRange: (block)->
    selection = rangy.getSelection()
    range = selection.getRangeAt(0)
    selection.setSingleRange(range)
    block(range, selection)

  # insert a node at current cursor position
  # sets cursor after node
  _insertNode: (node)->
    @_getRange (range, selection)->
      range.insertNode(node)
      range.selectNodeContents(node)
      selection.collapseToEnd()

  # insert a plain text at current cursor position
  # substitutes line breaks with <br>
  # sets cursor to end of inserted text
  _insertText: (text)->
    lines = text.split("\n")
    nodes = []
    for line in lines
      nodes.push document.createTextNode(line)
      nodes.push document.createElement('BR')
    nodes.pop() # remove last br

    @_getRange (range, selection)->
      range.deleteContents()
      reverse = nodes.reverse()
      for node in reverse
        range.insertNode(node)
      range.selectNodeContents(reverse[0])
      selection.collapseToEnd()

    undefined

  # if we remove items from nodeList it is updated live, that results in missed nodes
  # therefore we save the node references in an array and iterate over that
  cloneReferences = (nodes)->
    for node in nodes
      node

  # Helper method to clean cloned nodes
  # iterate over child nodes and clean them
  _cleanChildNodes: (parentNode)->
    for node in cloneReferences(parentNode.childNodes)
      @_cleanNode(node)

    true

  # Helper method to clean a single node
  # recurses into child nodes
  _cleanNode: (node)->
    # dont clean text nodes or mention nodes
    if node.nodeType == TEXT_NODE
      # do nothing
    else if node.nodeName.toUpperCase() == 'BR'
      $(node).replaceWith(' ') unless @multiline # clean breaks in single line inputs
    else if $(node).attr('serialized-mention')
      $(node).attr('contenteditable', false) # ensure contenteditable is set after paste
    else
      # clean all children and replace node with them
      if node.childNodes?.length > 0
        @_cleanChildNodes(node)
        $(node).replaceWith(node.childNodes)
      # remove node
      else
        $(node).remove()

    true

  # Helper Method to serialize a node, support for different node types
  serializeNode: (node)->
    @_trim(@_tokenizeNode(node).join('')).replace(/\u00A0/g, ' ')

  _tokenizeNode: (parentNode)->
    textNodes = []
    for node in parentNode.childNodes
      # is text node, append text
      if node.nodeType == TEXT_NODE
        textNodes.push node.data
        # is br node, append newline
      else if node.nodeName.toUpperCase() == 'BR'
        textNodes.push "\n" unless @_isLastChildNode(node)
        # is mention, append serializedMention
      else if serializedMention = $(node).attr('serialized-mention')
        textNodes.push serializedMention
        # is p or div, append newline and serialize children
      else if node.nodeName.toUpperCase() == 'P' || node.nodeName.toUpperCase() == 'DIV'
        textNodes.push("\n") if @_previousNodeIsTextNode(node)
        textNodes = textNodes.concat @_tokenizeNode(node)
        textNodes.push("\n") unless @_isLastChildNode(node)
        # is any other tag, serialize children
      else
        textNodes = textNodes.concat @_tokenizeNode(node)

    textNodes

  _isLastChildNode: (node)->
    node.parentNode.lastChild == node

  _previousNodeIsTextNode: (node)->
    node.previousSibling?.nodeType == TEXT_NODE

  # Helper Method to deserialize given text into nodes
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

  # Helper method for _deserialize
  # Split text into lines and add br-nodes to keep line breaks
  # musst be called with array as context (this), for example see _deserialize a few lines above
  _deserializeText: (text)->
    #console.log "_deserializeText", text
    lines = text.split("\n")
    for line, i in lines
      @push document.createTextNode(line)
      @push document.createElement('br') unless i == lines.length - 1

  # Helper method to create a proper rangy selection
  _prepareSetCaretTo: (node)->
    selection = rangy.getSelection()
    range = selection.getRangeAt(0)
    range.selectNodeContents(node)
    selection.setSingleRange(range)
    selection

  # Collapse selection to the end
  _setCaretToEndOf: (node)->
    @_prepareSetCaretTo(node).collapseToEnd()

  # Collapse selection to the beginning
  _setCaretToStartOf: (node)->
    @_prepareSetCaretTo(node).collapseToStart()

  # Helper method to check if caret is in the current temp mention
  _isCaretInTempMention: ->
    if @isAutocompleting()
      range = rangy.getSelection().getRangeAt(0)
      range?.compareNode(@_current.$tempMention.get(0)) == range.NODE_BEFORE_AND_AFTER

  # Helper method to trim whitespaces from start/end of text
  _trim: (text)->
    $.trim(text)