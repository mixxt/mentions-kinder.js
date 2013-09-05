###
  Base class
###
class MentionsKinder
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
    @_setupSync()

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
    @$editable = $('<div class="mentions-kinder-input" contenteditable="plaintext-only"></div>')
    @$input = $("<input type='hidden' name='#{@$originalInput.attr('name')}'/>")
    @$wrap.insertAfter(@$originalInput)
    @$originalInput.hide().appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$editable.appendTo(@$wrap)

  _setupSync: ->



MentionsKinder.Autocompleter = Autocompleter