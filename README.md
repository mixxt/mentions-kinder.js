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

## Developing
1.  Install node.js
2.  Install node.js Packages

    ```bash
    npm install
    ```
3.  Use grunt to run specs and compile CoffeeScript on the fly

    ```bash
    grunt server
    ```
4. If you develop a feature? Use a feature branch!

    ```bash
    git checkout -b feature-name_of_my_feature
    ```

## Create distribution
1.  Bump version in **package.json** and **mentions-kinder.jquery.json**
2.  Commit Version

    ```bash
    git commit -m "Bump version to x.x.x"
    ```
3.  Create distribution branch (__dist-x.x.x__)

    ```bash
    git checkout -b dist-x.x.x
    ```
4.  Create distribution / Compile and minify the CoffeeScript to JavaScript

    ```bash
    grunt dist
    ```
5.  Add and commit created JavaScript files

    ```bash
    git add .
    git commit -m "x.x.x"
    ```
6. Create annotated tag for this version

    ```bash
    git tag -a -m x.x.x x.x.x
    ```
7.  Push the distribution branch and the tag

    ```bash
    git push -u origin dist-x.x.x
    git push --tags
    ```
8.  Add and commit the updated version in the documentation directory

    ```bash
    cd doc/
    git add .
    git commit -m "Use version x.x.x"
    git push
    ```
9.  Switch back to the develop branch and push the changes

    ```bash
    cd ..
    git checkout develop
    git push
    ```
