# Id: nodelib/0.0.6-dev test/mocha/context.coffee

###

My usecase for context is not that big at the moment.

Just inherit the properties and add subcontexts.

###

Context = require '../../src/node/context'
chai = require 'chai'
expect = chai.expect



describe '0.1.1 Nodelib context-module', ->

  it '1 exports a class called Context', ->
    expect( Context::constructor )
    expect( Context::constructor.name ).to.equal 'Context'

  it '2 should numerically Id its instances', ->
    expect( Context.count() ).to.equal 0
    ctx1 = new Context {}
    expect( Context.count() ).to.equal 1
    expect( ctx1.id() ).to.equal 1
    expect( ctx1.toString() ).to.equal 'Context:1'
    ctx2 = new Context {}
    expect( Context.count() ).to.equal 2
    expect( ctx2.id() ).to.equal 2
    expect( ctx2.toString() ).to.equal 'Context:2'
    ctx3 = new Context {}
    expect( Context.count() ).to.equal 3
    expect( ctx3.id() ).to.equal 3
    expect( ctx3.toString() ).to.equal 'Context:3'


  describe '0.1.1.1 contructor should accept', ->

    it '1 a seed object', ->
      ctx = new Context foo: 'bar'
      expect( ctx.hasOwnProperty 'foo' ).to.equal true
      expect( ctx.foo ).to.equal 'bar'

    it '2 a seed object and (super)context property object', ->
      ctx1 = new Context foo: 'bar'
      init = foo: 'bar2'
      ctx2 = new Context init, ctx1
      expect( ctx2.foo ).to.equal 'bar2'
      expect( ctx2.context ).to.eql ctx1
      expect( ctx1.foo ).to.equal 'bar'


  describe '0.1.1.2 instances', ->

    it '2 should create and track subContexts, and override properties', ->
      ctx1 = new Context foo: 'bar'
      ctx2 = ctx1.getSub foo: 'bar2'
      expect( ctx1.foo ).to.equal 'bar'
      expect( ctx2.foo ).to.equal 'bar2'
      expect( ctx2.context ).to.eql ctx1
      # track subcontexts
      expect( ctx1._subs[0] ).to.eql ctx2
      # track subcontext ID
      expect( ctx2.id() ).to.equal '1.2'

    it "3 should inherit property values, but not export values to the super
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


    describe '0.1.1.2.1 can handle path-references', ->


      describe '0.1.1.2.1.1 which dereference', ->

        it '1 to objects', ->
          ctx = new Context foo: bar: el: 'baz'
          expect( ctx.get 'foo' ).to.eql bar: el: 'baz'
          expect( ctx.get 'foo.bar' ).to.eql el: 'baz'

        it '2 to values--even if empty', ->
          ctx = new Context foo: bar:
            str: ''
            int: 0
            bool: false
          expect( ctx.get 'foo.bar.str' ).to.equal ''
          expect( ctx.get 'foo.bar.int' ).to.equal 0
          expect( ctx.get 'foo.bar.bool' ).to.equal false

        it '3 to objects with unresolved references', ->
          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: 0
          expect( ctx.get 'foo.bar' ).to.eql $ref: '#/refs/x'

          
      describe '0.1.1.2.1.2 which resolve', ->

        it '1 to fully dereferenced objects', ->
          ctx = new Context {
            foo: bar: $ref: '#/refs/x'
            refs: x: el: 'baz'
          }
          expect( ctx.resolve 'foo' ).to.eql bar: el: 'baz'
          expect( ctx.resolve 'foo.bar' ).to.eql el: 'baz'

        it '2 to values', ->
          ctx = new Context foo: bar: el: 'baz'
          expect( ctx.resolve 'foo.bar.el' ).to.equal 'baz'

        it '3 to referenced values', ->
          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            refs: x: 0
          expect( ctx.resolve 'foo.bar' ).to.equal 0

        it '4 to values on referenced objects', ->
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

        it '5 to objects merged with reference objects', ->
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

        it '6 to objects merged with reference objects (II)', ->
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

        it '7 to fully dereferenced objects', ->
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


        it '8 to fully dereferenced lists', ->
          ctx = new Context
            foo: bar: $ref: '#/refs/x'
            foo2: $ref: '#/refs'
            refs:
              x: [
                el: 'baz'
              ]
          expect( ctx.refs ).to.eql  x: [el:'baz']
          expect( ctx.foo ).to.eql  bar: $ref:'#/refs/x'
          expect( ctx.resolve 'foo.bar' ).to.eql  [el:'baz']
          expect( ctx.resolve 'foo' ).to.eql  bar: [el:'baz']
          expect( ctx.foo2 ).to.eql  $ref:'#/refs'
          expect( ctx.resolve 'foo2' ).to.eql  x: [el:'baz']


      describe '0.1.1.2.1.3 which may contain paths as keys', ->

        it '1 dereferences', ->
          ctx = new Context x: "foo/bar": 'baz'
          expect( ctx.get 'x.foo/bar' ).to.eql 'baz'

        it '2 resolves', ->
          ctx = new Context x: "foo/bar": 'baz'
          expect( ctx.resolve "x.foo/bar" ).to.eql 'baz'

          ctx = new Context {
            x: "foo/bar": $ref: '#/y/foo\\/bar'
            y: "foo/bar": 'baz'
          }
          expect( ctx.resolve "x.foo/bar" ).to.eql 'baz'


      describe '0.1.1.2.1.3 which may contain periods as keys', ->

        it '1 dereferences', ->
          ctx = new Context {
            x: "foo/bar.ext": $ref: '#/y/foo\\/bar'
            y: "foo/bar": 'baz'
          }
          expect( ctx.get "x.foo/bar\\.ext" ).to.eql $ref: '#/y/foo\\/bar'

        it '2 resolves', ->
          ctx = new Context {
            x: "foo/bar.ext": $ref: '#/y/foo\\/bar'
            y: "foo/bar": 'baz'
          }
          expect( ctx.resolve "x.foo/bar\\.ext" ).to.eql 'baz'


      describe '0.1.1.2.1.4 merges', ->

        it "1.merges", ->
          ctx = new Context {
            a: 1
            b:
              c: 2
          }
          #expect( ctx.merge $ref: '#/b' ).to.eql { $ref: '#/b' }
          #expect( ctx.merge $ref: '#/b/c' ).to.eql { $ref: '#/b/c' }
          expect( ctx.merge foo: bar: $ref: '#/b' ).to.eql foo: bar: c: 2
          expect( ctx.merge foo: bar: $ref: '#/b/c' ).to.eql foo: bar: 2


  beforeEach ->
    Context.reset()

  afterEach ->
    delete ctx


