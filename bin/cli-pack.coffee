#!/usr/bin/env coffee
chalk = require 'chalk'

libcomponent = require '../src/node/component'
libmodule = require '../src/node/module'
libmetadata = require '../src/node/metadata'



# load first dir-bound metafile
cwd = process.cwd()
packs = libcomponent.DirMeta.load cwd

cmd = 'info'

# maybe its coffeescript but this doesnt work
if process.execArgv.length 
  cmd = process.execArgv.pop()

if process.argv.length > 2
  cmd = process.argv.pop()

console.log chalk.green("[#{cmd}]")
for pack in packs
  if not pack?
    continue # TODO
  pack[cmd]()


