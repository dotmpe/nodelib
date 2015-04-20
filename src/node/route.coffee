###
Metadata to Express helpers.

###
_ = require 'lodash'


# XXX Init one-off controller instance to handle str-spec callback..
resolveHandler = (module, cb) ->
  [ type, name ] = cb.substr( 0, cb.length - 1 ).split('(')
  core = module.core
  new core.base.type[ type ]( module, name )


applyRoutes = (app, root, module) ->

  if !app
    throw new Error "Missing app"

  routes = {}
  for name, route of module.route
    # full url
    url = [ root, name ].join('/').replace('$', ':')
    # recurse to sub-route
    if route.route
      subRoutes = applyRoutes app, url, route
      _.extend routes, subRoutes
    # apply current level
    for method in ['all', 'get', 'put', 'post', 'options', 'delete']
      cb = route[method]
      if cb
        #console.log url, method
        # Track all routes?
        if url not of routes
          routes[url] = {}
        if method of routes[url]
          console.error "Already routed: ", method, url
        routes[url][method] = cb
        # Apply to Express; ie. app.get( url, callback )
        if _.isArray cb
          app[method].apply app, [ url, cb... ]
        else if _.isString cb
          h = resolveHandler( module, cb )
          app[method] url, _.bind h[method], h
        else
          app[method] url, cb
  routes

module.exports =

  applyRoutes: applyRoutes

