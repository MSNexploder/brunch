(function() {
  var DSL, PathMatcher, YamlConfig, coffee, dsl, fs, path, scoped;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  fs = require('fs');
  coffee = require('coffee-script');
  path = require('path');
  scoped = require('../helpers').scoped;
  PathMatcher = require('./path_matcher').PathMatcher;
  YamlConfig = require('./yaml_config').YamlConfig;
  DSL = (function() {
    function DSL() {
      this.matchers = [];
      this.context = {};
      this.locals = {
        files: __bind(function() {
          return this.files.apply(this, arguments);
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
      matcher = new PathMatcher(paths);
      this.matchers.push(matcher);
      return matcher;
    };
    DSL.prototype.defineWith = function(code) {
      return scoped(code)(this.context, this.locals);
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
    yaml = new YamlConfig(path, options);
    return yaml.toOptions();
  };
}).call(this);
