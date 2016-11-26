# Id: nodelib/0.0.5-dev+20161126-0155 test/mocha/route.coffee

###

###

route = require '../../src/node/route'
chai = require 'chai'
#chai.should()
expect = chai.expect

appMock =
  all: null
  get: null
  put: null
  post: null
  options: null
  delete: null

urlBase = 'scheme:root/path'
moduleMock = route:
  name1:
    route: null
    all: null
    get: null
    put: null
    post: null
    options: null
    delete: null


describe "Module 'route'", ->

  it "has one principal function applyRoutes", ->
    expect( route.applyRoutes )


  describe "works with metadata objects containing a 'route' attribute", ->
    it "the value of which is an object"

    describe "that may hold any of the HTTP verbs", ->
      it "with a resolvable named handler"
      it "with a dynamic reference to a callable handler"

    it "which may hold the same key to a sub-route"


  describe "applies URL route handlers to an Express instance from static
  or dynamic metadata. ", ->
    
    it "XXX take an express, urlBase, mock arg, and return an merged route", ->
      routes = route.applyRoutes appMock, urlBase, moduleMock
      expect( routes.route )
    it "It can recursively traverse the 'route' key from an object"
    it "It can take names of handlers for singleton controllers"
    it "It can take dynamic references to handlers"


