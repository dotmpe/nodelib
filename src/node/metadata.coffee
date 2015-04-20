###

Load metadata for directories/files.
Data is stored in local files, can be in different formats.

This could get quite extensive. Currently only read YAML.

Want some centralized or integrated storage (xattr, ldap)?

###

path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
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

load = ( from_path, type )->
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
  readJrcModDef: ( md, name )->
    from_file = path.join md.dir
    data = fs.readFileSync from_file, 'ascii'
    mdef = parseJrcHeader data
    _.defaults mdef,
      id: path.join md.name
      deps: null
      title: null
      description: null
  parseJrcHeader: ( str )->
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

