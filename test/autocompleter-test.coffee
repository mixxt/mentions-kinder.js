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
  module '$.MentionsKinder.Autocompleter'

  test 'is available', ->
    ok $.MentionsKinder.Autocompleter, 'autocompleter base class is available'

  module 'Autocompleter',
    setup: ->
      @autocomplete = (string, callback)->
        completer = new $.MentionsKinder.Autocompleter(callback)
        completer.search(string)

  test 'autocompleter throws', ->
    throws ->
      @autocomplete 'foo'