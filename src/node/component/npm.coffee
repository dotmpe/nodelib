path = require 'path'
child_process = require 'child_process'


_ = require 'lodash'

libmetadata = require '../metadata'



class NPM extends libmetadata.types.JSONGeneric

  meta: ->

    meta = super

    handlers = []
    if meta.scripts?
      if meta.scripts.run?
        handlers.push 'run'
      if meta.scripts.test?
        handlers.push 'test'

    handlers = _.merge @defaults.handlers, handlers

    _.defaults @data, @defaults,
      handlers: handlers

  @load: ( from_path ) ->
    c = path.parse from_path
    if c.base != 'package.json'
      p = path.join c.dir, 'package.json'
    else
      p = path.join c.dir, c.base
    super p

  execCli: ( script )->
    meta = @meta()
    cmd = meta.scripts[ script ]
    child_process.exec cmd, ( err, stdo, stde ) ->
      if err
        console.error "Error: #{err}"
        console.error "Standard error stream: #{stde}"
        console.error "Standard output stream: #{stdo}"
      else
        console.log stdo

  run: ->
    @execCli 'run'

  test: ->
    @execCli 'test'


module.exports = NPM

