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
  mode: 'production',
  output: {
    path: path.join(__dirname, 'dist'),
    library: "nodelib",
    libraryTarget: "commonjs2",
    filename: 'nodelib.js'
  },
  module: {
    rules: [
      { test: /\.js$/, exclude: /node_modules/, use: { loader: 'babel-loader' } },
      { test: /\.coffee$/, use: { loader: "coffee-loader" } },
    ]
  },
  externals: nodeModules,
  plugins: [
    new webpack.BannerPlugin({ banner: 'require("source-map-support").install();',
                               raw: true, entryOnly: false })
  ],
  resolve: {
    extensions: [
      ".coffee", ".js"
    ]
  },
  devtool: 'sourcemap',
};

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

gulp.task('default', gulp.series([ 'dist-build' ]));
