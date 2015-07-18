# Id: nodelib/0.0.5-test+20150718-1851 test/mocha/context.coffee

###

My usecase for context is not that big at the moment.

Just inherit the properties and add subcontexts.

###
Context = require '../../src/node/context'
chai = require 'chai'
#chai.should()
expect = chai.expect

describe 'Nodelib context-module', ->

  it 'exports a class called Context', ->
    expect( Context::constructor )
    expect( Context::constructor.name ).to.equal 'Context'

  it 'should numerically Id its instances', ->

  describe 'contructor should accept', ->
    it 'a seed object', ->
    it 'a seed object and (super)context property object', ->

  describe 'instances', ->
    it 'should create and track subContexts, and override properties', ->
    it 'should inherit property values, but not export values to the super context', ->

    describe 'get path-reference', ->

      describe 'which dereference', ->
        it 'to objects', ->
        it 'to values--even if empty', ->
        it 'to objects with unresolved references', ->

      describe 'which resolve', ->
        it 'to fully dereferenced objects', ->
        it 'to values', ->
        it 'to referenced values', ->
        it 'to values on referenced objects', ->
        it 'to objects merged with reference objects', ->
        it 'to objects merged with reference objects (II)', ->
        it 'to fully dereferenced objects', ->

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs:
              x:
                el: 'baz'
                x2: $ref: '#/refs/x2'
              x2:
                int: 0
                bool: false
                x3: $ref: '#/refs/x3'
              x3: 'test'

          foo = bar:
            el: 'baz'
            x2: int: 0, bool: false, x3: 'test'

          expect( ctx.resolve 'foo' ).to.equal foo


  beforeEach ->
    Context.reset()

  afterEach ->
    delete ctx

