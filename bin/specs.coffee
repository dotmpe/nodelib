#!/usr/bin/env coffee

libmochaspecs = require '../src/node/mocha-specs'
libspecs = require '../src/node/specs'
libtable = require '../src/node/table'


if process.argv.length == 2
  process.argv.push '--help'

cmd = process.argv[2]


if cmd in [ '--version', '--help' ]
 
  pkg = require '../package.json'
  console.log "nodelib-specs/"+pkg.version


else if cmd in [ '--specs' ]

  # Print Mocha specs as YAML/reStructuredText

  if process.argv.length < 4
    process.argv.push libmochaspecs.opts.defaults.format

  opts = libmochaspecs.opts.get format: process.argv[3]

  libtable.Table.parse( filename='features.tab' ).then ( table ) ->
    opts.feature_table = table
    reader = libmochaspecs.MochaSpecReader.load_dir( opts )
    libmochaspecs.print_all reader.specs, opts


else if cmd in [ '--verify', '--components', '--refs', '--update' ]

  if process.argv.length < 4
    process.argv.push 'specs.rst'

  # Parse specs from reStructuredText subset
  doc = libspecs.parse process.argv[3]

  if cmd in [ '--verify' ]

    null # rely on parser checks, add schema check in the future


  else if cmd in [ '--components' ]

    libspecs.print_components doc


  else if cmd in [ '--refs' ]

    libspecs.print_refs doc


  else if cmd in [ '--update' ]

    updates = []
    while process.argv.length > 3
      upd = libspecs.parse process.argv.shift()
      doc.update upd
      updates.push upd
    
    libspecs.print doc


else
  throw Error "Command expected"

