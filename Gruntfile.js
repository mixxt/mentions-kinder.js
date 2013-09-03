'use strict';

module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        // Metadata.
        pkg: grunt.file.readJSON('mentions-kinder.jquery.json'),
        banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
            ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',
        // Task configuration.
        clean: {
            files: ['dist', 'test/*.js', 'src/*.js']
        },
        coffee: {
            dev:{
                files:{
                    'src/mentions-kinder.js':'src/*.coffee'
                }
            },
            test:{
                files:{
                    'test/tests.js':'test/*.coffee'
                }
            }
        },
//    concat: {
//      options: {
//        banner: '<%= banner %>',
//        stripBanners: true
//      },
//      dist: {
//        src: ['src/<%= pkg.name %>.js'],
//        dest: 'dist/<%= pkg.name %>.js'
//      },
//    },
//    uglify: {
//      options: {
//        banner: '<%= banner %>'
//      },
//      dist: {
//        src: '<%= concat.dist.dest %>',
//        dest: 'dist/<%= pkg.name %>.min.js'
//      },
//    },
        qunit: {
            files: ['test/**/*.html']
        },
        watch: {
            all:{
                files:['src/*.coffee', 'test/*.coffee'],
                tasks:['coffee:dev', 'coffee:test', 'qunit']
            }
        },
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-qunit');
    grunt.loadNpmTasks('grunt-contrib-watch');

    // Default task.
    grunt.registerTask('default', ['coffee:dev', 'coffee:test', 'qunit']);

};
