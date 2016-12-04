# Id: nodelib/0.0.5-dev+20161126-0155 test/mocha/context.coffee

###

My usecase for context is not that big at the moment.

Just inherit the properties and add subcontexts.

###


Context = require '../../src/node/context'
chai = require 'chai'
expect = chai.expect


describe 'Nodelib context-module', ->

  it 'exports a class called Context', ->

    expect( Context::constructor )
    expect( Context::constructor.name ).to.equal 'Context'

  it 'should numerically Id its instances', ->

    expect( Context.count() ).to.equal 0
    ctx1 = new Context {}
    expect( Context.count() ).to.equal 1
    expect( ctx1.id() ).to.equal 'ctx:1'
    ctx2 = new Context {}
    expect( Context.count() ).to.equal 2
    expect( ctx2.id() ).to.equal 'ctx:2'
    ctx3 = new Context {}
    expect( Context.count() ).to.equal 3
    expect( ctx3.id() ).to.equal 'ctx:3'


  describe 'contructor should accept', ->
    it 'a seed object', ->

      ctx = new Context foo: 'bar'
      expect( ctx.hasOwnProperty 'foo' ).to.equal true
      expect( ctx.foo ).to.equal 'bar'

    it 'a seed object and (super)context property object', ->

      ctx1 = new Context foo: 'bar'
      init = foo: 'bar2'
      ctx2 = new Context init, ctx1
      expect( ctx2.foo ).to.equal 'bar2'
      expect( ctx2.context ).to.eql ctx1
      expect( ctx1.foo ).to.equal 'bar'


  describe 'instances', ->
    it 'should create and track subContexts, and override properties', ->

      ctx1 = new Context foo: 'bar'
      ctx2 = ctx1.getSub foo: 'bar2'
      expect( ctx1.foo ).to.equal 'bar'
      expect( ctx2.foo ).to.equal 'bar2'
      expect( ctx2.context ).to.eql ctx1
      # track subcontexts
      expect( ctx1._subs[0] ).to.eql ctx2
      # track subcontext ID
      expect( ctx2.id() ).to.equal 'ctx:1.2'

    it "should inherit property values, but not export values to the super
        context", ->

      ctx1 = new Context foo: 'bar'
      ctx2 = ctx1.getSub x: 9
      expect( ctx2.foo ).to.equal 'bar'
      ctx1.foo = 'bar2'
      expect( ctx1.foo ).to.equal 'bar2'
      expect( ctx2.foo ).to.equal 'bar2'
      expect( ctx1.hasOwnProperty 'x' ).to.equal false
      expect( ctx2.hasOwnProperty 'x' ).to.equal true
      expect( ctx2.x ).to.equal 9

    describe 'can handle path-references', ->

      describe 'which dereference', ->
        it 'to objects', ->

          ctx = new Context foo: bar: el: 'baz'
          expect( ctx.get 'foo' ).to.eql bar: el: 'baz'
          expect( ctx.get 'foo.bar' ).to.eql el: 'baz'

        it 'to values--even if empty', ->

          ctx = new Context foo: bar:
            str: ''
            int: 0
            bool: false
          expect( ctx.get 'foo.bar.str' ).to.equal ''
          expect( ctx.get 'foo.bar.int' ).to.equal 0
          expect( ctx.get 'foo.bar.bool' ).to.equal false

        it 'to objects with unresolved references', ->

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: 0
          expect( ctx.get 'foo.bar' ).to.eql $ref: '#/refs/x'

      describe 'which resolve', ->
        it 'to fully dereferenced objects', ->

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: el: 'baz'
          expect( ctx.resolve 'foo' ).to.eql bar: el: 'baz'
          expect( ctx.resolve 'foo.bar' ).to.eql el: 'baz'

        it 'to values', ->

          ctx = new Context foo: bar: el: 'baz'
          expect( ctx.resolve 'foo.bar.el' ).to.equal 'baz'

        it 'to referenced values', ->

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: 0
          expect( ctx.resolve 'foo.bar' ).to.equal 0

        it 'to values on referenced objects', ->

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: el: 'baz'
          expect( ctx.resolve 'foo.bar.el' ).to.equal 'baz'

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs:
              x: el: $ref: '#/refs/el'
              el: 'baz'
          expect( ctx.resolve 'foo.bar.el' ).to.equal 'baz'

          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs:
              x: el: $ref: '#/refs/el'
              el: x2: $ref: '#/refs/x2'
              x2: 'baz'
          expect( ctx.resolve 'foo.bar.el.x2' ).to.equal 'baz'

        it 'to objects merged with reference objects', ->

          ctx = new Context
            foo: bar:
              x: 1
              x2: 1
              $ref: '#/refs/x'
            refs:
              x:
                x: 2
                y: 2
          expect( ctx.resolve 'foo.bar.y' ).to.equal 2
          expect( ctx.resolve 'foo.bar.x' ).to.equal 2
          expect( ctx.resolve 'foo.bar.x2' ).to.equal 1

        it 'to objects merged with reference objects (II)', ->

          ctx = new Context
            foo: bar:
              x:
                x: 1
                y: 1
              y: 1
              z: 1
              $ref: '#/refs/x'
            refs:
              x:
                y: 2
                x:
                  x: 2
                  y: 2
          expect( ctx.resolve 'foo.bar.x' ).to.eql { x: 2, y: 2 }
          expect( ctx.resolve 'foo.bar.y' ).to.eql 2
          expect( ctx.resolve 'foo.bar.z' ).to.eql 1

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

          refs =
            x:
              el: 'baz'
              x2:
                int: 0
                bool: false
                x3: 'test'
            x2:
              int: 0
              bool: false
              x3: 'test'
            x3: 'test'

          expect( ctx.resolve 'refs.x3' ).to.eql refs.x3
          expect( ctx.resolve 'refs.x2' ).to.eql refs.x2
          expect( ctx.resolve 'refs.x' ).to.eql refs.x
          expect( ctx.resolve 'foo' ).to.eql foo
          expect( ctx.resolve 'foo.bar' ).to.eql foo.bar
          expect( ctx.resolve 'foo.bar.el' ).to.eql foo.bar.el
          expect( ctx.resolve 'foo.bar.x2' ).to.eql foo.bar.x2
          expect( ctx.resolve 'foo.bar.x2.bool' ).to.eql foo.bar.x2.bool
          expect( ctx.resolve 'foo.bar.x2.int' ).to.eql foo.bar.x2.int
          expect( ctx.resolve 'foo.bar.x2.x3' ).to.eql foo.bar.x2.x3


  beforeEach ->
    Context.reset()

  afterEach ->
    delete ctx


