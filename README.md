
mentions-kinder.js [![Build Status](https://travis-ci.org/mixxt/mentions-kinder.js.png?branch=master)](https://travis-ci.org/mixxt/mentions-kinder.js)
=================
mentions-kinder is a simple and powerful input ui component that introduces all kinds of tokens/mentions in regular text inputs. Like user mentions you know from Facebook or Google+.
It tries to be as configurable and customizable as possible while providing a basic setup you can use right away.

This project is massively inspired by the [jquery-mentions-input](https://github.com/podio/jquery-mentions-input).
We maintained a version internally, collection various patches and features from forks, but run into too many errors. That's why we decided to write our own version with a few different ideas.

The name is a pun on the german exclamation [Menschenskinder](http://www.dict.cc/?s=menschenskinder), which sounds exactly like mentions-kinder.
It can also be interpreted in the way, that this plugin provides all kinds of mentions.

Check the [demo page](http://mixxt.github.io/mentions-kinder.js) now!

## Features
- [x] Browser Support: IE8+
- [x] Browser Support: Firefox
- [x] Browser Support: Chrome
- [x] Multiple trigger chars (i.e. # => tags, @ => mentions, ! => priority)
- [x] Configurable output syntax
- [x] Configurable autocompleters (i.e. select2 or a static value list)
- [x] Mime default behaviour: Autofocus
- [x] Mime default behaviour: submit on return in single line inputs

## TODO
- [ ] Context sensitive trigger, i.e. don't trigger @-mention when entering email address, via regex (`/(^|\s)@/`), which would support multi-char triggers too
- [ ] Remove mention via BACKSPACE in Firefox and IE8 ([See this Stackoverflow post](http://stackoverflow.com/questions/9983868/contenteditable-div-ie8-not-happy-with-backspace-remove-of-html-element))
- [ ] Full documentation
- [ ] Better Tests
- [ ] Try to remove rangy dependency, extract what we really need
- [ ] Make jquery optional
- [ ] Build with require.js
- [ ] Implement Datepicker-Autocompleter
- [ ] Implement Autocompleter using Twitter Typeahead

## Usage

It's best to check our demo page and its source for now, sorry.

```javascript
$('textarea').mentionsKinder()
```
