# Id: nodelib/0.0.5-dev+20150802-1547 test/mocha/module.coffee

module = require '../../src/node/module'
chai = require 'chai'
#chai.should()
expect = chai.expect


describe 'The framework is composed of two extensible components.', ->


  describe 'First, the core,', ->

    it 'which is a prototype for an object', ->
      obj = new module.classes.Core {}


    describe 'that can statically configure itself,', ->

      it 'taking paths to the source'
        #core = module.classes.Core.load 'test/example/core'

      it 'optionally using config modules'
        #opts = module.classes.Core.config ''
        #core = new module.classes.Core opts

      it 'by loading the metadatafile in the current directory.'
        #core = module.classes.CoreV01.


    describe 'Core instances have ', ->

      it 'a method to load modules onto the core instance '
      it 'and a method to prime and run the application server. '


  describe 'Second is the module', ->

    it 'which is a prototype', ->
      obj = new module.classes.Module {}


    describe 'that can statically configure itself, taking a path to a directory', ->
      it 'either containing a standard module layout'
      it 'or which has a reserved-name module metadata file. '


  beforeEach ->
    global.__noderoot = ''




