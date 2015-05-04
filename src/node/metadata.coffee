###

Load metadata for directories/files.
Data is stored in local files, can be in different formats.

This could get quite extensive. Currently only read YAML.

Want some centralized or integrated storage (xattr, ldap)?

###

path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
chalk = require 'chalk'
_ = require 'lodash'

codelib = require './code'



typeIsArray = Array.isArray ||
  ( value ) -> return {}.toString.call( value ) is '[object Array]'

# TODO: metafile should support various directory formats
#metafiles = [ 'main.*', 'module.*', '.meta' ]
metafiles = [ 'main.meta', 'module.meta', '.meta' ]

loadDir = ( from_path ) ->
  for metaf in metafiles
    metap = path.join( from_path, metaf )
    if fs.existsSync metap
      return yaml.safeLoad fs.readFileSync metap, 'utf8'

load = ( from_path, type ) ->
  md = loadDir from_path
  if _.isEmpty md
    return
  if _.isEmpty type
    return md
  if _.isArray md
    for item in md
      if item.type?
        if item.type == type
          return item
  if _.isObject md
    if md.type?
      if md.type == type
        return md
    return null


# Parse, fetch and return MVC metadata for module
resolve_mvc_meta = ( from_path, meta ) ->

  version = meta.type.split('/')[1]
  meta.path = from_path
  meta.ext_version = version

  if not meta.components
    meta.components = [ 'models', 'views', 'controllers' ]

  for compname in meta.components
    comppath = path.join( from_path, compname )
    pathprop = compname.substring(0, compname.length-1) + 'Path'
    meta[ pathprop ] = comppath

  #for compname in meta.components
  #  compidx = require comppath

  #  if typeIsArray( compidx )
  #    compcbs = compidx
  #  else
  #    compcbs = [ compidx ]

  #  comps = []
  #  for compcb in compcbs
  #    if _.isFunction compcb
  #      comps.push compcb meta
  #    else
  #      comps.push compcb

  #  #meta[ compname ] = comps

  meta

module.exports =

  loadDir: loadDir
  load: load
  resolve_mvc_meta: resolve_mvc_meta
  readJrcModDef: ( md, name ) ->
    from_file = path.join md.dir
    data = fs.readFileSync from_file, 'ascii'
    mdef = parseJrcHeader data
    _.defaults mdef,
      id: path.join md.name
      deps: null
      title: null
      description: null
  parseJrcHeader: ( str ) ->
    header = codelib.firstComment str
    m = {}
    for head in header
      p = head.indexOf ' '
      if p == -1
        continue
      propname = head.substr 0, p
      argstr = head.substr p+1
      p = propname.indexOf ':'
      if p == -1
        continue
      prefix = propname.substr 0, p
      if prefix != 'jrc'
        continue
      key = propname.substr p+1
      if key == 'export'
        m.id = argstr.trim()
      if key == 'import'
        deps = argstr.trim().split(' ')
        m.deps = deps
      if key == 'description'
        m.description = argstr.trim()
      if key == 'title'
        m.title = argstr.trim()
    m



class AbstractGeneric

  constructor: ( @data, defaults ) ->
    @defaults = _.defaults defaults,
      name: 'Generic metadata'
      handlers: []

  meta: ->
    _.defaults @data, @defaults

  info: ->
    meta = @meta()
    console.log chalk.yellow('---')
    console.log chalk.blue('Path')+':', chalk.green( meta.path )
    console.log chalk.blue('Name')+':', chalk.green( meta.name )
    console.log chalk.blue('Handlers')+':', chalk.green( meta.handlers.join ',' )
    console.log chalk.yellow('...')

  canDo: ( action_name ) ->
    meta = @meta()
    meta.handlers.hasOwnProperty action_name

  run: ->
    if @canDo 'run'
      @perform 'run'

  test: ->
    if @canDo 'test'
      @perform 'test'


class JSONGeneric extends AbstractGeneric

  "Any value, usually List or Dict style"

  @load: ( from_path ) ->
    relative = './' + path.relative __dirname, from_path
    new this require( relative ), path: from_path


class YAMLGeneric extends AbstractGeneric

  "Any value, usually List or Dict style"

  @load: ( from_path ) ->
    data = yaml.safeLoad fs.readFileSync from_path, 'utf8'
    new this data, path: from_path


class RstEmbeddedDict extends AbstractGeneric
  "A dict from the docinfo if present"

class PropertiesDict
  "A dict with properties"

class INIDict
  "A dict from sections and embedded properties"


module.exports.types =
  JSONGeneric: JSONGeneric
  YAMLGeneric: YAMLGeneric
  RstEmbeddedDict: RstEmbeddedDict
  PropertiesDict: PropertiesDict
  INIDict: INIDict

