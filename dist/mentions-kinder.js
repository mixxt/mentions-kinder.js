/*! mentions-kinder.js - v0.3.3 - 2016-08-24
* https://github.com/mixxt/mentions-kinder.js
* Copyright (c) 2016 mixxt GmbH; Licensed MIT */
(function($){
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.MentionsKinder = (function() {
    var KEY, TEXT_NODE, cloneReferences;

    KEY = {
      RETURN: 13,
      ESC: 27
    };

    TEXT_NODE = 3;

    MentionsKinder.prototype.defaultOptions = {
      trigger: {
        '@': {
          triggerName: 'member'
        }
      },
      deserialize: function(matchedToken, trigger, name, triggerName, value) {
        var formatter, _ref;
        formatter = (_ref = this.options.trigger[trigger]) != null ? _ref.formatter : void 0;
        if (formatter) {
          return formatter({
            trigger: trigger,
            name: name,
            value: value,
            triggerOptions: {
              triggerName: triggerName
            },
            serializedMention: matchedToken
          }).get(0);
        } else {
          return document.createTextNode(matchedToken);
        }
      },
      deserializeRegex: /\[(.)(.+?)\]\((\w+):(.+?)\)/g
    };

    MentionsKinder.prototype.triggerDefaultOptions = {
      autocompleter: MentionsKinder.Autocompleter,
      formatter: function(data) {
        var $deleteHandle, $mention, $trigger, $value;
        $trigger = $("<span class='" + data.triggerOptions.triggerName + "-trigger'></span>").text(data.trigger);
        $value = $("<span class='" + data.triggerOptions.triggerName + "-value'></span>").text(data.name);
        $mention = $('<span class="mention label" contenteditable="false"></span>');
        $deleteHandle = $("<span class='delete-mention " + data.triggerOptions.triggerName + "-delete'><i class='icon-remove'></i></span>");
        $mention.append([$trigger, $value, $deleteHandle]);
        $mention.attr('serialized-mention', data.serializedMention);
        return $mention;
      },
      serializer: function(data) {
        return "[" + data.trigger + data.name + "](" + data.triggerOptions.triggerName + ":" + data.value + ")";
      }
    };

    function MentionsKinder(element, options) {
      this.handleDelete = __bind(this.handleDelete, this);
      this.handlePlaceholder = __bind(this.handlePlaceholder, this);
      this.handleReset = __bind(this.handleReset, this);
      this.handlePaste = __bind(this.handlePaste, this);
      this.handleKeyup = __bind(this.handleKeyup, this);
      this.handleInput = __bind(this.handleInput, this);
      this.handleAutocompleteFail = __bind(this.handleAutocompleteFail, this);
      this.handleAutocompleteDone = __bind(this.handleAutocompleteDone, this);
      this.focus = __bind(this.focus, this);
      this.cleanEditable = __bind(this.cleanEditable, this);
      this.deserializeFromInput = __bind(this.deserializeFromInput, this);
      this.populateInput = __bind(this.populateInput, this);
      this._ensureInput(element);
      this._buildOptions(options);
      this._setupElements();
      this._setupEvents();
      if (this.$editable.attr('autofocus')) {
        this.$editable.focus();
      }
    }

    MentionsKinder.prototype.populateInput = function() {
      var val;
      val = this.serializeEditable();
      this.$originalInput.val(val).trigger({
        type: "change",
        mentionsKinder: true
      });
      return this.$originalInput.trigger('mentions-kinder-change', val);
    };

    MentionsKinder.prototype.serializeEditable = function() {
      return this.serializeNode(this.$editable[0]);
    };

    MentionsKinder.prototype.deserializeFromInput = function() {
      return this.$editable.html(this._deserialize(this.$originalInput.val()));
    };

    MentionsKinder.prototype.cleanEditable = function() {
      return this._cleanChildNodes(this.$editable[0]);
    };

    MentionsKinder.prototype.focus = function() {
      return this.$editable.focus();
    };

    MentionsKinder.prototype.startAutocomplete = function(triggerChar) {
      var tempMention;
      this._current = {
        trigger: triggerChar,
        triggerOptions: this.trigger[triggerChar],
        $tempMention: $("<span class='mention temp-mention label'>" + triggerChar + "</span>")
      };
      tempMention = this._current.$tempMention.get(0);
      this._insertNode(tempMention);
      this._current.autocompleter = new this._current.triggerOptions.autocompleter({
        mentionsKind: this
      });
      this._current.autocompleter.done(this.handleAutocompleteDone);
      this._current.autocompleter.fail(this.handleAutocompleteFail);
      this._current.autocompleter.always(this.populateInput);
      return this._current.autocompleter.search('');
    };

    MentionsKinder.prototype.updateAutocomplete = function() {
      var text, triggerLength;
      text = this._current.$tempMention.text();
      triggerLength = this._current.trigger.length;
      if (text.slice(0, triggerLength) === this._current.trigger) {
        return this._current.autocompleter.search(text.slice(triggerLength));
      } else {
        return this.abortAutocomplete();
      }
    };

    MentionsKinder.prototype.isAutocompleting = function() {
      if (this._current != null) {
        if ($.contains(this.$editable, this._current.$tempMention)) {
          return true;
        } else {
          this._current.autocompleter.abort();
          this._current = null;
          return false;
        }
      } else {
        return false;
      }
    };

    MentionsKinder.prototype.abortAutocomplete = function() {
      return this.isAutocompleting() && this._current.autocompleter.abort();
    };

    MentionsKinder.prototype.handleAutocompleteDone = function(data) {
      var $mention, node;
      data = $.extend({}, this._current, data);
      data.serializedMention = this._current.triggerOptions.serializer(data);
      $mention = this._current.triggerOptions.formatter(data);
      node = document.createTextNode(String.fromCharCode(160));
      $(node).insertAfter(this._current.$tempMention);
      this.$editable.focus();
      this._setCaretToEndOf(node);
      this._current.$tempMention.replaceWith($mention);
      return this._current = null;
    };

    MentionsKinder.prototype.handleAutocompleteFail = function() {
      var textNode;
      textNode = document.createTextNode(this._current.$tempMention.text());
      this._current.$tempMention.replaceWith(textNode);
      this._setCaretToEndOf(textNode);
      return this._current = null;
    };

    MentionsKinder.prototype.handleInput = function(e) {
      var char, charCode;
      charCode = e.charCode || e.which || e.keyCode;
      char = String.fromCharCode(charCode);
      if (!this.isAutocompleting() && this.trigger[char]) {
        e.preventDefault();
        this.startAutocomplete(char);
      }
      if (charCode === KEY.RETURN && !this.multiline) {
        e.preventDefault();
        if (this.submitOnEnter) {
          return this.$form.submit();
        }
      }
    };

    MentionsKinder.prototype.handleKeyup = function(e) {
      if (this.isAutocompleting()) {
        this.updateAutocomplete();
      }
      switch (e.keyCode) {
        case KEY.ESC:
          this.abortAutocomplete();
      }
      if (this.isAutocompleting() && !this._isCaretInTempMention()) {
        this.abortAutocomplete();
      }
      return this.populateInput();
    };

    MentionsKinder.prototype.handlePaste = function(e) {
      var content;
      if ((content = this._getClipboardContent(e))) {
        e.preventDefault();
        this._insertText(content);
      } else {
        setTimeout(this.cleanEditable, 0);
      }
      return setTimeout(this.populateInput, 0);
    };

    MentionsKinder.prototype.handleReset = function() {
      var _this = this;
      this.$editable.empty().blur();
      return setTimeout(function() {
        _this.deserializeFromInput();
        return _this.handlePlaceholder();
      }, 0);
    };

    MentionsKinder.prototype.handlePlaceholder = function(e) {
      var _this = this;
      if (this.$placeholder == null) {
        return;
      }
      if ((e != null ? e.type : void 0) === 'focus') {
        if (!this.placeholderDetached) {
          this.placeholderDetached = true;
          return window.setTimeout(function() {
            return _this.$placeholder.detach();
          });
        }
      } else {
        if (this.serializeEditable() === '') {
          this.$editable.empty().append(this.$placeholder);
          return this.placeholderDetached = false;
        }
      }
    };

    MentionsKinder.prototype.handleDelete = function(e) {
      var $currentMentionNode, nextNode;
      e.preventDefault();
      $currentMentionNode = $(e.target).parents('.mention');
      if ($currentMentionNode) {
        nextNode = $currentMentionNode.get(0).nextSibling;
        if (nextNode) {
          this._setCaretToStartOf(nextNode);
        }
        $currentMentionNode.remove();
        return this.populateInput();
      }
    };

    MentionsKinder.prototype._ensureInput = function(element) {
      this.$originalInput = $(element);
      if (!this.$originalInput.is('input[type=text],textarea')) {
        $.error("$.mentionsKinder works only on input[type=text] or textareas, was " + (element && element.tagName));
      }
      return this.multiline = this.$originalInput.is('textarea');
    };

    MentionsKinder.prototype._buildOptions = function(options) {
      var _this = this;
      this.options = $.extend({}, this.defaultOptions, options);
      $.each(this.options.trigger, function(trigger, triggerOptions) {
        return _this.options.trigger[trigger] = $.extend({}, _this.triggerDefaultOptions, triggerOptions);
      });
      return this.trigger = this.options.trigger || {};
    };

    MentionsKinder.prototype._setupElements = function() {
      var autofocus, placeholder;
      this.$wrap = $('<div class="mentions-kinder-wrap"></div>');
      this.$editable = $('<div class="form-control mentions-kinder" contenteditable="true"></div>');
      this.$editable.addClass("mentions-kinder-" + (this.multiline ? 'multiline' : 'singleline'));
      this.$editable.addClass(this.$originalInput.attr("class"));
      if (autofocus = this.$originalInput.attr('autofocus')) {
        this.$editable.attr('autofocus', autofocus);
      }
      if (this.$originalInput.val() !== '') {
        this.deserializeFromInput();
      }
      if (placeholder = this.$originalInput.attr('placeholder')) {
        this.$placeholder = $("<span class='placeholder'>" + placeholder + "</span>");
        this.handlePlaceholder();
      }
      this.$wrap.insertAfter(this.$originalInput);
      this.$originalInput.appendTo(this.$wrap).addClass('mentions-kinder-hidden');
      this.$editable.appendTo(this.$wrap);
      return void 0;
    };

    MentionsKinder.prototype._setupEvents = function() {
      var form,
        _this = this;
      this.$editable.bind('keypress', this.handleInput);
      this.$editable.bind('keyup', this.handleKeyup);
      this.$editable.bind('paste', this.handlePaste);
      this.$editable.bind('focus blur', this.handlePlaceholder);
      this.$editable.on('click', '.delete-mention', this.handleDelete);
      this.$originalInput.on('focus', this.focus);
      this.$originalInput.on('change', function(e) {
        if (!e.mentionsKinder) {
          return _this.deserializeFromInput();
        }
      });
      if (form = this.$originalInput.get(0).form) {
        this.$form = $(form);
        if (!this.multiline) {
          this.submitOnEnter = true;
        }
        return this.$form.on('reset', this.handleReset);
      }
    };

    MentionsKinder.prototype._getClipboardContent = function(e) {
      var _ref, _ref1;
      if ((_ref = e.originalEvent) != null ? _ref.clipboardData : void 0) {
        return e.originalEvent.clipboardData.getData('text/plain');
      } else if ((_ref1 = window.clipboardData) != null ? _ref1.getData : void 0) {
        return window.clipboardData.getData('Text');
      }
    };

    MentionsKinder.prototype._getRange = function(block) {
      var range, selection;
      selection = rangy.getSelection();
      range = selection.getRangeAt(0);
      selection.setSingleRange(range);
      return block(range, selection);
    };

    MentionsKinder.prototype._insertNode = function(node) {
      return this._getRange(function(range, selection) {
        range.insertNode(node);
        range.selectNodeContents(node);
        return selection.collapseToEnd();
      });
    };

    MentionsKinder.prototype._insertText = function(text) {
      var line, lines, nodes, _i, _len;
      lines = text.split("\n");
      nodes = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        nodes.push(document.createTextNode(line));
        nodes.push(document.createElement('BR'));
      }
      nodes.pop();
      this._getRange(function(range, selection) {
        var node, reverse, _j, _len1;
        range.deleteContents();
        reverse = nodes.reverse();
        for (_j = 0, _len1 = reverse.length; _j < _len1; _j++) {
          node = reverse[_j];
          range.insertNode(node);
        }
        range.selectNodeContents(reverse[0]);
        return selection.collapseToEnd();
      });
      return void 0;
    };

    cloneReferences = function(nodes) {
      var node, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        _results.push(node);
      }
      return _results;
    };

    MentionsKinder.prototype._cleanChildNodes = function(parentNode) {
      var node, _i, _len, _ref;
      _ref = cloneReferences(parentNode.childNodes);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        this._cleanNode(node);
      }
      return true;
    };

    MentionsKinder.prototype._cleanNode = function(node) {
      var _ref;
      if (node.nodeType === TEXT_NODE) {

      } else if (node.nodeName.toUpperCase() === 'BR') {
        if (!this.multiline) {
          $(node).replaceWith(' ');
        }
      } else if ($(node).attr('serialized-mention')) {
        $(node).attr('contenteditable', false);
      } else {
        if (((_ref = node.childNodes) != null ? _ref.length : void 0) > 0) {
          this._cleanChildNodes(node);
          $(node).replaceWith(node.childNodes);
        } else {
          $(node).remove();
        }
      }
      return true;
    };

    MentionsKinder.prototype.serializeNode = function(node) {
      return this._trim(this._tokenizeNode(node).join('')).replace(/\u00A0/g, ' ');
    };

    MentionsKinder.prototype._tokenizeNode = function(parentNode) {
      var node, serializedMention, textNodes, _i, _len, _ref;
      textNodes = [];
      _ref = parentNode.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node.nodeType === TEXT_NODE) {
          textNodes.push(node.data);
        } else if (node.nodeName.toUpperCase() === 'BR') {
          if (!this._isLastChildNode(node)) {
            textNodes.push("\n");
          }
        } else if (serializedMention = $(node).attr('serialized-mention')) {
          textNodes.push(serializedMention);
        } else if (node.nodeName.toUpperCase() === 'P' || node.nodeName.toUpperCase() === 'DIV') {
          if (this._previousNodeIsTextNode(node)) {
            textNodes.push("\n");
          }
          textNodes = textNodes.concat(this._tokenizeNode(node));
          if (!this._isLastChildNode(node)) {
            textNodes.push("\n");
          }
        } else {
          textNodes = textNodes.concat(this._tokenizeNode(node));
        }
      }
      return textNodes;
    };

    MentionsKinder.prototype._isLastChildNode = function(node) {
      return node.parentNode.lastChild === node;
    };

    MentionsKinder.prototype._previousNodeIsTextNode = function(node) {
      var _ref;
      return ((_ref = node.previousSibling) != null ? _ref.nodeType : void 0) === TEXT_NODE;
    };

    MentionsKinder.prototype._deserialize = function(text) {
      var lastText, match, pointer, regex, result;
      result = [];
      regex = this.options.deserializeRegex;
      pointer = 0;
      while (true) {
        match = regex.exec(text);
        if (match) {
          if (match.index !== 0) {
            this._deserializeText.call(result, text.substring(pointer, match.index));
          }
          pointer = regex.lastIndex;
          result.push(this.options.deserialize.apply(this, match));
        } else {
          if (pointer !== text.length) {
            lastText = text.substring(pointer, text.length);
            if (lastText !== '') {
              this._deserializeText.call(result, lastText);
            }
          }
          break;
        }
      }
      return result;
    };

    MentionsKinder.prototype._deserializeText = function(text) {
      var i, line, lines, _i, _len, _results;
      lines = text.split("\n");
      _results = [];
      for (i = _i = 0, _len = lines.length; _i < _len; i = ++_i) {
        line = lines[i];
        this.push(document.createTextNode(line));
        if (i !== lines.length - 1) {
          _results.push(this.push(document.createElement('br')));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    MentionsKinder.prototype._prepareSetCaretTo = function(node) {
      var range, selection;
      selection = rangy.getSelection();
      range = selection.getRangeAt(0);
      range.selectNodeContents(node);
      selection.setSingleRange(range);
      return selection;
    };

    MentionsKinder.prototype._setCaretToEndOf = function(node) {
      return this._prepareSetCaretTo(node).collapseToEnd();
    };

    MentionsKinder.prototype._setCaretToStartOf = function(node) {
      return this._prepareSetCaretTo(node).collapseToStart();
    };

    MentionsKinder.prototype._isCaretInTempMention = function() {
      var range;
      if (this.isAutocompleting()) {
        range = rangy.getSelection().getRangeAt(0);
        return (range != null ? range.compareNode(this._current.$tempMention.get(0)) : void 0) === range.NODE_BEFORE_AND_AFTER;
      }
    };

    MentionsKinder.prototype._trim = function(text) {
      return $.trim(text);
    };

    return MentionsKinder;

  })();

}).call(this);

(function() {
  MentionsKinder.Autocompleter = (function() {
    function Autocompleter(options) {
      if (options == null) {
        options = {};
      }
      this.mentionsKind = options.mentionsKind;
      this.options = options;
      this.initialize();
      this.deferred = $.Deferred();
      this.deferred.promise(this);
    }

    Autocompleter.prototype.initialize = function() {};

    Autocompleter.prototype.complete = function(data) {
      return this.deferred.resolve(data);
    };

    Autocompleter.prototype.abort = function() {
      return this.deferred.reject();
    };

    Autocompleter.prototype.search = function(string) {
      return $.error("implement #search in your autocompleter");
    };

    return Autocompleter;

  })();

}).call(this);


function has(object, property) {
    return object ? Object.prototype.hasOwnProperty.call(object, property) : false;
}

var extend = function(protoProps, staticProps) {
    var parent = this;
    var child;

    // The constructor function for the new subclass is either defined by you
    // (the "constructor" property in your `extend` definition), or defaulted
    // by us to simply call the parent's constructor.
    if (protoProps && has(protoProps, 'constructor')) {
        child = protoProps.constructor;
    } else {
        child = function(){ return parent.apply(this, arguments); };
    }

    // Add static properties to the constructor function, if supplied.
    $.extend(child, parent, staticProps);

    // Set the prototype chain to inherit from `parent`, without calling
    // `parent`'s constructor function.
    var Surrogate = function(){ this.constructor = child; };
    Surrogate.prototype = parent.prototype;
    child.prototype = new Surrogate;

    // Add prototype properties (instance properties) to the subclass,
    // if supplied.
    if (protoProps) $.extend(child.prototype, protoProps);

    // Set a convenience property in case the parent's prototype is needed
    // later.
    child.__super__ = parent.prototype;

    return child;
};

MentionsKinder.extend = MentionsKinder.Autocompleter.extend = extend;
(function() {
  MentionsKinder.Autocompleter.Select2Autocompleter = MentionsKinder.Autocompleter.extend({
    select2Options: {
      data: []
    },
    initialize: function() {
      var _this = this;
      this._setupInput();
      this.$input.on('select2-selecting', function(e) {
        var data;
        data = $.extend({}, {
          name: e.object.text,
          value: e.object.id
        }, e.object);
        _this.complete.call(_this, data);
        return _this.$input.select2('destroy').remove();
      });
      return this.$input.on('select2-close', function(e) {
        _this.abort.call(_this);
        return _this.$input.select2('destroy').remove();
      });
    },
    search: $.noop,
    _setupInput: function() {
      this.$input = $('<input type="hidden" />').css('width', this.mentionsKind.$editable.width()).appendTo(this.mentionsKind.$wrap);
      this.$input.select2(this.select2Options);
      return this.$input.select2('open');
    }
  });

  MentionsKinder.prototype.triggerDefaultOptions.autocompleter = MentionsKinder.Autocompleter.Select2Autocompleter;

}).call(this);

(function() {
  $.fn.mentionsKinder = function(options) {
    return this.each(function() {
      var instance;
      instance = $(this).data('mentionsKinder');
      if (instance === void 0) {
        return $(this).data('mentionsKinder', new $.MentionsKinder(this, options));
      }
    });
  };

  $.MentionsKinder = MentionsKinder;

  $.MentionsKinder.defaultOptions = MentionsKinder.prototype.defaultOptions;

  $.MentionsKinder.triggerDefaultOptions = MentionsKinder.prototype.triggerDefaultOptions;

}).call(this);

})(jQuery);