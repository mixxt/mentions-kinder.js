class Autocompleter.DummyAutocompleter extends Autocompleter
  timeout: 500
  search: (string)->
    clearTimeout(@timeout) if @timeout
    value = ~~(Math.random() * 1000) # dummy val
    callback = @callback
    @timeout = setTimeout((-> callback({ name: string, value: value })), @timeout)