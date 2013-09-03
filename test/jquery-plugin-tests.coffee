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
  module 'jQuery#mentionsKinder',
    setup: ->
      @elems = $('#qunit-fixture').children()

  test 'is chainable', ->
    strictEqual @elems.mentionsKinder(), @elems, 'should be chainable'


  module 'jQuery.MentionsKinder'

  test 'is defined', ->
    ok $.MentionsKinder

  test 'exposes defaultOptions', ->
    ok $.MentionsKinder.defaultOptions, 'defaultOptions available'

  test 'changes defaultOptions on prototype', ->
    $.MentionsKinder.defaultOptions.foo = 'bar'
    obj = new $.MentionsKinder(document.createElement('textarea'))

    ok obj.options.foo, 'custom option is set'

    deepEqual obj.options, $.MentionsKinder.defaultOptions, 'default options are inherited into object'

  test 'accepts options', ->
    customTrigger = ['&']
    obj = new $.MentionsKinder(document.createElement('textarea'), trigger: customTrigger)

    equal obj.options.trigger, customTrigger, 'overrides defaultOptions'
    notEqual obj.defaultOptions.trigger, customTrigger, 'does not change defaultOptions'

  test 'it raises error if initialized with wrong or no element', ->
    throws -> $.MentionsKinder()
    throws -> $.MentionsKinder(document.createElement('span'))