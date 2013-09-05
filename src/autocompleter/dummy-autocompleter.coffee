###
  This autocompleter will return your search string and a random value after the timeout,
  simulating a user selecting something from the autocomplete
###
class Autocompleter.DummyAutocompleter extends Autocompleter
  timeout: 2000
  search: (string)->
    console.log "search", string
    clearTimeout(@timer) if @timer
    value = ~~(Math.random() * 1000) # dummy val
    @timer = setTimeout((=>
      @deferred.resolve({ name: string, value: value })
    ), @timeout)