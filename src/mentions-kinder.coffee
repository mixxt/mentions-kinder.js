###
  Base class
###
class MentionsKinder
  # default options, exposed under $.mentionsKinder.defaultOptions
  defaultOptions:
    autocompleter:
      '@': Autocompleter

  # le constructor
  constructor: (element, options)->
    @options = $.extend {}, @defaultOptions, options
    @$el = $(element)
    unless @$el.is('input[type=text],textarea')
      $.error("$.mentionsKinder works only on input[type=text] or textareas, was #{element && element.tagName}")

MentionsKinder.Autocompleter = Autocompleter