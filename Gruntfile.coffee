"use strict"

load_grunt_tasks = require("load-grunt-tasks")

module.exports = ( grunt ) ->

  # auto load grunt contrib tasks from package.json
  load_grunt_tasks(grunt)

  grunt.initConfig
    watch:
      coffee:
        files: "src/node/*.coffee"
        tasks: [
          "coffee:lib"
          "exec:es2015_test"
          "mochaTest:test"
        ]

      ###
      gruntfile:
        files: "<%= jshint.gruntfile.src %>"
        tasks: ["jshint:gruntfile"]

      lib:
        files: "<%= jshint.lib.src %>"
        tasks: [
          "jshint:src"
          "nodeunit"
        ]

      test:
        files: "<%= jshint.test.src %>"
        tasks: [
          "test"
        ]
      ###

    coffee:
      lib:
        expand: true
        flatten: true
        cwd: "#{__dirname}/src/node/"
        src: [
           "*.coffee"
        ],
        dest: "build/js/lib/src/node/"
        ext: ".js"

      dev:
        expand: true
        cwd: "#{__dirname}/"
        src: [
           "bin/*.coffee"
           "src/node/*.coffee"
           "*.coffee"
           "test/example/core/*.coffee"
           "test/mocha/*.coffee"
        ],
        dest: "build/js/lib-dev"
        ext: ".js"

      test:
        expand: true
        cwd: "#{__dirname}/"
        src: [
           "test/example/core/*.coffee"
           "test/mocha/*.coffee"
        ],
        dest: "build/js/lib-test"
        ext: ".js"

    jshint:
      options:
        jshintrc: ".jshintrc"
      gulpfile: [ "gulpfile.js" ]
      package: [ "*.json" ]

    coffeelint:
      options:
        configFile: ".coffeelint.json"
      gruntfile: [ "Gruntfile.coffee" ]
      app: [
        "bin/*.coffee"
        "src/**/*.coffee"
        "test/**/*.coffee"
      ]

    yamllint:
      all: [
        "Sitefile.yaml"
        "package.yaml"
        "**/*.meta"
      ]

    mochaTest:
      test:
        options:
          reporter: "spec"
          require: "coffee-script/register"
          captureFile: "mocha.out"
          quiet: false
          clearRequireCache: false # do explicitly as needed
        src: ["test/mocha/*.coffee"]

    exec:
      check_version:
        cmd: "git-versioning check"

      es2015_test:
        cmd: "node --use_strict test/test.js"
      
      gulp_dist_build:
        cmd: "gulp dist-build"

      spec_update:
        cmd: "sh ./tools/update-spec.sh"

      tasks_update:
        cmd: "sh ./tools/tasks.sh"

      nodelib_deps_g:
        cmd: "make dep-g"

    pkg: grunt.file.readJSON "package.json"


  # Static analysis of source files
  grunt.registerTask "lint", [ "coffeelint", "jshint", "yamllint" ]

  # Test both source and compiled JS lib
  grunt.registerTask "test", [ "mochaTest", "coffee:lib", "exec:es2015_test" ]

  # Project pre-commit
  grunt.registerTask "check", [ "exec:check_version", "lint" ]
  grunt.registerTask "default", [ "lint", "test" ]

  # Build dist
  grunt.registerTask "dist", [
    "coffee:lib"
    "exec:gulp_dist_build"
  ]
  # documentation artefacts, some intial publishing
  grunt.registerTask "build", [
    "dist"
    "exec:nodelib_deps_g"
  ]

  # Looking for better build and module config
  grunt.registerTask "x-build", [
    "build"
    "exec:spec_update"
  ]
