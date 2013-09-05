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

  _ensureInput: (element)->
    @$input = $(element)
    unless @$input.is('input[type=text],textarea')
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
    @$overlay = $('<div class="mentions-overlay"></div>')
    @$hiddenInput = $("<input type='hidden' name='#{@$input.attr('name')}'/>")
    @$input.attr('name', '')
    @$wrap.insertAfter(@$input)
    @$overlay.appendTo(@$wrap)
    @$input.appendTo(@$wrap)
    @$hiddenInput.appendTo(@$wrap)


MentionsKinder.Autocompleter = Autocompleter