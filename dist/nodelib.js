require("source-map-support").install();
module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var version;
	
	version = "0.0.6-dev";
	
	module.exports = {
	  Context: __webpack_require__(2),
	  metadata: __webpack_require__(5),
	  module: __webpack_require__(11),
	  route: __webpack_require__(14),
	  error: __webpack_require__(4),
	  util: __webpack_require__(21),
	  version: version
	};


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	A coffeescript implementation of a context
	with inheritance and override.
	
	See also dotmpe/invidia for JS
	 */
	var Context, _, ctx_prop_spec, error, refToPath,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;
	
	_ = __webpack_require__(3);
	
	error = __webpack_require__(4);
	
	ctx_prop_spec = function(desc) {
	  return _.defaults(desc, {
	    enumerable: false,
	    configurable: true
	  });
	};
	
	refToPath = function(ref) {
	  if (!ref.match(/^#\/.*/)) {
	    throw new Error("Absolute JSON ref only support");
	  }
	  return ref.substr(2).replace(/([^\\])\//g, '$1.').replace(/\\\//g, '/');
	};
	
	Context = (function() {
	
	  /*
	    Obj. hierarchy with dynamic, inherited properties.
	   */
	  function Context(init, ctx) {
	    if (ctx == null) {
	      ctx = null;
	    }
	    this._instance = ++Context._i;
	    this.context = ctx;
	    this._data = {};
	    this._subs = [];
	    if (ctx && ctx._data) {
	      this.prepare_from_obj(ctx._data);
	    }
	    this.add_data(init);
	  }
	
	  Context.prototype.id = function() {
	    if (this.context) {
	      return this.context.id() + '.' + this._instance;
	    } else {
	      return this._instance;
	    }
	  };
	
	  Context.prototype.toString = function() {
	    return 'Context:' + this.id();
	  };
	
	  Context.prototype.isEmpty = function() {
	    return _.isEmpty(this._data && (this.context ? this.context.isEmpty() : true));
	  };
	
	  Context.prototype.subs = function() {
	    return this._subs;
	  };
	
	  Context.prototype.seed = function(obj) {
	    var k, v;
	    for (k in obj) {
	      v = obj[k];
	      this._data[k] = v;
	    }
	    return this;
	  };
	
	  Context.prototype.prepare_from_obj = function(obj) {
	    var k, v;
	    for (k in obj) {
	      v = obj[k];
	      this.prepare_property(k);
	    }
	    return this;
	  };
	
	  Context.prototype.prepare_all = function(keys) {
	    var i, k, len;
	    for (i = 0, len = keys.length; i < len; i++) {
	      k = keys[i];
	      this.prepare_property(k);
	    }
	    return this;
	  };
	
	  Context.prototype.prepare_property = function(k) {
	    if (k in this._data) {
	      return;
	    }
	    this._ctx_property(k, {
	      get: this._ctxGetter(k),
	      set: this._ctxSetter(k)
	    });
	    return this;
	  };
	
	  Context.prototype.getSub = function(init) {
	    var SubContext, sub;
	    SubContext = (function(superClass) {
	      extend(SubContext, superClass);
	
	      function SubContext(init, sup) {
	        Context.call(this, init, sup);
	      }
	
	      return SubContext;
	
	    })(Context);
	    sub = new SubContext(init, this);
	    this._subs.push(sub);
	    return sub;
	  };
	
	  Context.prototype.add_data = function(obj) {
	    this.prepare_from_obj(obj);
	    return this.seed(obj);
	  };
	
	  Context.prototype.get = function(p_) {
	    var c, name, p;
	    p = p_.replace(/([^\\])\./g, '$1\n').replace(/\\\./, '.').split('\n');
	    c = this;
	    while (p.length) {
	      name = p.shift();
	      if (name in c) {
	        c = c[name];
	      } else {
	        console.error("no " + name + " of " + p_ + " in", c);
	        throw new error.types.NonExistantPathElementException("Unable to get " + name + " of " + p_);
	      }
	    }
	    return c;
	  };
	
	  Context.prototype.resolve = function(p_, defaultValue) {
	    var _deref, c, err, name, p, self;
	    p = p_.replace(/([^\\])\./g, '$1\n').replace(/\\\./, '.').split('\n');
	    c = self = this;
	    _deref = function(o) {
	      var ls, rs;
	      ls = o;
	      rs = self.get(refToPath(o.$ref));
	      if (_.isPlainObject(rs)) {
	        rs = _.merge(ls, rs);
	      }
	      return rs;
	    };
	    if ('$ref' in c) {
	      try {
	        c = _deref(c);
	      } catch (error1) {
	        err = error1;
	        if (defaultValue != null) {
	          return defaultValue;
	        }
	        throw err;
	      }
	    }
	    while (p.length) {
	      name = p.shift();
	      if (name in c) {
	        c = c[name];
	        if (!_.isObject(c)) {
	          continue;
	        }
	        if ('$ref' in c) {
	          try {
	            c = _deref(c);
	          } catch (error1) {
	            err = error1;
	            if (defaultValue != null) {
	              return defaultValue;
	            }
	            throw err;
	          }
	        }
	      } else {
	        console.error("no " + name + " of " + p_ + " in", c);
	        throw new Error("Unable to resolve " + name + " of " + p_);
	      }
	    }
	    if (_.isPlainObject(c)) {
	      return this.merge(c);
	    }
	    return c;
	  };
	
	  Context.prototype._clean = function(c) {
	    var k, v, w;
	    for (k in c) {
	      v = c[k];
	      if (_.isPlainObject(v)) {
	        w = _.clone(v);
	        if ('$ref' in w) {
	          delete w.$ref;
	        }
	        this._clean(w);
	        c[k] = w;
	      }
	    }
	    return c;
	  };
	
	  Context.prototype.merge = function(c) {
	    var merge, self;
	    self = this;
	    merge = function(result, value, key) {
	      var deref, i, index, item, key2, len, merged, value2;
	      if (_.isArray(value)) {
	        for (index = i = 0, len = value.length; i < len; index = ++i) {
	          item = value[index];
	          merge(value, item, index);
	        }
	      } else if (_.isPlainObject(value)) {
	        if ('$ref' in value) {
	          deref = self.get(refToPath(value.$ref));
	          if (_.isPlainObject(deref)) {
	            merged = self.merge(deref);
	            delete value.$ref;
	            value = _.merge(value, merged);
	          } else {
	            value = deref;
	          }
	        } else {
	          for (key2 in value) {
	            value2 = value[key2];
	            merge(value, value2, key2);
	          }
	        }
	      } else if (_.isString(value) || _.isNumber(value) || _.isBoolean(value)) {
	        null;
	      } else {
	        throw new Error("Unhandled value '" + value + "'");
	      }
	      result[key] = value;
	      return result;
	    };
	    return _.transform(c, merge);
	  };
	
	  Context.prototype.to_dict = function() {
	    var _ctx, d;
	    d = {};
	    _ctx = this;
	    while (_ctx) {
	      d = _.merge(d, _ctx._data);
	      _ctx = _ctx.context;
	    }
	    return d;
	  };
	
	  Context.prototype._ctx_property = function(prop, desc) {
	    ctx_prop_spec(desc);
	    return Object.defineProperty(this, prop, desc);
	  };
	
	  Context.prototype._ctxGetter = function(k) {
	    return function() {
	      if (k in this._data) {
	        return this._data[k];
	      } else if (this.context != null) {
	        return this.context[k];
	      }
	    };
	  };
	
	  Context.prototype._ctxSetter = function(k) {
	    return function(newVal) {
	      return this._data[k] = newVal;
	    };
	  };
	
	  Context.count = function() {
	    return Context._i;
	  };
	
	  Context.reset = function() {
	    return Context._i = 0;
	  };
	
	  return Context;
	
	})();
	
	Context.reset();
	
	module.exports = Context;


/***/ },
/* 3 */
/***/ function(module, exports) {

	module.exports = require("lodash");

/***/ },
/* 4 */
/***/ function(module, exports) {

	var NonExistantPathElementException,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;
	
	NonExistantPathElementException = (function(superClass) {
	  extend(NonExistantPathElementException, superClass);
	
	  function NonExistantPathElementException() {
	    return NonExistantPathElementException.__super__.constructor.apply(this, arguments);
	  }
	
	  null;
	
	  return NonExistantPathElementException;
	
	})(Error);
	
	module.exports = {
	  types: {
	    NonExistantPathElementException: NonExistantPathElementException
	  }
	};


/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	
	Load metadata for directories/files.
	Data is stored in local files, can be in different formats.
	
	This could get quite extensive. Currently only read YAML.
	
	Want some centralized or integrated storage (xattr, ldap)?
	 */
	var _, codelib, fs, load, loadDir, metafiles, path, resolve_mvc_meta, typeIsArray, yaml;
	
	path = __webpack_require__(6);
	
	fs = __webpack_require__(7);
	
	yaml = __webpack_require__(8);
	
	_ = __webpack_require__(3);
	
	codelib = __webpack_require__(9);
	
	typeIsArray = Array.isArray || function(value) {
	  return {}.toString.call(value) === '[object Array]';
	};
	
	metafiles = ['main.meta', 'module.meta', '.meta'];
	
	loadDir = function(from_path) {
	  var i, len, metaf, metap;
	  for (i = 0, len = metafiles.length; i < len; i++) {
	    metaf = metafiles[i];
	    metap = path.join(from_path, metaf);
	    if (fs.existsSync(metap)) {
	      return yaml.safeLoad(fs.readFileSync(metap, 'utf8'));
	    }
	  }
	};
	
	load = function(from_path, type) {
	  var i, item, len, md;
	  md = loadDir(from_path);
	  if (_.isEmpty(md)) {
	    return;
	  }
	  if (_.isEmpty(type)) {
	    return md;
	  }
	  if (_.isArray(md)) {
	    for (i = 0, len = md.length; i < len; i++) {
	      item = md[i];
	      if (item.type != null) {
	        if (item.type === type) {
	          return item;
	        }
	      }
	    }
	  }
	  if (_.isObject(md)) {
	    if (md.type != null) {
	      if (md.type === type) {
	        return md;
	      }
	    }
	    return null;
	  }
	};
	
	resolve_mvc_meta = function(from_path, meta) {
	  var compname, comppath, i, len, pathprop, ref, version;
	  version = meta.type.split('/')[1];
	  meta.path = from_path;
	  meta.ext_version = version;
	  if (!meta.components) {
	    meta.components = ['models', 'views', 'controllers'];
	  }
	  ref = meta.components;
	  for (i = 0, len = ref.length; i < len; i++) {
	    compname = ref[i];
	    comppath = path.join(from_path, compname);
	    pathprop = compname.substring(0, compname.length - 1) + 'Path';
	    meta[pathprop] = comppath;
	  }
	  return meta;
	};
	
	module.exports = {
	  loadDir: loadDir,
	  load: load,
	  resolve_mvc_meta: resolve_mvc_meta,
	  readJrcModDef: function(md, name) {
	    var data, from_file, mdef;
	    from_file = path.join(md.dir);
	    data = fs.readFileSync(from_file, 'ascii');
	    mdef = parseJrcHeader(data);
	    return _.defaults(mdef, {
	      id: path.join(md.name),
	      deps: null,
	      title: null,
	      description: null
	    });
	  },
	  parseJrcHeader: function(str) {
	    var argstr, deps, head, header, i, key, len, m, p, prefix, propname;
	    header = codelib.firstComment(str);
	    m = {};
	    for (i = 0, len = header.length; i < len; i++) {
	      head = header[i];
	      p = head.indexOf(' ');
	      if (p === -1) {
	        continue;
	      }
	      propname = head.substr(0, p);
	      argstr = head.substr(p + 1);
	      p = propname.indexOf(':');
	      if (p === -1) {
	        continue;
	      }
	      prefix = propname.substr(0, p);
	      if (prefix !== 'jrc') {
	        continue;
	      }
	      key = propname.substr(p + 1);
	      if (key === 'export') {
	        m.id = argstr.trim();
	      }
	      if (key === 'import') {
	        deps = argstr.trim().split(' ');
	        m.deps = deps;
	      }
	      if (key === 'description') {
	        m.description = argstr.trim();
	      }
	      if (key === 'title') {
	        m.title = argstr.trim();
	      }
	    }
	    return m;
	  }
	};


/***/ },
/* 6 */
/***/ function(module, exports) {

	module.exports = require("path");

/***/ },
/* 7 */
/***/ function(module, exports) {

	module.exports = require("fs");

/***/ },
/* 8 */
/***/ function(module, exports) {

	module.exports = require("js-yaml");

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	var LineReader, _, cleanLineComment, firstComment, isLineComment, os;
	
	os = __webpack_require__(10);
	
	_ = __webpack_require__(3);
	
	LineReader = (function() {
	  function LineReader(str1, eol, lines1) {
	    this.str = str1;
	    this.eol = eol != null ? eol : os.EOL;
	    this.lines = lines1 != null ? lines1 : [];
	  }
	
	  LineReader.prototype.hasNext = function() {
	    return !_.isEmpty(this.str);
	  };
	
	  LineReader.prototype.next = function() {
	    line;
	    var line, p;
	    p = this.str.indexOf(this.eol);
	    if (p > -1) {
	      line = this.str.substr(0, p);
	      this.str = this.str.substr(p + this.eol.length);
	    } else {
	      line = this.str;
	      this.str = '';
	    }
	    this.lines.push(line);
	    return line;
	  };
	
	  return LineReader;
	
	})();
	
	isLineComment = function(line) {
	  return line.trim().substr(0, 1) === '#';
	};
	
	cleanLineComment = function(line) {
	  return line.trim().substr(1).trim();
	};
	
	firstComment = function(str) {
	  var line, lineReader, lines;
	  lines = [];
	  lineReader = new LineReader(str);
	  while (lineReader.hasNext()) {
	    line = lineReader.next();
	    if (isLineComment(line)) {
	      lines.push(cleanLineComment(line));
	    }
	  }
	  return lines;
	};
	
	module.exports = {
	  firstComment: firstComment,
	  isLineComment: isLineComment,
	  cleanLineComment: cleanLineComment
	};


/***/ },
/* 10 */
/***/ function(module, exports) {

	module.exports = require("os");

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(module) {
	/*
	
	.mpe 2015 Some code to quickly start an extensible Express app.
	
	  'express-mvc/0.1'
	
	  'express-mvc-ext/0.1'
	 */
	var Component, Core, CoreV01, ModuleV01, _, applyParams, applyRoutes, init, load_core, load_module, metadata, module_classes, path, session, uuid,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty,
	  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };
	
	path = __webpack_require__(6);
	
	_ = __webpack_require__(3);
	
	uuid = __webpack_require__(13);
	
	metadata = __webpack_require__(5);
	
	applyRoutes = __webpack_require__(14).applyRoutes;
	
	applyParams = function(app, context) {
	  var handler, name, ref, results;
	  if (context.params) {
	    ref = context.params;
	    results = [];
	    for (name in ref) {
	      handler = ref[name];
	      results.push(app.param(name, handler));
	    }
	    return results;
	  }
	};
	
	Component = (function() {
	  function Component(opts) {
	    this.app = opts.app, this.server = opts.server, this.root = opts.root, this.pkg = opts.pkg, this.config = opts.config, this.meta = opts.meta, this.url = opts.url, this.path = opts.path, this.route = opts.route;
	    this.base = {};
	    this.controllers = {};
	    this.routes = {};
	    this.models = {};
	    this.params = {};
	  }
	
	  Component.load_config = function(name) {
	    return {};
	  };
	
	  Component.prototype.configure = function() {
	    console.log("TODO component.configure", [this.name, this.meta, this.base, this.path, this.route]);
	    return this.load_controllers();
	  };
	
	  Component.prototype.load_models = function() {
	    return Base.plugin('registry');
	  };
	
	  Component.prototype.load_controllers = function() {
	    var cs;
	    if (!this.meta.controllers) {
	      console.warn('No controllers for component', this.name);
	      return;
	    }
	    cs = this.meta.controllers;
	    if (_.isArray(cs)) {
	      return this.load_controller_names();
	    } else if (_.isObject(cs) && !_.isEmpty(cs)) {
	      return this.update_controller(cs);
	    }
	  };
	
	  Component.prototype.load_model = function(name) {
	    var modpath;
	    if (!this.models[name]) {
	      modpath = path.join(this.modelPath, name);
	      this.models[name] = __webpack_require__(15)(modpath).define(this.modelbase);
	    }
	    return this.models[name];
	  };
	
	  Component.prototype.load_controller_names = function() {
	    var ctrl, ctrl_path, err, i, len, p, ref, results, updateObj;
	    p = this.root || this.path;
	    ref = this.meta.controllers;
	    results = [];
	    for (i = 0, len = ref.length; i < len; i++) {
	      ctrl = ref[i];
	      ctrl_path = path.join(p, ctrl);
	      this.controllers[ctrl] = __webpack_require__(15)(ctrl_path);
	      try {
	        updateObj = this.controllers[ctrl](this, this.base);
	      } catch (error) {
	        err = error;
	        console.error("Unable to load " + ctrl);
	        throw err;
	      }
	      this.update_controller(updateObj);
	      results.push(console.log("Component: " + this.name + " loaded", ctrl, "controller"));
	    }
	    return results;
	  };
	
	  Component.prototype.update_controller = function(updateObj) {
	    var comp;
	    comp = this.core || this;
	    if (updateObj.meta) {
	      _.merge(comp.meta, updateObj.meta);
	    }
	    if (updateObj.params) {
	      _.merge(this.params, updateObj.params);
	    }
	    if (updateObj.route) {
	      return _.merge(this.route, updateObj.route);
	    }
	  };
	
	  return Component;
	
	})();
	
	Core = (function(superClass) {
	  extend(Core, superClass);
	
	  function Core(opts) {
	    Core.__super__.constructor.call(this, opts);
	    this.name = this.name || 'core';
	  }
	
	  Core.prototype.configure = function() {
	    var p;
	    p = this.root || this.path;
	    this.name = this.name || this.meta.name;
	    if (!this.controllerPath) {
	      this.controllerPath = path.join(p, 'controllers');
	    }
	    if (!this.modelPath) {
	      this.modelPath = path.join(p, 'models');
	    }
	    if (!this.viewPath) {
	      this.viewPath = path.join(p, 'views');
	    }
	    this.load_models();
	    this.load_controllers();
	    return this.apply_controllers();
	  };
	
	  Core.prototype.apply_controllers = function() {
	    var defroute;
	    _.extend(this.routes, applyRoutes(this.app, this.url, this));
	    applyParams(this.app, this);
	    if (this.meta.default_route) {
	      defroute = path.join(this.url, this.meta.default_route);
	      return this.app.all(this.url, this.base.redirect(defroute));
	    }
	  };
	
	  Core.config = function(md, core_path) {
	    var core_file, core_seed_cb, opts;
	    core_file = path.join(__noderoot, core_path, 'main');
	    core_seed_cb = __webpack_require__(15)(core_file);
	    opts = core_seed_cb(core_path);
	    _.defaults(opts, {
	      route: {}
	    });
	    return opts;
	  };
	
	  return Core;
	
	})(Component);
	
	CoreV01 = (function(superClass) {
	  extend(CoreV01, superClass);
	
	
	  /*
	  
	  | Encapsulate Express MVC for extension.
	  | XXX what to use for models?
	  
	  - views
	  - models
	  - controllers
	   */
	
	  function CoreV01(opts) {
	    CoreV01.__super__.constructor.call(this, opts);
	    this.modules = {};
	  }
	
	  CoreV01.prototype.configure = function() {
	    var self;
	    this.url = this.url || '';
	    this.modelPath = path.join(this.root, 'models');
	    self = this;
	    this.app.use(function(req, res, next) {
	      res.locals.core = self;
	      res.locals.modules = [];
	      return next();
	    });
	    return CoreV01.__super__.configure.apply(this, arguments);
	  };
	
	
	  /*
	    CoreV01.load_modules
	   */
	
	  CoreV01.prototype.load_modules = function() {
	    var fullpath, i, len, mod, modpath, modroot, mods, results;
	    modroot = path.join(__noderoot, this.config.src || 'src');
	    mods = _.extend([], this.config.modules, this.meta.modules);
	    results = [];
	    for (i = 0, len = mods.length; i < len; i++) {
	      modpath = mods[i];
	      fullpath = path.join(modroot, modpath);
	      mod = ModuleV01.load(this, fullpath);
	      mod.configure();
	      this.modules[mod.meta.name] = mod;
	      console.log('Loaded module', modpath, mod.meta.name);
	      results.push(console.log(mod.route));
	    }
	    return results;
	  };
	
	
	  /*
	    CoreV01.get_all_components
	   */
	
	  CoreV01.prototype.get_all_components = function() {
	    var comps;
	    comps = [this];
	    return _.union(comps, _.values(this.modules));
	  };
	
	  CoreV01.prototype.start = function() {
	    var self;
	    self = this;
	    return this.server.listen(this.app.get("port"), function() {
	      return console.log("Express server listening on port " + self.app.get("port"));
	    });
	  };
	
	  CoreV01.DEFAULT_METADATA = [
	    {
	      type: 'express-mvc-core/0.2'
	    }
	  ];
	
	  CoreV01.SUPPORTED = ['express-mvc-core/0.1', 'express-mvc-core/0.2'];
	
	  CoreV01.load = function(core_path) {
	    var i, len, md, mdc, ref;
	    md = metadata.load(core_path);
	    if (!md) {
	      console.warn("No metadata for core", core_path);
	      md = CoreV01.DEFAULT_METADATA;
	    }
	    for (i = 0, len = md.length; i < len; i++) {
	      mdc = md[i];
	      if (!'type' in mdc) {
	        continue;
	      }
	      if (ref = mdc.type, indexOf.call(CoreV01.SUPPORTED, ref) >= 0) {
	        return CoreV01.load_from_metadata(core_path, mdc);
	      }
	    }
	    throw new Error("No known core interface on module at " + core_path);
	  };
	
	  CoreV01.load_from_metadata = function(core_path, mdc) {
	    var CoreClass, opts;
	    CoreClass = CoreV01;
	    opts = CoreClass.config([mdc], core_path);
	    return new CoreClass(opts);
	  };
	
	  return CoreV01;
	
	})(Core);
	
	ModuleV01 = (function(superClass) {
	  extend(ModuleV01, superClass);
	
	
	  /*
	  
	  | Handle Express MVC extension modules.
	  
	  - handlers
	  - routes
	   */
	
	  function ModuleV01(opts) {
	    this.core = opts.core;
	    if (!opts.name) {
	      opts.name = 'ModuleV01';
	    }
	    ModuleV01.__super__.constructor.call(this, opts);
	  }
	
	  ModuleV01.DEFAULT_METADATA = [
	    {
	      type: 'express-mvc-ext/0.2'
	    }
	  ];
	
	  ModuleV01.SUPPORTED = ['express-mvc-ext/0.1', 'express-mvc-ext/0.2'];
	
	  ModuleV01.load = function(core, from_path) {
	    var i, len, md, mdc, ref;
	    md = metadata.load(from_path);
	    if (!md) {
	      console.warn("No metadata for module", from_path);
	      md = ModuleV01.DEFAULT_METADATA;
	    }
	    for (i = 0, len = md.length; i < len; i++) {
	      mdc = md[i];
	      if (!'type' in mdc) {
	        continue;
	      }
	      if (ref = mdc.type, indexOf.call(ModuleV01.SUPPORTED, ref) >= 0) {
	        return ModuleV01.load_from_metadata(core, from_path, mdc);
	      }
	    }
	    throw new Error("No known extension interface on module at " + from_path);
	  };
	
	  ModuleV01.load_from_metadata = function(core, from_path, mdc) {
	    var ModuleClass, md, opts;
	    md = metadata.resolve_mvc_meta(from_path, mdc);
	    if (!md.controllers) {
	      console.error("Missing MVC meta for ", mdc);
	    }
	    ModuleClass = module_classes[md.ext_version];
	    opts = ModuleClass.config(core, md, from_path);
	    return new ModuleClass(opts);
	  };
	
	  ModuleV01.config = function(core, md, from_path) {
	    return {
	      meta: md || {
	        name: md.name
	      },
	      config: md.config || {},
	      route: md.route || {},
	      core: core,
	      app: core.app,
	      base: core.base,
	      path: from_path
	    };
	  };
	
	  return ModuleV01;
	
	})(Component);
	
	module_classes = {
	  '0.1': ModuleV01,
	  '0.2': ModuleV01
	};
	
	session = {
	  instances: {},
	  projects: {},
	  apps: {}
	};
	
	init = function(node_path, app_path) {
	  var code_id;
	  if (app_path == null) {
	    app_path = null;
	  }
	  if (!session.projects[node_path]) {
	    code_id = uuid.v4();
	    session.projects[node_path] = code_id;
	  } else {
	    code_id = session.projects[node_path];
	  }
	  return global.__noderoot = node_path;
	};
	
	load_core = function(app_path) {
	  var app_id, core;
	  global.__approot = app_path;
	  app_id;
	  if (!session.apps[app_path]) {
	    app_id = uuid.v4();
	    session.apps[app_path] = app_id;
	  } else {
	    app_id = session.apps[app_path];
	  }
	  global.__appid = app_id;
	  if (!session.instances[app_id]) {
	    session.instances[app_id] = core = CoreV01.load(app_path);
	  } else {
	    core = session.instances[app_id];
	  }
	  return core;
	};
	
	load_module = function(mod_path) {
	  module.configure(extroot);
	  return module.load(app);
	};
	
	module.exports = {
	  session: session,
	  init: init,
	  classes: {
	    Core: CoreV01,
	    Module: ModuleV01
	  },
	  load_core: load_core,
	  load_and_start: function(app_path) {
	    var core;
	    init(process.cwd());
	    core = load_core(app_path);
	    core.configure();
	    core.load_modules();
	    return core.start();
	  }
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(12)(module)))

/***/ },
/* 12 */
/***/ function(module, exports) {

	module.exports = function(module) {
		if(!module.webpackPolyfill) {
			module.deprecate = function() {};
			module.paths = [];
			// module.parent = undefined by default
			module.children = [];
			module.webpackPolyfill = 1;
		}
		return module;
	}


/***/ },
/* 13 */
/***/ function(module, exports) {

	module.exports = require("node-uuid");

/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	Metadata to Express helpers.
	 */
	var _, applyRoutes, resolveHandler,
	  slice = [].slice;
	
	_ = __webpack_require__(3);
	
	resolveHandler = function(module, cb) {
	  var core, name, ref, type;
	  ref = cb.substr(0, cb.length - 1).split('('), type = ref[0], name = ref[1];
	  core = module.core;
	  return new core.base.type[type](module, name);
	};
	
	applyRoutes = function(app, root, module) {
	  var cb, h, i, len, method, name, ref, ref1, route, routes, subRoutes, url;
	  if (!app) {
	    throw new Error("Missing app");
	  }
	  routes = {};
	  ref = module.route;
	  for (name in ref) {
	    route = ref[name];
	    url = [root, name].join('/').replace('$', ':');
	    if (route.route) {
	      subRoutes = applyRoutes(app, url, route);
	      _.extend(routes, subRoutes);
	    }
	    ref1 = ['all', 'get', 'put', 'post', 'options', 'delete'];
	    for (i = 0, len = ref1.length; i < len; i++) {
	      method = ref1[i];
	      cb = route[method];
	      if (cb) {
	        if (!(url in routes)) {
	          routes[url] = {};
	        }
	        if (method in routes[url]) {
	          console.error("Already routed: ", method, url);
	        }
	        routes[url][method] = cb;
	        if (_.isArray(cb)) {
	          app[method].apply(app, [url].concat(slice.call(cb)));
	        } else if (_.isString(cb)) {
	          h = resolveHandler(module, cb);
	          app[method](url, _.bind(h[method], h));
	        } else {
	          app[method](url, cb);
	        }
	      }
	    }
	  }
	  return routes;
	};
	
	module.exports = {
	  applyRoutes: applyRoutes
	};


/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	var map = {
		"./code": 9,
		"./code.coffee": 9,
		"./context": 2,
		"./context.coffee": 2,
		"./error": 4,
		"./error.coffee": 4,
		"./index": 1,
		"./index.coffee": 1,
		"./metadata": 5,
		"./metadata.coffee": 5,
		"./mocha-specs": 16,
		"./mocha-specs.coffee": 16,
		"./module": 11,
		"./module.coffee": 11,
		"./route": 14,
		"./route.coffee": 14,
		"./specs": 17,
		"./specs.coffee": 17,
		"./table": 19,
		"./table.coffee": 19,
		"./util": 21,
		"./util.coffee": 21
	};
	function webpackContext(req) {
		return __webpack_require__(webpackContextResolve(req));
	};
	function webpackContextResolve(req) {
		return map[req] || (function() { throw new Error("Cannot find module '" + req + "'.") }());
	};
	webpackContext.keys = function webpackContextKeys() {
		return Object.keys(map);
	};
	webpackContext.resolve = webpackContextResolve;
	module.exports = webpackContext;
	webpackContext.id = 15;


/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	
	While mocha has no need for dry-run, this script was made to query and maybe
	interact with the test specs.
	
	- It relies on synchronous loading of specs while patching globals.
	- This is all strictly line-based to keep it simple and codesize low.
	
	https://github.com/mochajs/mocha/pull/1070
	 */
	var MochaSpecReader, _, defaultopts, fs, getopts, id_re, path, schema, writers;
	
	path = __webpack_require__(6);
	
	fs = __webpack_require__(7);
	
	_ = __webpack_require__(3);
	
	defaultopts = {
	  dirname: './test/mocha/',
	  format: 'yaml',
	  indent: '',
	  yaml: {
	    description_style: 'keys',
	    description_attr: 'name',
	    item_style: 'numerical_keys',
	    item_attr: 'it'
	  }
	};
	
	schema = {
	  properties: {
	    format: {
	      "enum": ['rst', 'yaml']
	    },
	    rst: {},
	    yaml: {
	      properties: {
	        description_style: {
	          "enum": ['keys', 'attr']
	        },
	        description_attr: {
	          type: 'string'
	        },
	        item_style: {
	          "enum": ['list_attr', 'numerical_keys']
	        },
	        item_attr: {
	          type: 'string'
	        }
	      }
	    }
	  }
	};
	
	getopts = function(opts) {
	  if (opts == null) {
	    opts = {};
	  }
	  return _.defaultsDeep(opts, defaultopts);
	};
	
	id_re = /^[A-Za-z_][A-Za-z0-9_]+$/;
	
	writers = {
	  rst: {
	    describe: function(opts, ctx, text) {
	      var tab;
	      tab = opts.feature_table.find('ID', text);
	      if (tab) {
	        console.log("" + opts.indent + tab.CAT + ". " + text);
	      } else {
	        console.log(opts.indent + "- " + text);
	      }
	      return console.log('');
	    },
	    start_describe: function(opts, ctx, text) {},
	    end_describe: function(opts, ctx) {},
	    it: function(opts, ctx, idx, text) {
	      return console.log("" + opts.indent + idx + ". " + text);
	    },
	    start_it: function(opts, ctx, idx, text) {},
	    end_it: function(opts, ctx, idx, text) {
	      return console.log('');
	    }
	  },
	  yaml: {
	    describe: function(opts, ctx, text) {
	      var attr;
	      if (opts.yaml.description_style === 'keys') {
	        if (text.match(id_re)) {
	          return console.log("" + opts.indent + text + ":");
	        } else {
	          return console.log(opts.indent + "'" + text + "':");
	        }
	      } else if (opts.yaml.description_style === 'attr') {
	        attr = opts.yaml.description_attr;
	        if (text.match(id_re)) {
	          return console.log(opts.indent + "- " + attr + ": " + text + ":");
	        } else {
	          return console.log(opts.indent + "- " + attr + ": '" + text + "':");
	        }
	      }
	    },
	    start_describe: function(opts, ctx, text) {},
	    end_describe: function(opts, ctx) {},
	    it: function(opts, ctx, idx, text) {
	      if (opts.yaml.item_style === 'numerical_keys') {
	        if (text.match(id_re)) {
	          return console.log("" + opts.indent + idx + ": " + text);
	        } else {
	          return console.log("" + opts.indent + idx + ": '" + text + "'");
	        }
	      }
	    },
	    start_it: function(opts, ctx, idx, text) {},
	    end_it: function(opts, ctx, idx, text) {}
	  }
	};
	
	MochaSpecReader = (function() {
	  function MochaSpecReader(base) {
	    this.base = base != null ? base : '../../';
	    this.base = process.cwd() + '/';
	    this.specs = {};
	  }
	
	  MochaSpecReader.prototype.populate_spec = function(opts, file_name) {
	    var ctx, describe, it, spec_name;
	    global.before = function() {};
	    global.beforeEach = function() {};
	    global.after = function() {};
	    global.afterEach = function() {};
	    ctx = {};
	    ctx.timeout = function() {};
	    global.spec = {
	      cwd: '',
	      items: [],
	      comps: {}
	    };
	    describe = function(text, cb) {
	      var nspec, spec;
	      spec = global.spec;
	      nspec = spec.comps[text] = {
	        cwd: '',
	        items: [],
	        comps: {}
	      };
	      nspec.cwd = spec.cwd + ' / ' + text;
	      global.spec = nspec;
	      cb.bind(ctx)();
	      global.spec = spec;
	      return null;
	    };
	    it = function(text, cb) {
	      spec.items.push(text);
	      return null;
	    };
	    global.describe = describe.bind(ctx);
	    global.it = it.bind(ctx);
	    spec_name = path.basename(file_name, '.coffee');
	    __webpack_require__(15)(this.base + path.join(opts.dirname, spec_name));
	    this.specs[spec_name] = spec;
	    delete global.before;
	    delete global.beforeEach;
	    delete global.after;
	    delete global.afterEach;
	    delete global.spec;
	    return spec_name;
	  };
	
	  MochaSpecReader.load_dir = function(opts) {
	    var file_name, i, len, name, reader, ref;
	    reader = new MochaSpecReader();
	    ref = fs.readdirSync(opts.dirname);
	    for (i = 0, len = ref.length; i < len; i++) {
	      file_name = ref[i];
	      if (!file_name.match(/\.coffee$/)) {
	        continue;
	      }
	      name = reader.populate_spec(opts, file_name);
	    }
	    return reader;
	  };
	
	  MochaSpecReader.print = function(name, ctx, opts) {
	    var i, idx, item, len, name_, ref, results;
	    results = [];
	    for (name_ in ctx.comps) {
	      writers[opts.format].describe(opts, ctx.comps[name_], name_);
	      if ('comps' in ctx.comps[name_]) {
	        opts.indent += '  ';
	        MochaSpecReader.print(name_, ctx.comps[name_], opts);
	        opts.indent = opts.indent.substr(2);
	      }
	      if ('items' in ctx.comps[name_]) {
	        opts.indent += '  ';
	        writers[opts.format].start_it(opts, ctx.comps[name_]);
	        ref = ctx.comps[name_].items;
	        for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
	          item = ref[idx];
	          writers[opts.format].it(opts, ctx.comps[name_], 1 + idx, item);
	        }
	        writers[opts.format].end_it(opts, ctx.comps[name_]);
	        results.push(opts.indent = opts.indent.substr(2));
	      } else {
	        results.push(void 0);
	      }
	    }
	    return results;
	  };
	
	  return MochaSpecReader;
	
	})();
	
	module.exports = {
	  opts: {
	    defaults: defaultopts,
	    schema: schema,
	    get: getopts
	  },
	  MochaSpecReader: MochaSpecReader,
	  print_all: function(specs, opts) {
	    var name, results;
	    if (opts == null) {
	      opts = null;
	    }
	    if (!opts) {
	      opts = getopts();
	    }
	    console.log(opts.feature_table);
	    results = [];
	    for (name in specs) {
	      writers[opts.format].describe(opts, specs[name], name);
	      opts.indent = '  ';
	      MochaSpecReader.print(name, specs[name], opts);
	      results.push(opts.indent = opts.indent.substr(2));
	    }
	    return results;
	  }
	};


/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	
	Parse specs.rst
	  - Check indices, build ids, check refs.
	
	Update one file using another
	  - Update descriptions given existing index
	  - Create new indices for new descriptions
	
	Print
	  - specs.rst
	  - specs.refs.rst
	  - specs.res.cites.rst
	  - specs.yaml
	 */
	var Output, Spec, YamlOutput, _, context, fs, path,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;
	
	path = __webpack_require__(6);
	
	fs = __webpack_require__(7);
	
	_ = __webpack_require__(3);
	
	context = __webpack_require__(2);
	
	Spec = (function() {
	  function Spec(description, specs1) {
	    this.description = description != null ? description : null;
	    this.specs = specs1 != null ? specs1 : [];
	  }
	
	  Spec.prototype.add = function(spec) {
	    return specs.push(spec);
	  };
	
	  Spec.root = null;
	
	  Spec.add = function(spec) {
	    return Spec.root.add(spec);
	  };
	
	  Spec.update = function(doc) {};
	
	  return Spec;
	
	})();
	
	Output = (function() {
	  function Output() {}
	
	  return Output;
	
	})();
	
	YamlOutput = (function(superClass) {
	  extend(YamlOutput, superClass);
	
	  function YamlOutput() {}
	
	  YamlOutput.prototype.write = function() {};
	
	  return YamlOutput;
	
	})(Output);
	
	module.exports.parse = function(filename) {
	  var lineReader, nstack, stack, suites;
	  suites = [];
	  nstack = function(indent) {
	    if (indent == null) {
	      indent = '';
	    }
	    return {
	      indent: indent,
	      specs: [],
	      description: null,
	      index: null,
	      sid: null
	    };
	  };
	  stack = [];
	  lineReader = __webpack_require__(18).createInterface({
	    input: fs.createReadStream(filename)
	  });
	  return lineReader.on('line', function(line) {
	    var err, idx, m, nst, root, ws;
	    if (!line.trim()) {
	      return;
	    }
	    m = line.match(/^\s*([0-9\.]+|-)\s([^\[]*)(\s\[([0-9`_\.]+)\])?$/);
	    if (m) {
	      ws = line.match(/^(\s*)/);
	      root = ws[1].length === 0;
	      if (root) {
	        nst = nstack(ws[1]);
	        nst.sid = m[1];
	        nst.description = m[2].trim();
	        stack.push(nst);
	        suites.push(nst);
	      }
	      if (stack[stack.length - 1].indent.length > ws[1].length) {
	        while (stack[stack.length - 1].indent.length !== ws[1].length) {
	          stack.pop();
	        }
	        console.log('');
	      }
	      if (stack[stack.length - 1].indent === ws[1]) {
	        if (root) {
	          stack[stack.length - 1].index = suites.length;
	          console.log('');
	        } else {
	          nst = nstack(ws[1]);
	          nst.index = stack[stack.length - 1].index + 1;
	          nst.description = m[2].trim();
	          stack.pop();
	          if (stack[stack.length - 1].sid === '-') {
	            nst.sid = String(nst.index) + ".";
	          } else {
	            nst.sid = stack[stack.length - 1].sid + String(nst.index) + ".";
	          }
	          stack.push(nst);
	        }
	        try {
	          idx = parseInt(m[1].trim('.'), 10);
	        } catch (error) {
	          err = error;
	          null;
	        }
	        if (isNaN(idx)) {
	          idx = '-';
	        }
	        if (typeof idx !== 'string' && stack[stack.length - 1].index !== idx) {
	          if (idx !== 0) {
	            throw Error("Index " + stack[stack.length - 1].index + " " + m[1]);
	          }
	        }
	        return console.log(stack[stack.length - 1].indent + stack[stack.length - 1].sid, stack[stack.length - 1].description);
	      } else if (stack[stack.length - 1].indent.length < ws[1].length) {
	        nst = nstack(ws[1]);
	        nst.description = m[2].trim();
	        try {
	          nst.index = parseInt(m[1].trim('.'), 10);
	        } catch (error) {
	          err = error;
	          null;
	        }
	        if (isNaN(nst.index)) {
	          nst.index = suites.length;
	        }
	        if (stack[stack.length - 1].sid === '-') {
	          nst.sid = String(nst.index) + ".";
	        } else {
	          nst.sid = stack[stack.length - 1].sid + String(nst.index) + ".";
	        }
	        console.log('');
	        console.log(nst.indent + nst.sid, nst.description);
	        return stack.push(nst);
	      }
	    } else {
	      return null;
	    }
	  });
	};
	
	module.exports.print = function(doc) {};
	
	module.exports.print_refs = function(doc) {};
	
	module.exports.print_components = function(doc) {};


/***/ },
/* 18 */
/***/ function(module, exports) {

	module.exports = require("readline");

/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	 */
	var Promise, Table, _, fs, path, readline;
	
	readline = __webpack_require__(18);
	
	path = __webpack_require__(6);
	
	fs = __webpack_require__(7);
	
	_ = __webpack_require__(3);
	
	Promise = __webpack_require__(20);
	
	Table = (function() {
	  function Table(headers1, rows) {
	    this.headers = headers1 != null ? headers1 : {};
	    this.rows = rows != null ? rows : [];
	    this.raw = [];
	  }
	
	  Table.parse_headers = function(line) {
	    var col, headers, i, key, keys, len, w;
	    headers = [];
	    keys = line.split(/\s+/);
	    keys.shift();
	    for (i = 0, len = keys.length; i < len; i++) {
	      key = keys[i];
	      w = line.match(RegExp(key + "\\s*"));
	      if (!w) {
	        throw Error(key);
	      }
	      col = {
	        key: key,
	        offset: w.index,
	        width: w[0].length,
	        match: w
	      };
	      headers.push(col);
	      if (headers.length === 1) {
	        headers[0].offset -= 2;
	      }
	    }
	    return headers;
	  };
	
	  Table.prototype.parse_row = function(line) {
	    var hd, i, lasthd, len, ref, row;
	    row = {};
	    lasthd = this.headers[this.headers.length - 1];
	    if (line.length > lasthd.offset + lasthd.width) {
	      lasthd.width = line.length - lasthd.offset;
	    }
	    ref = this.headers;
	    for (i = 0, len = ref.length; i < len; i++) {
	      hd = ref[i];
	      row[hd.key] = line.substr(hd.offset, hd.width).trim();
	    }
	    this.rows.push(row);
	    return row;
	  };
	
	  Table.parse = function(filename) {
	    var table;
	    table = new Table(null);
	    return new Promise(function(resolve, reject) {
	      var lineReader;
	      lineReader = readline.createInterface({
	        input: fs.createReadStream(filename)
	      });
	      lineReader.on('line', function(line) {
	        var comment;
	        if (!line.trim()) {
	          return;
	        }
	        comment = line.match(/^#(.*)$/);
	        if (comment) {
	          if (_.isEmpty(table.headers)) {
	            table.headers = Table.parse_headers(line);
	          }
	          return;
	        }
	        return table.raw.push(line);
	      });
	      return lineReader.on('close', function() {
	        var i, len, line, ref;
	        ref = table.raw;
	        for (i = 0, len = ref.length; i < len; i++) {
	          line = ref[i];
	          table.parse_row(line);
	        }
	        return resolve(table);
	      });
	    });
	  };
	
	  Table.prototype.find = function(col, value) {
	    var i, len, ref, row;
	    ref = this.rows;
	    for (i = 0, len = ref.length; i < len; i++) {
	      row = ref[i];
	      if (row[col] === value) {
	        return row;
	      }
	    }
	  };
	
	  return Table;
	
	})();
	
	module.exports = {};
	
	module.exports.Table = Table;


/***/ },
/* 20 */
/***/ function(module, exports) {

	module.exports = require("bluebird");

/***/ },
/* 21 */
/***/ function(module, exports) {

	
	/**
	 * Formats mongoose errors into proper array
	 *
	 * @param {Array} errors
	 * @return {Array}
	 * @api public
	 */
	exports.errors = function(errors) {
	  var errs, keys;
	  keys = Object.keys(errors);
	  errs = [];
	  if (!keys) {
	    return ['Oops! There was an error'];
	  }
	  keys.forEach(function(key) {
	    errs.push(errors[key].message);
	  });
	  return errs;
	};
	
	
	/**
	 * Index of object within an array
	 *
	 * @param {Array} arr
	 * @param {Object} obj
	 * @return {Number}
	 * @api public
	 */
	
	exports.indexof = function(arr, obj) {
	  var index, keys, result;
	  index = -1;
	  keys = Object.keys(obj);
	  result = arr.filter(function(doc, idx) {
	    var i, matched;
	    matched = 0;
	    i = keys.length - 1;
	    while (i >= 0) {
	      if (doc[keys[i]] === obj[keys[i]]) {
	        matched++;
	        if (matched === keys.length) {
	          index = idx;
	          return idx;
	        }
	      }
	      i--;
	    }
	  });
	  return index;
	};
	
	
	/**
	 * Find object in an array of objects that matches a condition
	 *
	 * @param {Array} arr
	 * @param {Object} obj
	 * @param {Function} cb - optional
	 * @return {Object}
	 * @api public
	 */
	
	exports.findByParam = function(arr, obj, cb) {
	  var index;
	  index = exports.indexof(arr, obj);
	  if (~index && typeof cb === 'function') {
	    return cb(void 0, arr[index]);
	  } else if (~index && !cb) {
	    return arr[index];
	  } else if (!~index && typeof cb === 'function') {
	    return cb('not found');
	  }
	};


/***/ }
/******/ ]);
//# sourceMappingURL=nodelib.js.map