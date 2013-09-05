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

    equal obj.options.trigger['%'].autocompleter, MentionsKinder.Autocompleter

  module 'Input modification',
    setup: ->
      @inputs = $('#qunit-fixture').children()

  test 'it wraps the input', ->
    expect 4

    @inputs.mentionsKinder().each ->
      obj = $(@).data('mentionsKinder')
      ok $(@).parent().hasClass('mentions-kinder-wrap'), 'input has mentions wrap parent'
      equal obj.$wrap[0], $(@).parent()[0], 'referenced $wrap equals input parent'

  test 'it removes name from input', ->
    expect 2

    @inputs.mentionsKinder().each ->
      equal $(@).attr('name'), ""

  test 'it adds hidden input with name from input', ->
    expect 4
    @inputs.attr('name', 'foo')

    @inputs.mentionsKinder().each ->
      $hidden = $(@).parents('.mentions-kinder-wrap').find('input[type=hidden]')
      ok $hidden.length > 0
      equal $hidden.attr('name'), 'foo'