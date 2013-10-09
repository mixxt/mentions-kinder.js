[![Build Status](https://travis-ci.org/mixxt/mentions-kinder.js.png?branch=develop)](https://travis-ci.org/mixxt/mentions-kinder.js)

mentions-kinder.js
=================
Mentions-Kinder is a simple and powerful input ui component that enables mentions in a text message, like in Facebook or Google+.

This project is massively inspired by the [jquery-mentions-input](https://github.com/podio/jquery-mentions-input).
We maintained a version internally which consisted various patches from forks, but we run into too many errors and it isn't supported anymore, so we decided to try a clean rewrite.

New features, better support and a modern approach!

The Mentions-Kinder project is started by [Christoph Geschwind](http://github.com/1st8) and [Axel Wahlen](http://github.com/dino115) from [mixxt GmbH](http://www.mixxt.de).

**Attention:** This project is an early beta version!

## Demo
Check out the demo page (beta/click dummy)
http://mixxt.github.io/mentions-kinder.js

## Features
- [x] Browser Support: IE8+
- [x] Browser Support: Firefox
- [x] Browser Support: Chrome
- [x] Multiple trigger chars (for example: # => tags, @ => mentions, ! => priority)
- [x] Configurable output syntax
- [x] Configurable autocompleters (for example select2 or a static value list)
- [x] Mime default behaviour: Autofocus
- [x] Mime default behaviour: submit on return in single line inputs
- [x] Unit Tests

## TODO
- [ ] Explain name
- [ ] Add API for change/reset/etc.
- [ ] Context sensitive trigger, i.e. don't trigger @-mention when entering email address, via regex (`/(^|\s)@/`), which would support multi-char triggers too
- [ ] Remove mention via BACKSPACE in Firefox and IE8 ([See this Stackoverflow post](http://stackoverflow.com/questions/9983868/contenteditable-div-ie8-not-happy-with-backspace-remove-of-html-element))
- [ ] Full documentation
- [ ] Try to remove rangy dependency, extract what we really need
- [ ] Make jquery optional

## Usage
comming soon

```javascript
$('textarea').mentionsKinder()
```
