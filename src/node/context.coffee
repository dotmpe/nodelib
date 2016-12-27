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
  if not ref.match /^#\/.*/
    throw new Error "Absolute JSON ref only support"
  ref.substr(2)
    .replace(/([^\\])\//g, '$1.')
    .replace(/\\\//g, '/')


class Context

  ###
    Obj. hierarchy with dynamic, inherited properties.
  ###

  constructor: ( init, ctx=null ) ->
    @_instance = ++ Context._i
    # Provide path to super context
    @context = ctx
    # XXX unused @_defaults = init
    @_data = {}
    @_subs = []
    # XXX: re-create all properties from context, needed?
    # Also what if wait until local is overriden..
    if ctx and ctx._data
      @prepare_from_obj ctx._data
    # add properties for, and seed from init into local data
    @add_data init

  id: -> if @context then @context.id() + '.' + @_instance else @_instance
  toString: -> 'Context:' + @id()
  isEmpty: -> _.isEmpty @_data and if @context then @context.isEmpty() else true
  subs: -> @_subs # List subcontexts

  # Seed property data from obj
  seed: ( obj ) ->
    for k, v of obj
      @_data[ k ] = v
    @

  # Create local properties using keys in obj (ignores existing data keys)
  prepare_from_obj: ( obj ) ->
    for k, v of obj
      @prepare_property k
    @

  prepare_all: ( keys ) ->
    for k in keys
      @prepare_property k
    @

  prepare_property: ( k ) ->
    if k of @_data
      return
    @_ctx_property k,
      get: @_ctxGetter( k )
      set: @_ctxSetter( k )
    @

  # new subcontext, inherits current instance, optional new or override vars
  getSub: ( init ) ->
    class SubContext extends Context
      constructor: ( init, sup ) ->
        Context.call @, init, sup
    sub = new SubContext init, @
    @_subs.push sub
    sub

  # Short cut for adding new attributes from data
  add_data: ( obj ) -> @prepare_from_obj obj; @seed obj

  # get an object by json path reference,
  get: ( p_ ) ->
    p = p_.replace(/([^\\])\./g, '$1\n')
      .replace(/\\\./, '.').split '\n'
    c = @
    while p.length
      name = p.shift()
      if name of c
        c = c[ name ]
      else
        console.error "no #{name} of #{p_} in", c
        throw new error.types.NonExistantPathElementException(
          "Unable to get #{name} of #{p_}" )
    c

  # get an object by json path reference,
  # and resolve all contained references too
  resolve: ( p_, defaultValue ) ->
    p = p_.replace(/([^\\])\./g, '$1\n')
      .replace(/\\\./, '.').split '\n'
    c = self = @

    # resolve an object with $ref key
    _deref = (o) ->
      ls = o
      rs = self.get refToPath o.$ref
      if _.isPlainObject rs
        rs = _.merge ls, rs
      rs

    # replace current with referenced path
    if '$ref' of c
      try
        c = _deref c
      catch err
        if defaultValue?
          return defaultValue
        throw err

    while p.length

      # replace current with sub at next path element
      name = p.shift()

      if name of c
        c = c[ name ]

        #if not _.isPlainObject( c )
        if not _.isObject( c )
          continue

        if '$ref' of c
          try
            c = _deref c
          catch err
            if defaultValue?
              return defaultValue
            throw err

      else
        console.error "no #{name} of #{p_} in", c
        throw new Error "Unable to resolve #{name} of #{p_}"

    if _.isPlainObject c
      return @merge c

    c

  # XXX drop $ref from return value
  _clean: ( c ) ->
    for k, v of c
      if _.isPlainObject v
        w = _.clone v
        if '$ref' of w
          delete w.$ref
        @_clean w
        c[k] = w
    c

  # recurive resolve
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
          deref = self.get refToPath value.$ref
          if _.isPlainObject deref
            merged = self.merge deref
            delete value.$ref
            value = _.merge value, merged
          else
            value = deref
        else
          for key2, value2 of value
            merge value, value2, key2

      else if _.isString( value ) or _.isNumber( value ) or _.isBoolean( value )
        null

      else
        throw new Error "Unhandled value '#{value}'"

      result[ key ] = value

      result

    _.transform c, merge

  to_dict: ->
    d = {}
    _ctx = @
    while _ctx
      d = _.merge d, _ctx._data
      _ctx = _ctx.context
    d


  ## Private functions

  _ctx_property: ( prop, desc ) ->
    ctx_prop_spec desc
    Object.defineProperty @, prop, desc

  # return a getter for property `k`: returns local data or tries context
  _ctxGetter: ( k ) ->
    ->
      if k of @_data
        @_data[ k ]
      else if @context?
        @context[ k ]

  # return a setter for property `k`: set into local data
  _ctxSetter: ( k ) ->
    ( newVal ) ->
      @_data[ k ] = newVal


  ## Class funcs

  @count: ->
    return Context._i

  @reset: ->
    Context._i = 0


# Class vars
Context.reset()
# XXX: not strict: Context.name = "context-mpe"

module.exports = Context

