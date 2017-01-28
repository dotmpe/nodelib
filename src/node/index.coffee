# Id: nodelib/0.0.6-test3 src/node/index.coffee

version = "0.0.6-test3" # nodelib


module.exports =
  Context: require './context'
  metadata: require './metadata'
  module: require './module'
  route: require './route'
  error: require './error'
  util: require './util'
  version: version


