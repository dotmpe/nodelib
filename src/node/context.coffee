###
A coffeescript implementation of a context
with inheritance and override.

See also dotmpe/invidia for JS 
###
_ = require 'lodash'

error = require './error'


ctx_prop_spec = ( desc ) ->
  _.defaults desc,
    enumerable: false
    configurable: true

refToPath = ( ref ) ->
  if not ref.match /#\/.*/
    throw new Error "Absolute JSON ref only support"
  ref.substr(2).replace /\//g, '.'

class Context

  constructor: ( init, ctx=null ) ->
    @_instance = ++ Context._i
    @context = ctx
    @_defaults = init
    @_data = {}
    @_subs = []
    if ctx and ctx._data
      @prepare_properties ctx._data
    @prepare_properties init
    @seed init

  id: ->
    if @context
      return @context.id() + '.' + @_instance
    return 'ctx:' + @_instance

  toString: ->
    #console.log @constructor.name
    #console.log @path
    #( @constructor.name +':'+ @path )
    'Context:'+@path

  isEmpty: ->
    not _.isEmpty @_data

  # return a getter for property `k`
  _ctxGetter: ( k ) ->
    ->
      if k of @_data
        @_data[ k ]
      else if @context?
        @context[ k ]

  # return a setter for property `k`
  _ctxSetter: ( k ) ->
    ( newVal ) ->
      @_data[ k ] = newVal

  # seed property data from obj
  seed: ( obj ) ->
    for k, v of obj
      @_data[ k ] = v

  # Create local properties using keys in obj
  prepare_properties: ( obj ) ->
    for k, v of obj
      if k of @_data
        continue
      @ctx_property k,
        get: @_ctxGetter( k )
        set: @_ctxSetter( k )

  subs: ->
    return @_subs

  # get new subcontext:
  # create new SubContext instance that inherits from current instance
  getSub: ( init ) ->
    class SubContext extends Context
      constructor: ( init, sup ) ->
        Context.call @, init, sup
    sub = new SubContext init, @
    @_subs.push sub
    sub

  # get an object by json path reference,
  get: ( path ) ->
    p = path.split '.'
    c = @
    while p.length
      name = p.shift()
      if name of c
        c = c[ name ]
      else
        throw new error.NonExistantPathElementException "Unable to get #{name} of #{path}"
    c

  # get an object by json path reference,
  # and resolve all contained references too
  resolve: ( path, defaultValue ) ->
    p = path.split '.'
    c = @

    while p.length

      if '$ref' of c
        lc = c
        try
          c = @get refToPath c.$ref
        catch error
          if defaultValue?
            return defaultValue
          throw error
        if _.isPlainObject c
          delete lc.$ref
          _.merge lc, c

      name = p.shift()

      if name of c
        c = c[ name ]

        if _.isObject( c ) and '$ref' of c
          lc = c
          try
            c = @get refToPath c.$ref
          catch error
            if defaultValue?
              return defaultValue
            throw error
          if _.isPlainObject c
            delete lc.$ref
            c = _.merge lc, c

      else
        throw new Error "Unable to resolve #{name} of #{path}"

    if _.isPlainObject c
      return @merge c

    c

  merge: ( c ) ->
    self = @
    # recursively replace $ref: '..' with dereferenced value
    # XXX this starts top-down, but forgets context. may need to globalize
    merge = ( result, value, key ) ->
      if _.isArray value
        for item, index in value
          merge value, item, index
      else if _.isPlainObject value
        if '$ref' of value 
          merged = self.merge self.get refToPath value.$ref
          delete value.$ref
          value = _.merge value, merged
        else
          for key2, value2 of value
            merge value, value2, key2
      else if _.isString( value ) or _.isNumber( value ) or _.isBoolean( value )
        null
      else
        throw new Error "Unhandled value '#{value}'"
      result[ key ] = value

    _.transform c, merge

  ctx_property: ( prop, desc ) ->
    ctx_prop_spec desc
    Object.defineProperty @, prop, desc

  # Class funcs

  @count: ->
    return Context._i

  @reset: ->
    Context._i = 0

# Class vars
Context.reset()
Context.name = "context-mpe"

module.exports = Context

