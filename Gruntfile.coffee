"use strict"

module.exports = ( grunt ) ->

  # auto load grunt contrib tasks from package.json
  require("load-grunt-tasks")(grunt)

  grunt.initConfig
    watch:
      coffee:
        files: "src/node/*.coffee"
        tasks: [
          "coffee:compile"
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
      compile:
        expand: true
        flatten: true
        cwd: "#{__dirname}/src/node/"
        src: [
           "*.coffee"
        ],
        dest: "build/js/"
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

      nodelib_deps_svg:
        cmd: "madge --image doc/assets/nodelib-deps.svg build/js/*.js"

    pkg: grunt.file.readJSON "package.json"


  # Static analysis of source files
  grunt.registerTask "lint", [
    "coffeelint"
    "jshint"
    "yamllint"
  ]

  grunt.registerTask "check", [
    "exec:check_version"
    "lint"
  ]

  # Test both source and compiled JS
  grunt.registerTask "test", [
    "mochaTest"
    "coffee:compile"
    "exec:es2015_test"
  ]

  # Everything
  grunt.registerTask "default", [
    "lint"
    "test"
  ]

  # Documentation artefacts, some intial publishing
  grunt.registerTask "build", [
    "coffee:compile"
    "exec:gulp_dist_build"
    "exec:nodelib_deps_svg"
  ]

  grunt.registerTask "x-build", [
    "build"
    "exec:spec_update"
  ]
