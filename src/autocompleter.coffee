###
  Autocompleter Base
###
class Autocompleter
  constructor: (callback)->
    @callback = callback
    @initialize()

  initialize: ->

  search: (string)->
    $.error "implement #search in your autocompleter"
