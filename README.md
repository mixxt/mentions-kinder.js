mentions-kinder.js [![Build Status](http://img.shields.io/travis/mixxt/mentions-kinder.js.svg)](https://travis-ci.org/mixxt/mentions-kinder.js)
=================
mentions-kinder is a simple and powerful input ui component that introduces all kinds of tokens/mentions in regular text inputs. Like user mentions you know from Facebook or Google+.
It tries to be as configurable and customizable as possible while providing a basic setup you can use right away.

This project is massively inspired by the [jquery-mentions-input](https://github.com/podio/jquery-mentions-input).
We maintained a version internally, collecting various patches and features from forks, but run into too many errors. That's why we decided to write our own version with a few different ideas.

The name is a pun on the german exclamation [Menschenskinder](http://www.dict.cc/?s=menschenskinder), which sounds exactly like mentions-kinder.
It can also be interpreted in the way, that this plugin provides all kinds of mentions.

Check the [demo page](http://mixxt.github.io/mentions-kinder.js) now!

## Features
- Multiple trigger chars (i.e. # => tags, @ => mentions, ! => priority)
- Configurable output serialization (i.e. \[@Jon Doe](user:id))
- Configurable autocompleters (select2, datepicker, whatever)
- Support IE8

## TODO
- Context sensitive trigger, i.e. don't trigger @-mention when entering email address, via regex (`/(^|\s)@/`), which would support multi-char triggers too
- Remove mention via BACKSPACE in Firefox and IE8 ([See this Stackoverflow post](http://stackoverflow.com/questions/9983868/contenteditable-div-ie8-not-happy-with-backspace-remove-of-html-element))
- Full documentation
- Better Tests
- Try to remove rangy dependency, extract what we really need
- Make jquery optional
- Build with require.js
- Implement datepicker-autocompleter
- Implement autocompleter using Twitter Typeahead

## Usage

It's best to check our demo page and its source for now, sorry.

```javascript
$('textarea').mentionsKinder()
```
