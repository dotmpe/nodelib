
module.exports = ( grunt ) ->

  # auto load grunt contrib tasks from package.json
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    watch:
      coffee:
        files: 'src/node/*.coffee'
        tasks: [
          'coffee:compile'
          'exec:es2015_test'
          'mochaTest:test'
        ]

      ###
      gruntfile:
        files: '<%= jshint.gruntfile.src %>'
        tasks: ['jshint:gruntfile']

      lib:
        files: '<%= jshint.lib.src %>'
        tasks: [
          'jshint:src'
          'nodeunit'
        ]

      test:
        files: '<%= jshint.test.src %>'
        tasks: [
          'test'
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
        dest: 'build/js/'
        ext: '.js'

    coffeelint:
      options:
        configFile: '.coffeelint.json'
      app: [
        'bin/*.coffee'
        'src/**/*.coffee'
        'test/**/*.coffee'
      ]

    yamllint:
      all:
        src: [
          'Sitefile.yaml'
          '**/*.metadata'
        ]

    jshint:
      options:
        jshintrc: '.jshintrc'
      gruntfile:
        src: 'Gruntfile.js'


    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          captureFile: 'mocha.out'
          quiet: false
          clearRequireCache: false
        src: ['test/mocha/*.coffee']

    exec:
      es2015_test:
        cmd: 'node --use_strict test/test.js'
      
      gulp_dist_build:
        cmd: "gulp dist-build"


    pkg: grunt.file.readJSON('package.json')


  # Static analysis of source files
  grunt.registerTask 'lint', [
    'coffeelint',
    'jshint',
    'yamllint'
  ]

  # Test both source and compiled JS
  grunt.registerTask 'test', [
    'mochaTest'
    'coffee:compile'
    'exec:es2015_test'
  ]

  grunt.registerTask 'build', [
    "exec:gulp_dist_build"
  ]

  # Everything
  grunt.registerTask 'default', [
    'lint',
    'test'
  ]

 
