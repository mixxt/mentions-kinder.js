class Autocompleter
  constructor: (callback)->
    @callback = callback

  search: (string)->
    $.error "implement #search in your autocompleter"
