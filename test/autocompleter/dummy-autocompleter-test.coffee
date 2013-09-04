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

  module '$.MentionsKinder.Autocompleter.DummyAutocompleter'

  asyncTest 'it returns async', ->
    expect(2)

    callback = (data)->
      equal data.name, 'foo'
      ok data.value
      start()

    autocompleter = new $.MentionsKinder.Autocompleter.DummyAutocompleter(callback)
    autocompleter.timeout = 50
    autocompleter.search 'foo'