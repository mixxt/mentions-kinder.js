###
  Autocompleter Base
###
class MentionsKinder.Autocompleter
  constructor: (options = {})->
    @mentionsKind = options.mentionsKind
    @options = options
    @initialize()
    @deferred = $.Deferred()
    @deferred.promise(@)

  initialize: ->

  complete: (data)->
    @deferred.resolve(data)

  abort: ->
    @deferred.reject()

  search: (string)->
    $.error "implement #search in your autocompleter"
