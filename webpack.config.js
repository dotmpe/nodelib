
module.exports = {
  entry: [ './src/node/index.coffee' ],
  output: {
    filename: 'dist/nodelib.js'
  },
	module: {
		loaders: [
			{ test: /\.coffee$/, loader: "coffee" },
			{ test: /\.json$/, loader: "json" }
		]
	},
	resolve: {
		extensions: [
		  "", ".coffee", ".js"
		]
	},
	/* Allow Node.JS globals */
  //  process: "empty",
	/* Allow Node.JS stdlib */
  node: {
    fs: "empty",
    child_process: "empty",
    net: "empty"
  },
}

