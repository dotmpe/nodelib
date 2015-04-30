# Id: nodelib/0.0.4-dev+20150422 src/node/index.coffee

version = '0.0.4-dev+20150422' # nodelib

module.exports =
	Context: require './context'
	metadata: require './metadata'
	module: require './module'
	route: require './route'
	util: require './util'
	version: version


