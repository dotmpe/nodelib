var gulp = require('gulp');
var webpack = require('webpack');
var path = require('path');
var fs = require('fs');

var nodeModules = {};
fs.readdirSync('node_modules')
  .filter(function(x) {
    return ['.bin'].indexOf(x) === -1;
  })
  .forEach(function(mod) {
    nodeModules[mod] = 'commonjs ' + mod;
  });

var config = {
  entry: [ './src/node/index.coffee' ],
  target: 'node',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'nodelib.js'
  },
  module: {
    loaders: [
      { test: /\.js$/, exclude: /node_modules/, loaders: ['babel'] },
			{ test: /\.coffee$/, loader: "coffee" },
    ]
  },
  externals: nodeModules,
  plugins: [
    new webpack.BannerPlugin('require("source-map-support").install();',
                             { raw: true, entryOnly: false })
  ],
	resolve: {
		extensions: [
			"", ".coffee", ".js"
		]
	},
  devtool: 'sourcemap',
  libraryTarget: "commonjs2"
}

gulp.task('dist-build', function(done) {
  webpack(config).run(function(err, stats) {
    if(err) {
      console.log('Error', err);
    }
    else {
      console.log(stats.toString());
    }
    done();
  });
});

gulp.task('default', [ 'dist-build' ]);
