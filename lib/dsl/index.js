(function() {
  var DSL, PathMatcher, YamlConfig, coffee, colors, dsl, fs, helpers, path;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  fs = require('fs');
  coffee = require('coffee-script');
  path = require('path');
  helpers = require('../helpers');
  colors = require('../../vendor/termcolors').colors;
  PathMatcher = require('./path_matcher').PathMatcher;
  YamlConfig = require('./yaml_config').YamlConfig;
  DSL = (function() {
    function DSL() {
      this._buildPath = 'build';
      this.matchers = [];
      this.context = {};
      this.locals = {
        files: __bind(function() {
          return this.files.apply(this, arguments);
        }, this),
        buildPath: __bind(function() {
          return this.buildPath.apply(this, arguments);
        }, this),
        require: require,
        global: global,
        process: process,
        module: module
      };
    }
    DSL.prototype.files = function() {
      var matcher, paths;
      paths = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      matcher = new PathMatcher(this, paths);
      this.matchers.push(matcher);
      return matcher;
    };
    DSL.prototype.buildPath = function(path) {
      this._buildPath = path;
      return this;
    };
    DSL.prototype.defineWith = function(code) {
      return helpers.scoped(code)(this.context, this.locals);
    };
    DSL.prototype.readAndCompile = function(file) {
      var code;
      code = this.read(file);
      return coffee.compile(code);
    };
    DSL.prototype.read = function(file) {
      return fs.readFileSync(file, 'utf8');
    };
    DSL.prototype.runFile = function(file) {
      var code;
      this.locals.__filename = path.join(process.cwd(), file);
      this.locals.__dirname = process.cwd();
      this.locals.module.filename = this.locals.__filename;
      code = this.readAndCompile(file);
      return this.run(code);
    };
    DSL.prototype.run = function(code) {
      var matcher, options, _i, _len, _ref;
      this.defineWith(code);
      options = {};
      _ref = this.matchers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        matcher = _ref[_i];
        if (matcher.name == null) {
          next;
        }
        options[matcher.name] = matcher.options;
      }
      return options;
    };
    return DSL;
  })();
  dsl = new DSL;
  exports.matchers = dsl.matchers;
  exports.run = function() {
    return dsl.run.apply(dsl, arguments);
  };
  exports.loadConfigFile = function() {
    return dsl.runFile.apply(dsl, arguments);
  };
  exports.loadYamlConfigFile = function(path, options) {
    var yaml;
    helpers.log(colors.lred("brunch:   old yaml based config file found! Please switch to new coffee-script based configuration!\n", true));
    yaml = new YamlConfig(path, options);
    return yaml.toOptions();
  };
}).call(this);
