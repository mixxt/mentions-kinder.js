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
      @elems = $('#inputs').children()

  test 'is chainable', ->
    equal @elems.mentionsKinder(), @elems, 'should be chainable'

  test 'sets data("mentionsKinder")', ->
    expect 2

    @elems.mentionsKinder().each ->
      ok $(@).data('mentionsKinder') instanceof $.MentionsKinder


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

    delete $.MentionsKinder.defaultOptions.foo