###
  Expose MentionsKinder to jQuery
###

$.fn.mentionsKinder = (options)->
  @.each ->
    instance = $(@).data('mentionsKinder')
    if instance is undefined
      $(@).data('mentionsKinder', new $.MentionsKinder(@, options))

# Add class under jQuery namespace
$.MentionsKinder = MentionsKinder
# expose default options
$.MentionsKinder.defaultOptions = MentionsKinder::defaultOptions
$.MentionsKinder.triggerDefaultOptions = MentionsKinder::triggerDefaultOptions
