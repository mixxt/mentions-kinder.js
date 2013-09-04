###
  Expose MentionsKinder to jQuery
###

$.fn.mentionsKinder = (options)->
  @.each ->
    if $(@).data('mentionsKinder') is undefined
      $(@).data('mentionsKinder', new $.MentionsKinder(@, options))

# Add class under jQuery namespace
$.MentionsKinder = MentionsKinder
# expose default options
$.MentionsKinder.defaultOptions = MentionsKinder::defaultOptions
