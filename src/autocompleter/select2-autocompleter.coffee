###
  Autocompleter that utilizes select2
###
Autocompleter.Select2Autocompleter = Autocompleter.extend {
  select2Options: {
    data: []
  }

  initialize: ->
    @_setupInput()

    @$input.on 'select2-selecting', (e)=>
      @complete.call(@, e.object)
      @$input.select2('destroy').remove()

    @$input.on 'select2-close', (e)=>
      @abort.call(@)
      @$input.select2('destroy').remove()

  search: (string)->
    @$input.val(string)

  complete: (data)->
    @deferred.resolve(name: data.text, value: data.id)

  _setupInput: ->
    @$input = $('<input type="hidden" />').css('width', @mentionsKind.$editable.width()).appendTo(@mentionsKind.$wrap)
    @$input.select2(@select2Options)
    @$input.select2('open')

}

MentionsKinder.triggerDefaultOptions.autocompleter = Autocompleter.Select2Autocompleter