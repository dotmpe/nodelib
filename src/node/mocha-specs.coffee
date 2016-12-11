###

While mocha has no need for dry-run, this script was made to query and maybe
interact with the test specs.

- It relies on synchronous loading of specs while patching globals.
- This is all strictly line-based to keep it simple and codesize low.

https://github.com/mochajs/mocha/pull/1070
###
path = require 'path'
fs = require 'fs'
_ = require 'lodash'



defaultopts =
  dirname: './test/mocha/'
  format: 'yaml'
  indent: ''
  yaml:
    description_style: 'keys'
    description_attr: 'name'
    item_style: 'numerical_keys'
    item_attr: 'it'


schema =
  properties:
    format:
      enum: [ 'rst', 'yaml' ]
    rst: {}
    yaml:
      properties:
        description_style:
          enum: [ 'keys', 'attr' ]
        description_attr:
          type: 'string'
        item_style:
          enum: [ 'list_attr', 'numerical_keys' ]
        item_attr:
          type: 'string'


getopts = ( opts={} ) ->
  _.defaultsDeep opts, defaultopts


id_re = /^[A-Za-z_][A-Za-z0-9_]+$/


writers =
  rst:
    describe: ( opts, ctx, text ) ->
      tab = opts.feature_table.find('ID', text)
      if tab
        console.log "#{opts.indent}#{tab.CAT}. #{text}"
      else
        console.log "#{opts.indent}- #{text}"
      console.log ''
    start_describe: ( opts, ctx, text ) ->
    end_describe: ( opts, ctx ) ->
    it: ( opts, ctx, idx, text ) ->
      console.log "#{opts.indent}#{idx}. #{text}"
    start_it: ( opts, ctx, idx, text ) ->
    end_it: ( opts, ctx, idx, text ) ->
      console.log ''

  yaml:
    describe: ( opts, ctx, text ) ->
      if opts.yaml.description_style == 'keys'
        if text.match id_re
          console.log "#{opts.indent}#{text}:"
        else
          console.log "#{opts.indent}'#{text}':"
      else if opts.yaml.description_style == 'attr'
        attr = opts.yaml.description_attr
        if text.match id_re
          console.log "#{opts.indent}- #{attr}: #{text}:"
        else
          console.log "#{opts.indent}- #{attr}: '#{text}':"
        #opts.indent += '  '
    start_describe: ( opts, ctx, text ) ->
    end_describe: ( opts, ctx ) ->

    it: ( opts, ctx, idx, text ) ->
      if opts.yaml.item_style == 'numerical_keys'
        if text.match id_re
          console.log "#{opts.indent}#{idx}: #{text}"
        else
          console.log "#{opts.indent}#{idx}: '#{text}'"
      #else if opts.yaml.item_style == 'list_attr'
      # XXX: need two lines to print list attr, iow. add start_it method
      #  attr = opts.yaml.item_attr
      #  if text.match id_re
      #    console.log "#{opts.indent}#{idx}: #{text}"
      #  else
      #    console.log "#{opts.indent}#{idx}: '#{text}'"
    start_it: ( opts, ctx, idx, text ) ->
    end_it: ( opts, ctx, idx, text ) ->


class MochaSpecReader
  constructor: ( @base='../../' ) ->
    @base = process.cwd()+'/'
    @specs = {}

  populate_spec: ( opts, file_name ) ->
    global.before = ->
    global.beforeEach = ->
    global.after = ->
    global.afterEach = ->
    ctx = {}
    ctx.timeout = ->
    global.spec = cwd: '', items: [], comps: {}

    describe = ( text, cb ) ->
      
      spec = global.spec
      nspec = spec.comps[text] = cwd: '', items: [], comps: {}
      nspec.cwd = spec.cwd+' / '+text

      global.spec = nspec

      cb.bind(ctx)()

      global.spec = spec

      null

    it = ( text, cb ) ->
   
      spec.items.push text

      null

    global.describe = describe.bind ctx
    global.it = it.bind ctx

    spec_name = path.basename file_name, '.coffee'

    require @base+path.join opts.dirname, spec_name

    @specs[spec_name] = spec

    delete global.before
    delete global.beforeEach
    delete global.after
    delete global.afterEach
    delete global.spec

    return spec_name

  @load_dir: ( opts ) ->
    reader = new MochaSpecReader()
    for file_name in fs.readdirSync opts.dirname
      if not file_name.match /\.coffee$/
        continue
      name = reader.populate_spec opts, file_name

    reader

  @print: ( name, ctx, opts ) ->
    for name_ of ctx.comps
      writers[opts.format].describe opts, ctx.comps[name_], name_
      if 'comps' of ctx.comps[name_]
        opts.indent += '  '
        MochaSpecReader.print( name_, ctx.comps[name_], opts )
        opts.indent = opts.indent.substr 2
      if 'items' of ctx.comps[name_]
        opts.indent += '  '
        writers[opts.format].start_it opts, ctx.comps[name_]
        for item, idx in ctx.comps[name_].items
          writers[opts.format].it opts, ctx.comps[name_], ( 1 + idx ) , item
        writers[opts.format].end_it opts, ctx.comps[name_]
        opts.indent = opts.indent.substr 2


module.exports =
  opts:
    defaults: defaultopts
    schema: schema
    get: getopts
  MochaSpecReader: MochaSpecReader
  print_all: ( specs, opts=null ) ->
    if not opts
      opts = getopts()
    console.log opts.feature_table
    for name of specs
      writers[opts.format].describe opts, specs[name], name
      opts.indent = '  '
      MochaSpecReader.print name, specs[name], opts
      opts.indent = opts.indent.substr 2


