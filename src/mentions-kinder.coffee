class MentionsKinder
  defaultOptions:
    trigger: ['@']

  constructor: ($element, options)->
    @options = $.extend {}, @defaultOptions, options