'use strict';

module.exports = function(grunt) {

  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
    },

    coffeelint: {
      options: {
        configFile: '.coffeelint.json'
      },
      app: [
        'bin/*.coffee',
        'src/**/*.coffee',
        'test/**/*.coffee'
      ]
    },

    yamllint: {
      all: {
        src: [
          'Sitefile.yaml',
          '**/*.metadata'
        ]
      }
    },

    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: 'coffee-script/register',
          captureFile: 'mocha.out',
          quiet: false,
          clearRequireCache: false
        },
        src: ['test/mocha/*.coffee']
      }
    },

    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      lib: {
        files: '<%= jshint.lib.src %>',
        tasks: [
          'jshint:src',
          'nodeunit'
        ]
      },
      test: {
        files: '<%= jshint.test.src %>',
        tasks: [
          'test'
        ]
      },
    },

  });

  // auto load grunt contrib tasks from package.json
  require('load-grunt-tasks')(grunt);

  grunt.registerTask('lint', [
    'coffeelint',
    'jshint',
    'yamllint'
  ]);

  grunt.registerTask('test', [
    'mochaTest'
  ]);

  grunt.registerTask('default', [
    'lint',
    'test'
  ]);

};
