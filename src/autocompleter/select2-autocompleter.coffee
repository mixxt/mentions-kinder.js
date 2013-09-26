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
      data = $.extend({}, { name: e.object.text, value: e.object.id }, e.object)
      @complete.call(@, data)
      @$input.select2('destroy').remove()

    @$input.on 'select2-close', (e)=>
      @abort.call(@)
      @$input.select2('destroy').remove()

  search: $.noop # not needed, typing directly in select2 input

  _setupInput: ->
    @$input = $('<input type="hidden" />').css('width', @mentionsKind.$editable.width()).appendTo(@mentionsKind.$wrap)
    @$input.select2(@select2Options)
    @$input.select2('open')

}

MentionsKinder.triggerDefaultOptions.autocompleter = Autocompleter.Select2Autocompleter