# Id: nodelib/0.0.5-dev-f-component-metadata+20150716-2341 src/node/index.coffee

version = "0.0.5-dev-f-component-metadata+20150716-2341" # nodelib

module.exports =
  Context: require './context'
  metadata: require './metadata'
  module: require './module'
  route: require './route'
  error: require './error'
  util: require './util'
  version: version


