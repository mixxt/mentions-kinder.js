[![Build Status](https://travis-ci.org/mixxt/mentions-kinder.js.png?branch=develop)](https://travis-ci.org/mixxt/mentions-kinder.js)

mentions-kinder.js
=================

## Goals
- multiple trigger chars (tags, mentions, etc.)
- configurable output syntax
- unit tests
- support different autocompleters
- IE8 Support

## TODO
- explain name
- context sensitive trigger, i.e. don't trigger @-mention when entering email address, via regex (`/(^|\s)@/`), which would support multi-char triggers too
- support input[type=text] aka single line input
- try to remove rangy dependency, extract what we really need
- make jquery optional

## Credits
Massively inspired by https://github.com/podio/jquery-mentions-input
We maintained a version internally for a few months which consisted various patches from forks and decided to try a rewrite.
