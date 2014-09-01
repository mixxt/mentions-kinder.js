'use strict';

module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        // Metadata.
        pkg: grunt.file.readJSON('bower.json'),
        banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.company %>;' +
            ' Licensed <%= pkg.license %> */\n',
        // Task configuration.
        clean: {
            files: ['dist', 'tmp', 'test/*test.js']
        },
        coffee: {
            dev:{
                expand: true,
                cwd: 'src',
                src: ['**/*.coffee'],
                dest: 'tmp/src',
                ext: '.js'
            },
            test:{
                files:{
                    'tmp/tests.js':'test/**/*.coffee'
                }
            }
        },
        concat: {
            options: {
                banner: '<%= banner %>' +
                    "(function($){\n",
                footer: "\n})(jQuery);",
                stripBanners: true
            },
            dev: {
                src: [
                    'tmp/src/mentions-kinder.js',
                    'tmp/src/autocompleter.js',
                    'src/extend-patch.js',
//                    'tmp/src/autocompleter/dummy-autocompleter.js',
                    'tmp/src/autocompleter/select2-autocompleter.js',
                    'tmp/src/jquery-plugin.js'
                ],
                dest: 'tmp/mentions-kinder.js',
                nonull: true
            },
            dist: {
                src: [
                    'tmp/src/mentions-kinder.js',
                    'tmp/src/autocompleter.js',
                    'src/extend-patch.js',
//                    'tmp/src/autocompleter/dummy-autocompleter.js',
                    'tmp/src/autocompleter/select2-autocompleter.js',
                    'tmp/src/jquery-plugin.js'
                ],
                dest: 'dist/mentions-kinder.js',
                nonull: true
            },
            dist_rangy: {
                src: [
                    'tmp/src/mentions-kinder.js',
                    'tmp/src/autocompleter.js',
                    'src/extend-patch.js',
//                    'tmp/src/autocompleter/dummy-autocompleter.js',
                    'tmp/src/autocompleter/select2-autocompleter.js',
                    'bower_components/rangy/rangy-core.js',
                    'tmp/src/jquery-plugin.js',
                    'tmp/src/init-rangy.js'
                ],
                dest: 'dist/mentions-kinder.rangy.js',
                nonull: true
            }
        },
        uglify: {
            options: {
                banner: '<%= banner %>'
            },
            dist: {
                src: '<%= concat.dist.dest %>',
                dest: 'dist/mentions-kinder.min.js'
            },
            dist_rangy: {
                src: '<%= concat.dist_rangy.dest %>',
                dest: 'dist/mentions-kinder.rangy.min.js'
            }
        },
        qunit: {
            files: ['test/**/*-test.html']
        },
        watch: {
            all:{
                files:['src/**/*.coffee', 'test/**/*.coffee'],
                tasks:['test']
            }
        },
        connect: {
            server: {
                options: {
                    hostname: '0.0.0.0',
                    port: 1338
                }
            }
        }
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-qunit');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-connect');

    grunt.registerTask('doc:dist', function(){
        if(grunt.file.exists('doc')){
            var source_js = grunt.config.get('uglify.dist.dest'),
                destination_js = "doc/"+source_js,
                source_css = 'dist/mentions-kinder.css',
                destination_css = "doc/"+source_css;
            grunt.file.copy(source_js, destination_js);
            grunt.file.copy(source_css, destination_css);
        }
        else {
            var repo = "git@github.com:mixxt/mentions-kinder.js.git",
                options = "--branch gh-pages --single-branch";
            grunt.fail.warn("doc folder not found, run this first:\n\n\t git clone "+ options +" "+ repo +" doc\n\n");
        }
    });

    grunt.registerTask('css:dist', function(){
        var source_css = 'css/mentions-kinder.css',
            dist_css = "dist/mentions-kinder.css";
        grunt.file.copy(source_css, dist_css);
    });

    // Default task.
    grunt.registerTask('precompile', ['coffee:dev', 'coffee:test', 'concat:dev']);
    grunt.registerTask('dist', [
        'coffee:dev', 'coffee:test',
        'concat:dist', 'concat:dist_rangy',
        'uglify:dist', 'uglify:dist_rangy',
        'css:dist',
        'doc:dist'
    ]);
    grunt.registerTask('test', ['precompile', 'qunit']);
    grunt.registerTask('server', ['precompile', 'connect:server', 'watch']);
    grunt.registerTask('default', 'test');

};
