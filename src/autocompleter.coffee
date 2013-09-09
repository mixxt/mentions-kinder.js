###
  Autocompleter Base
###
class Autocompleter
  constructor: (options = {})->
    @mentionsKind = options.mentionsKind
    @options = options
    @initialize()
    @deferred = $.Deferred()
    @deferred.promise(@)

  initialize: ->

  abort: ->
    @deferred.reject()

  search: (string)->
    $.error "implement #search in your autocompleter"
