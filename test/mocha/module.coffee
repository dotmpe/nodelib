# Id: nodelib/0.0.8 test/mocha/module.coffee

module = require '../../src/node/module'
chai = require 'chai'
chai.should()
expect = chai.expect


describe "Module 'nodelib.module' provides classes and routines to set up
    an Express application. ", ->

  describe 'To do so it has a framework composed of \
      two extensible components.', ->


    describe 'First, the core,', ->

      it 'which is a prototype for an object', ->
        obj = new module.classes.Core {}
        obj.should.be.an 'object'


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


      describe "that can statically configure itself,
          taking a path to a directory", ->
        it 'either containing a standard module layout'
        it 'or which has a reserved-name module metadata file. '


    beforeEach ->
      global.__noderoot = ''


  describe "To start an express-mvc 0.1 application", ->
 
    it "it requires a global init. FIXME: fix this somehow. ", ->
      module.init process.cwd()

    it "it requires to load a core component from a module", ->
      module.init process.cwd()
      core = module.load_core 'test/example/core'
      expect( core ).to.be.an 'object'
      expect( core.app ).to.be.an 'undefined'
      expect( core.server ).to.be.an 'undefined'
      expect( core.root ).to.be.an 'undefined'
      expect( core.pkg ).to.be.an 'undefined'
      expect( core.config ).to.be.an 'undefined'
      expect( core.meta ).to.be.an 'undefined'
      expect( core.url ).to.be.an 'undefined'
      expect( core.path ).to.be.an 'undefined'
      expect( core.route ).to.be.an('object').that.is.empty
      expect( core.base ).to.be.an('object').that.is.empty
      expect( core.controllers ).to.be.an('object').that.is.empty
      expect( core.routes ).to.be.an('object').that.is.empty
      expect( core.models ).to.be.an('object').that.is.empty
      expect( core.params ).to.be.an('object').that.is.empty
      expect( core.name ).to.be.string 'core'
      expect( core.meta ).to.be.an 'undefined'


    it "TODO: it requires a call to configure the core component", ->
      module.init process.cwd()
      core = module.load_core 'test/example/core'
      #core.configure()

    it "TODO: it can load extensions. ", ->
      module.init process.cwd()
      core = module.load_core 'test/example/core'
      #core.configure()
      #core.load_modules()

    it "TODO: it finally has a function to start the Express app. ", ->
      module.init process.cwd()
      core = module.load_core 'test/example/core'
      #core.configure()
      #core.load_modules()
      # FIXME: euhm.. build or find interrupt mechanism and start this in a
      #        coroutine core.start()

#
