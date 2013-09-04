###
  This autocompleter will return your search string and a random value after the timeout,
  simulating a user selecting something from the autocomplete
###
class Autocompleter.DummyAutocompleter extends Autocompleter
  timeout: 500
  search: (string)->
    clearTimeout(@timeout) if @timeout
    value = ~~(Math.random() * 1000) # dummy val
    callback = @callback
    @timeout = setTimeout((-> callback({ name: string, value: value })), @timeout)