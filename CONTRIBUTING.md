# Contributing

## Important notes
Please don't edit files in the `dist` subdirectory as they are generated via Grunt. You'll find source code in the `src` subdirectory!

### Code style
Regarding code style like indentation and whitespace, **follow the conventions you see used in the source already.**

### PhantomJS
While Grunt can run the included unit tests via [PhantomJS](http://phantomjs.org/), this shouldn't be considered a substitute for the real thing. Please be sure to test the `test/*.html` unit test file(s) in _actual_ browsers.

## Modifying the code
First, ensure that you have the latest [Node.js](http://nodejs.org/) and [npm](http://npmjs.org/) installed.

Test that Grunt's CLI is installed by running `grunt --version`.  If the command isn't found, run `npm install -g grunt-cli`.  For more information about installing Grunt, see the [getting started guide](http://gruntjs.com/getting-started).

1. Fork and clone the repo.
1. Run `npm install` to install all dependencies (including Grunt).
1. Run `grunt` to grunt this project.

Assuming that you don't see any red, you're ready to go. Just be sure to run `grunt` after making any changes, to ensure that nothing is broken.

## Submitting pull requests

1. Create a new branch, please don't work in your `master` branch directly.
1. Add failing tests for the change you want to make. Run `grunt` to see the tests fail.
1. Fix stuff.
1. Run `grunt` to see if the tests pass. Repeat steps 2-4 until done.
1. Open `test/*.html` unit test file(s) in actual browser to ensure tests pass everywhere.
1. Update the documentation to reflect any changes.
1. Push to your fork and submit a pull request.

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
2.  Add and commit version bump

    ```bash
    git add .
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
