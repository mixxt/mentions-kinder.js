/*
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
*/


(function() {
  (function($) {
    module('jQuery#mentionsKinder', {
      setup: function() {
        return this.elems = $('#qunit-fixture').children();
      }
    });
    return test('is chainable', function() {
      return strictEqual(this.elems.mentionsKinder(), this.elems, 'should be chainable');
    });
  })(jQuery);

}).call(this);
