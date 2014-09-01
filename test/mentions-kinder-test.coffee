###
  ======== A Handy Little QUnit Reference ========
  http://api.qunitjs.com/

  Test methods:
    module(name, {[setup][ ,teardown]})
    test(name, callback)
    expect(numberOfAssertions)
    stop(increment)
    start(decrement)
  Test assertions:
    ok(value, [message])
    equal(actual, expected, [message])
    notEqual(actual, expected, [message])
    deepEqual(actual, expected, [message])
    notDeepEqual(actual, expected, [message])
    strictEqual(actual, expected, [message])
    notStrictEqual(actual, expected, [message])
    throws(block, [expected], [message])
###

do ($ = jQuery) ->
  MentionsKinder = $.MentionsKinder

  module 'MentionsKinder'

  test 'accepts options and extends with defaults', ->
    customTrigger = {'%': {}}
    obj = new MentionsKinder(document.createElement('textarea'), trigger: customTrigger)

    equal obj.options.trigger, customTrigger, 'overrides defaultOptions'
    notEqual obj.defaultOptions.trigger, customTrigger, 'does not change defaultOptions'

  test 'it raises error if initialized with wrong or no element', ->
    throws -> MentionsKinder()
    throws -> MentionsKinder(document.createElement('span'))

  test 'it extends trigger options with triggerDefaults', ->
    customTrigger = {'%': {}}
    obj = new MentionsKinder(document.createElement('textarea'), trigger: customTrigger)

    ok obj.options.trigger['%'].autocompleter

  module 'Input modification',
    setup: ->
      @inputs = $('#inputs').children()

  test 'it wraps the input', ->
    expect 4

    @inputs.mentionsKinder().each ->
      obj = $(@).data('mentionsKinder')
      ok $(@).parent().hasClass('mentions-kinder-wrap'), 'input has mentions wrap parent'
      equal obj.$wrap[0], $(@).parent()[0], 'referenced $wrap equals input parent'

  test 'it hides input', ->
    expect 2

    @inputs.mentionsKinder().each ->
      ok $(@).hasClass('mentions-kinder-hidden')

  test 'it adds the autofocus attribute from originalInput', ->
    expect 2
    @inputs.attr('autofocus', 'autofocus')

    @inputs.mentionsKinder().each ->
      $editable = $(@).parents('.mentions-kinder-wrap').find('.mentions-kinder')
      equal $editable.attr('autofocus'), 'autofocus'

  test 'it adds a placeholder span if placeholder attribute is set', ->
    expect 4
    @inputs.attr('placeholder', 'My Placeholder')

    @inputs.mentionsKinder().each ->
      $placeholder = $(@).parents('.mentions-kinder-wrap').find('span.placeholder')
      ok $placeholder.length > 0
      equal $placeholder.text(), 'My Placeholder'

  module 'deserialization',
    setup: ->
      @obj = new MentionsKinder(document.createElement('textarea'))

  textNodeEqual = (node, text)->
    equal node.nodeName, '#text', "node is text node"
    equal node.data, text, "node has correct text"

  test 'it returns array', ->
    result1 = @obj._deserialize('')
    ok result1 instanceof Array, 'returns array'
    equal result1.length, 0, 'returns empty array for empty input'

    result2 = @obj._deserialize('blubb')
    ok result2 instanceof Array, 'returns array'
    equal result2.length, 1, 'returns 1 element for text only input'
    textNodeEqual result2[0], 'blubb'

  test 'it deserializes token', ->
    result = @obj._deserialize('[@foo](member:123)')
    equal result.length, 1, "returns one elements hmm"
    $mention =  $(result[0])
    ok $mention.is('span.mention'), 'second element is a mention'
    equal $mention.text(), '@foo', 'has right text'
    equal $mention.attr('serialized-mention'), '[@foo](member:123)', 'has serialized-mention attribute'

  test 'it deserializes mixed text', ->
    result = @obj._deserialize('foo [@derp](member:1337) bar')
    equal result.length, 3, "returns three elements"
    textNodeEqual result[0], 'foo '
    textNodeEqual result[2], ' bar'
    $mention =  $(result[1])
    ok $mention.is('span.mention'), 'second element is a mention'
    equal $mention.text(), '@derp', 'has right text'
    equal $mention.attr('serialized-mention'), '[@derp](member:1337)', 'has serialized-mention attribute'

  test 'it deserializes line breals', ->
    result = @obj._deserialize("foo\nbar")
    equal result.length, 3, "returns three elements"
    textNodeEqual result[0], 'foo'
    ok result[1].tagName.toLowerCase() == 'br'
    textNodeEqual result[2], 'bar'

  module 'serialization'

  test 'it serializes simple element', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-1')),
      "Hello"
    )

  test 'it serializes divs', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-2')),
      "Hello\nWorld"
    )

  test 'it serializes divs with brs', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-3')),
      "Hello\nWorld"
    )

  test 'it serializes empty divs with brs inbetween', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-4')),
      "Hello"
    )

  test 'it serializes empty divs and brs', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-5')),
      "Hello\n\n\n\n\nWorld"
    )

  test 'it serializes divs in divs', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-6')),
      "Hello\nWorld"
    )

  test 'it converts non-breaking space to regular space', ->
    equal(
      MentionsKinder::serializeNode(document.getElementById('serialize-me-7')),
      "Hello Banana"
    )
