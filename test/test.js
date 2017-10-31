'use strict';

var assert = require('assert');

var Context = require('../build/js/lib/src/node/context');


var ctx = new Context({'foo': 1});
assert.equal( ctx.foo, 1 );

var ctx2 = ctx.getSub({'foo': 2});
assert.equal( ctx.foo, 1 );
assert.equal( ctx2.foo, 2 );

console.log(ctx);
console.log(ctx2);

