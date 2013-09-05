###
  Autocompleter Base
###
class Autocompleter
  constructor: ->
    @initialize()
    @deferred = $.Deferred()
    @deferred.promise(@)

  initialize: ->

  abort: ->
    @deferred.reject()

  search: (string)->
    $.error "implement #search in your autocompleter"
