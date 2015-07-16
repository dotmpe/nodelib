###

.mpe 2015 Some code to quickly start an extensible Express app.

  'express-mvc/0.1'

  'express-mvc-ext/0.1'

###
path = require 'path'

_ = require 'lodash'
uuid = require 'node-uuid'

metadata = require './metadata'
applyRoutes = require('./route').applyRoutes

applyParams = ( app, context ) ->
  if context.params
    for name, handler of context.params
      app.param( name, handler )

class Component

  constructor: ( opts ) ->
    {@app, @server, @root, @pkg, @config, @meta, @url, @path, @route} = opts
    @base = {}
    @controllers = {}
    @routes = {}
    @models = {}
    @params = {}

  @load_config: ( name ) ->
    {}

  configure: ->
    p = @root || @path

    @name = @name || @meta.name

    if not @controllerPath
      @controllerPath = path.join p, 'controllers'
    if not @modelPath
      @modelPath = path.join p, 'models'
    if not @viewPath
      @viewPath = path.join p, 'views'

    @load_models()
    @load_controllers()

  load_models: ->
    knex = @app.get('knex.main')
    if not knex
      knex = require('knex')(@config.database.main)
      @app.set('knex.main', knex)
      #console.log(chalk.grey('Initialized main DB conn'))
    # FIXME
    Base = Bookshelf.initialize(knex)
    @modelbase = Bookshelf.session = Base
    # Prepare Bookshelf.{model,collection} registries
    Base.plugin 'registry'


  load_model: ( name ) ->
    if not @models[name]
      modpath = path.join @modelPath, name
      @models[name] = require(modpath).define(@modelbase)
    @models[name]

  load_controllers: ->
    if ! @meta.controllers
      console.warn 'No controllers for component', @name
      return

    cs = @meta.controllers
    if _.isArray cs
      @load_controller_names()
    else if _.isObject( cs ) and not _.isEmpty cs
      @update_controller cs

    @apply_controllers()

  load_controller_names: ->
    p = @root || @path

    # load configured controllers
    for ctrl in @meta.controllers

      ctrl_path = path.join( p, ctrl )
      @controllers[ ctrl ] = require ctrl_path
      try
        updateObj = @controllers[ ctrl ] @, @base
      catch err
        console.error "Unable to load #{ctrl}"
        throw err

      @update_controller updateObj

      console.log "Component: #{@name} loaded", ctrl, "controller"


  update_controller: ( updateObj ) ->
    #console.log @meta, updateObj
    # update global meta object
    comp = @core || @
    if updateObj.meta
      _.merge comp.meta, updateObj.meta

    if updateObj.params
      # keep params at local module
      _.merge @params, updateObj.params

    if updateObj.route
      # keep routes at local module
      _.merge @route, updateObj.route

  apply_controllers: ->
    # pick of new routes from updateObj
    _.extend @routes, applyRoutes( @app, @url, @ )

    applyParams @app, @

    if @meta.default_route
      defroute = path.join( @url, @meta.default_route )
      @app.all @url, @base.redirect(defroute)


class Core extends Component

  constructor: (opts) ->
    super opts
    @name = @name || 'core'

  # static init for core, relay app init to core module, then init
  @config: ( core_path ) ->
    core_file = path.join __noderoot, core_path, 'main'
    core_seed_cb = require core_file
    # Return core opts
    opts = core_seed_cb core_path
    _.defaults opts, route: {}
    opts


class CoreV01 extends Core

  ###

  | Encapsulate Express MVC for extension.
  | XXX what to use for models?

  - views
  - models
  - controllers

  ###

  constructor: (opts) ->
    super opts
    @modules = {}

  configure: ->
    # url must point to netpath, WITHOUT any *path* part (ie. including root)
    # so any sub-component can deal with abs or rel paths
    @url = @url || ''
    #@viewPath = @app.get 'views'
    @modelPath = path.join @root, 'models'

    # Add some more locals for Jade templates
    self = @
    @app.use (req, res, next) ->
      res.locals.core = self
      res.locals.modules = []
      next()

    super

  ###
    CoreV01.load_modules
  ###
  load_modules: ->
    #console.log 'load_modules', @config.modules
    modroot = path.join __noderoot, @config.src || 'src'
    mods = _.extend( [], @config.modules, @meta.modules )
    for modpath in mods
      fullpath = path.join( modroot, modpath )
      mod = ModuleV01.load( @, fullpath )
      mod.configure()
      @modules[ mod.meta.name ] = mod
      console.log 'loaded module', modpath, mod.meta.name

  ###
    CoreV01.get_all_components
  ###
  get_all_components: ->
    comps = [ @ ]
    _.union comps, _.values( @modules )

  start: ->
    self = @
    @server.listen @app.get("port"), ->
      console.log "Express server listening on port " + self.app.get("port")

  @load: ( core_path ) ->
    # TODO sync with Module.load:
    #md = metadata.load( core_path )
    #if not md
    #  md = type: 'express-mvc/0.1'
    # static configuration
    opts = Core.config( core_path )
    new CoreV01( opts )


class ModuleV01 extends Component

  ###

  | Handle Express MVC extension modules.

  - handlers
  - routes

  ###

  # Get new instance holding module metadata and config.
  constructor: ( opts ) ->
    {@core} = opts
    if !opts.name
      opts.name = 'ModuleV01'
    super opts

  # Static methods

  # Read module metadata from path, load MVC-ext-type modules
  @load: ( core, from_path ) ->
    md = metadata.load( from_path )
    if !md
      console.warn "No module to load from", from_path
      return
    for mdc in md
      if mdc.type in [ 'express-mvc-ext/0.1', 'express-mvc-ext/0.2' ]
        md = metadata.resolve_mvc_meta from_path, mdc
        if !md.controllers
          console.error "Missing MVC meta for ", mdc
        ModuleClass = module_classes[ md.ext_version ]
        opts = ModuleClass.config( core, md, from_path )
        return new ModuleClass( opts )

  @config: ( core, md, from_path ) ->
    meta: md || name: md.name
    config: md.config || {}
    route: md.route || {}
    core: core
    app: core.app
    base: core.base
    path: from_path

module_classes = {
  '0.1': ModuleV01
  '0.2': ModuleV01
}

# set globals to track projects and apps
#
session = {
  instances: { },
  projects: { },
  apps: { }
}

init = ( node_path, app_path=null ) ->
  if not session.projects[node_path]
    code_id = uuid.v4()
    session.projects[node_path] = code_id
  else
    code_id = session.projects[node_path]

  global.__noderoot = node_path


load_core = ( app_path ) ->
  global.__approot = app_path
  app_id

  if not session.apps[app_path]
    app_id = uuid.v4()
    session.apps[app_path] = app_id
  else
    app_id = session.apps[app_path]

  global.__appid = app_id

  if not session.instances[app_id]
    session.instances[app_id] = core = CoreV01.load( app_path )

  else
    core = session.instances[app_id]

  core


load_module = ( mod_path ) ->
  module.configure extroot
  module.load app


module.exports = {
  session: session
  init: init
  classes:
    Core: CoreV01
    Module: ModuleV01
  load_core: load_core,
  #load_module: load_module,
  load_and_start: ( app_path ) ->
    init process.cwd()
    core = load_core app_path
    core.configure()
    core.load_modules()
    core.start()
}

